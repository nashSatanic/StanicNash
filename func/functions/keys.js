import { getStore } from "@netlify/blobs";

const checkAuth = (headers) => {
  const auth = headers.authorization || "";
  return auth === "Bearer nash_owner_authenticated_token";
};

exports.handler = async (event) => {
  if (!checkAuth(event.headers)) {
    return { statusCode: 401, body: JSON.stringify({ error: "Unauthorized" }) };
  }

  const store = getStore("nash_keys");

  if (event.httpMethod === 'GET') {
    const { blobs } = await store.list();
    const keys = [];
    for (const b of blobs) {
      const data = await store.getJSON(b.key);
      keys.push({ key: b.key, ...data });
    }
    return { statusCode: 200, body: JSON.stringify({ keys }) };
  }

  if (event.httpMethod === 'POST') {
    const body = JSON.parse(event.body);
    
    if (body.action === 'create') {
      const part = () => Math.random().toString(36).substring(2, 6).toUpperCase();
      const newKey = `NASH-${part()}-${part()}-${part()}`;
      const days = body.days || 30;
      const expiresAt = Date.now() + (days * 24 * 60 * 60 * 1000);

      await store.setJSON(newKey, {
        hwid: null,
        expiresAt,
        created: Date.now()
      });
      return { statusCode: 200, body: JSON.stringify({ success: true, key: newKey }) };
    }

    if (body.action === 'reset') {
      const keyData = await store.getJSON(body.key);
      if (keyData) {
        keyData.hwid = null;
        await store.setJSON(body.key, keyData);
        return { statusCode: 200, body: JSON.stringify({ success: true }) };
      }
    }

    if (body.action === 'delete') {
      await store.delete(body.key);
      return { statusCode: 200, body: JSON.stringify({ success: true }) };
    }
  }

  return { statusCode: 400 };
};