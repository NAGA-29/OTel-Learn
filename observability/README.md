# Collector設定

`otel-collector.yaml` はAWSなしで正規化結果をdebug exporterへ出す。`otel-collector-s3.yaml` は同じ変換にS3 exporterと永続送信キューを追加する。

処理順は `redact → normalize → resource → batch`。秘密値を最初に落とし、アプリ固有JSONをOTel属性へ移し、サービス共通情報をResourceへ付け、最後にまとめて送る。`file_storage` はfilelogの読み取り位置とS3送信キューをDocker volumeへ保持する。

設定を更新したら次で起動確認する。

```bash
docker compose up collector
docker compose --profile aws up collector-s3
```

