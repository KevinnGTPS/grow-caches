export default async function handler(req, res) {
  const r = await fetch("http://178.128.111.175:8081", {
    method: req.method,
    headers: { 'Content-Type': 'application/json' },
    body: req.method === 'POST' ? JSON.stringify(req.body) : undefined
  });

  const data = await r.text();
  res.status(r.status).send(data);
}
