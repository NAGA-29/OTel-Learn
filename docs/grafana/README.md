# Grafana で Laravel ログを確認する

このプロジェクトでは、Laravel が出力した JSON ログを OpenTelemetry Collector で正規化し、Loki に保存します。Grafana は Loki を検索・表示するための画面です。Grafana 自身はログを保存しません。

```text
Laravel → JSON log file → OpenTelemetry Collector → Loki → Grafana
```

## まず起動する

リポジトリのルートで実行します。

```bash
make up
```

初回は Grafana と Loki のイメージ取得に少し時間がかかります。起動状態は次で確認できます。

```bash
docker compose ps
```

`grafana`、`loki`、`collector` が `Up` なら準備完了です。`collector-init` が `Exited (0)` なのは正常です。Collector の永続ボリュームへ書き込むための初期化だけを行うサービスなので、常駐しません。

## ログインする

ブラウザで <http://localhost:3000> を開きます。

|項目|値|
|---|---|
|ユーザー名|`admin`|
|パスワード|`admin`|

これはローカルデモ専用の既定値です。変更する場合は、`.env` に次を設定して Grafana を再作成します。

```dotenv
GRAFANA_ADMIN_PASSWORD=your-local-password
```

```bash
docker compose up -d --force-recreate grafana
```

初回起動後にパスワードを変更したいときは、Grafana の画面から変更します。既存の `grafana-data` volume がある状態では、環境変数の変更だけでは既存管理者のパスワードは置き換わりません。

## 最初のログを見る

1. 左メニューの **Explore** を開きます。
2. 左上のデータソースが **Loki** であることを確認します。
3. クエリー欄に次を入力して **Run query** を選びます。

```logql
{service_name="otel-laravel-demo"}
```

ログがまだなければ、別ターミナルで API を呼び出します。

```bash
curl -s http://localhost:8000/api/suppliers
curl -s http://localhost:8000/api/suppliers/1
```

数秒後に Explore で再実行すると、次のようなログが見えます。

- `Suppliers listed` / `Supplier fetched`: アプリケーションのドメインログ
- `request completed`: HTTP アクセスログ

画面右上の期間選択が「Last 15 minutes」など、リクエストを行った時刻を含む範囲になっていることも確認してください。

## よく使う検索

LogQL は Loki の検索言語です。まずは波かっこの中でサービスを指定し、必要なら後ろに条件を追加します。

|目的|LogQL|
|---|---|
|このアプリの全ログ|`{service_name="otel-laravel-demo"}`|
|HTTPアクセスログだけ|`{service_name="otel-laravel-demo"} \| app_log_type="http_access"`|
|GET リクエストだけ|`{service_name="otel-laravel-demo"} \| http_request_method="GET"`|
|404 を含むログ|`{service_name="otel-laravel-demo"} \| http_response_status_code="404"`|
|メッセージに `Supplier` を含むログ|`{service_name="otel-laravel-demo"} \|= "Supplier"`|
|特定リクエストを追跡|`{service_name="otel-laravel-demo"} \| app_request_id="<request-id>"`|

`app_request_id` は、1回の HTTP リクエストに対する識別子です。同じ値で `Supplier fetched` と `request completed` を横断検索できるため、「どの処理が何ミリ秒で終わったか」を追えます。

## 属性名の対応

Laravel の `Log::info()` に渡した `context` は、Collector により OTel 属性として保存されます。Grafana/Loki ではドットがアンダースコアへ変換されます。

|Laravel の context|Grafana / Loki の属性|
|---|---|
|`request_id`|`app_request_id`|
|`method`|`http_request_method`|
|`route`|`http_route`|
|`status_code`|`http_response_status_code`|
|`duration_ms`|`duration_ms`|
|`supplier_id`|`app_supplier_id`|
|`log_type`|`app_log_type`|

新しい context 項目を Grafana で検索したい場合は、Collector の `transform/normalize` に属性化ルールを加えます。フィールドが存在しないログでも安全に動くよう、必ず `where ... != nil` を付けます。

```yaml
- set(attributes["app.supplier.name"], cache["raw"]["context"]["name"])
  where cache["raw"]["context"]["name"] != nil
```

変更後は Collector を再作成します。

```bash
docker compose up -d --force-recreate collector
```

ログに個人情報・認証情報・秘密情報を記録しないことが原則です。Collector の redaction は補助的な対策で、自由文の秘密情報を完全に検出するものではありません。

## このリポジトリの設定

|対象|設定ファイル|役割|
|---|---|---|
|Grafana|`observability/grafana/provisioning/datasources/loki.yaml`|Loki datasource を起動時に自動登録|
|Loki|`observability/loki-config.yaml`|ローカル filesystem へのログ保存と OTLP 受信|
|Collector|`observability/otel-collector.yaml`|ログ正規化と Loki への OTLP/HTTP 送信|
|Compose|`docker-compose.yml`|Grafana / Loki / Collector の接続と永続 volume|

Collector は Loki のネイティブ OTLP endpoint（`http://loki:3100/otlp`）へ送信します。既存の `debug` exporter も残しているため、ターミナルでも同じログを確認できます。

```bash
make collector-logs
make grafana-logs
```

## 困ったとき

|症状|確認・対処|
|---|---|
|Grafana にログインできない|`docker compose ps grafana` を確認。既存 volume では環境変数でパスワードを上書きできないため、Grafana 画面で変更する。|
|Explore にログが出ない|API を呼び出した後、期間選択を確認してから再実行する。`make collector-logs` で Collector がログを読めているか確認する。|
|Loki datasource のエラー|`make grafana-logs` を実行し、Loki が `Up` か確認する。|
|Collector が起動しない|`docker compose logs collector collector-init` を確認する。`collector-init` の `Exited (0)` はエラーではない。|

## 参考

- [Grafana Explore](https://grafana.com/docs/grafana/latest/explore/)
- [Loki LogQL](https://grafana.com/docs/loki/latest/query/)
- [Loki へ OpenTelemetry Collector からログを送る](https://grafana.com/docs/loki/latest/send-data/otel/)
