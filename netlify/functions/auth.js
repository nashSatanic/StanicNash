const corsHeaders = () => ({
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS"
});

exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') return { statusCode: 204, headers: corsHeaders() };
  if (event.httpMethod !== 'POST') return { statusCode: 405 };

  try {
    const { secret } = JSON.parse(event.body);
    const expected = process.env.OWNER_SECRET || "nash1234";
    const token = process.env.OWNER_TOKEN || "nash_owner_token";

    if (secret === expected) {
      return { statusCode: 200, headers: corsHeaders(), body: JSON.stringify({ token }) };
    }
    return { statusCode: 401, headers: corsHeaders(), body: JSON.stringify({ error: "Unauthorized" }) };
  } catch (e) {
    return { statusCode: 500 };
  }
};