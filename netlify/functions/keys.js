import { getStore } from "@netlify/blobs";

const corsHeaders = () => ({
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS"
});

const part = () => Math.random().toString(36).substring(2, 6).toUpperCase();
const genKey = () => part();

exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') return { statusCode: 204, headers: corsHeaders() };

  const store = getStore("nash_keys");

  if (event.httpMethod === 'GET') {
    const { blobs } = await store.list();
    const keys = [];
    for (const b of blobs) {
      const data = await store.getJSON(b.key);
      keys.push({ key: b.key, ...data });
    }
    return { statusCode: 200, headers: corsHeaders(), body: JSON.stringify({ keys }) };
  }

  if (event.httpMethod === 'POST') {
    const body = JSON.parse(event.body);

    // Crear key con tiempo de expiración
    if (body.action === 'create') {
      const newKey = `STANIC-${genKey()}-${genKey()}-${genKey()}`;
      const durationMs = body.durationMs || 0;
      const expiresAt = durationMs === 0 ? null : Date.now() + durationMs;

      await store.setJSON(newKey, {
        hwid: null,
        expiresAt,
        created: Date.now()
      });
      return { statusCode: 200, headers: corsHeaders(), body: JSON.stringify({ success: true, key: newKey, expiresAt }) };
    }

    if (body.action === 'reset') {
      const keyData = await store.getJSON(body.key);
      if (keyData) {
        keyData.hwid = null;
        await store.setJSON(body.key, keyData);
        return { statusCode: 200, headers: corsHeaders(), body: JSON.stringify({ success: true }) };
      }
    }

    if (body.action === 'delete') {
      await store.delete(body.key);
      return { statusCode: 200, headers: corsHeaders(), body: JSON.stringify({ success: true }) };
    }
  }

  return { statusCode: 400, headers: corsHeaders(), body: JSON.stringify({ error: "Bad request" }) };
};