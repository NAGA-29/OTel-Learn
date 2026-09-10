import React from 'react';
import ReactDOM from 'react-dom/client';
import './style.css';

type Supplier = {id: number; name: string; email: string};

function App() {
  const [suppliers, setSuppliers] = React.useState<Supplier[]>([]);
  const [selected, setSelected] = React.useState<Supplier | null>(null);
  const [name, setName] = React.useState('');
  const [email, setEmail] = React.useState('');
  const [error, setError] = React.useState('');
  const [deletingId, setDeletingId] = React.useState<number | null>(null);
  const selectedRequest = React.useRef(0);

  const load = React.useCallback(async () => {
    const response = await fetch('/api/suppliers');
    const json = await response.json();
    setSuppliers(json.data);
  }, []);

  React.useEffect(() => { load().catch((e) => setError(String(e))); }, [load]);

  async function show(id: number) {
    const request = ++selectedRequest.current;
    const response = await fetch(`/api/suppliers/${id}`);
    const json = await response.json();
    if (request === selectedRequest.current) setSelected(json.data);
  }

  async function create(event: React.FormEvent) {
    event.preventDefault();
    setError('');
    const response = await fetch('/api/suppliers', {
      method: 'POST',
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: JSON.stringify({name, email}),
    });
    if (!response.ok) {
      setError(`作成に失敗しました (${response.status})`);
      return;
    }
    setName(''); setEmail('');
    await load();
  }

  async function remove(supplier: Supplier) {
    if (!window.confirm(`「${supplier.name}」を削除しますか？`)) return;

    setError('');
    selectedRequest.current += 1;
    setDeletingId(supplier.id);
    try {
      const response = await fetch(`/api/suppliers/${supplier.id}`, {
        method: 'DELETE',
        headers: {'Accept': 'application/json'},
      });
      if (!response.ok) {
        setError(`削除に失敗しました (${response.status})`);
        return;
      }
      if (selected?.id === supplier.id) setSelected(null);
      await load();
    } catch (e) {
      setError(String(e));
    } finally {
      setDeletingId(null);
    }
  }

  return <main>
    <header><p>Framework-independent logging pipeline</p><h1>Supplier Demo</h1></header>
    {error && <p className="error">{error}</p>}
    <section>
      <h2>Supplier一覧</h2>
      <ul>{suppliers.map((supplier) => <li key={supplier.id}>
        <button onClick={() => show(supplier.id)}>{supplier.name}</button>
        <span>{supplier.email}</span>
        <button className="danger" onClick={() => remove(supplier)} disabled={deletingId !== null}>
          {deletingId === supplier.id ? '削除中…' : '削除'}
        </button>
      </li>)}</ul>
    </section>
    <section>
      <h2>Supplier詳細</h2>
      {selected ? <dl><dt>ID</dt><dd>{selected.id}</dd><dt>Name</dt><dd>{selected.name}</dd><dt>Email</dt><dd>{selected.email}</dd></dl> : <p>一覧から選択してください。</p>}
    </section>
    <section>
      <h2>Supplier作成</h2>
      <form onSubmit={create}>
        <label>Name<input value={name} onChange={(e) => setName(e.target.value)} required /></label>
        <label>Email<input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required /></label>
        <button type="submit">作成</button>
      </form>
    </section>
  </main>;
}

ReactDOM.createRoot(document.getElementById('root')!).render(<React.StrictMode><App /></React.StrictMode>);
