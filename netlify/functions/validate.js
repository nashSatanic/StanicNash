import { getStore } from "@netlify/blobs";

exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers: corsHeaders() };
  }
  if (event.httpMethod !== 'POST') return { statusCode: 405 };

  try {
    const { key, hwid } = JSON.parse(event.body);
    if (!key || !hwid) {
      return { statusCode: 200, headers: corsHeaders(), body: JSON.stringify({ valid: false, message: "Parámetros incompletos" }) };
    }

    const store = getStore("nash_keys");
    const keyData = await store.getJSON(key);

    if (!keyData) {
      return { statusCode: 200, headers: corsHeaders(), body: JSON.stringify({ valid: false, message: "Key inválida o inexistente" }) };
    }

    if (keyData.expiresAt && Date.now() > keyData.expiresAt) {
      return { statusCode: 200, headers: corsHeaders(), body: JSON.stringify({ valid: false, message: "La key ha expirado" }) };
    }

    if (keyData.hwid && keyData.hwid !== hwid) {
      return { statusCode: 200, headers: corsHeaders(), body: JSON.stringify({ valid: false, message: "Key vinculada a otro dispositivo (HWID mismatch)" }) };
    }

    if (!keyData.hwid) {
      keyData.hwid = hwid;
      await store.setJSON(key, keyData);
    }

    return { statusCode: 200, headers: corsHeaders(), body: JSON.stringify({ valid: true, message: "Acceso concedido" }) };
  } catch (e) {
    return { statusCode: 500, headers: corsHeaders(), body: JSON.stringify({ valid: false, message: "Error interno" }) };
  }
};

function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS"
  };
}