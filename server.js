const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const PORT = 3000;
const KEYS_FILE = path.join(__dirname, 'keys.json');

let db = {};
try { db = JSON.parse(fs.readFileSync(KEYS_FILE, 'utf8')); } catch (e) { db = {}; }
const save = () => fs.writeFileSync(KEYS_FILE, JSON.stringify(db, null, 2));

const ALPHA = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
const rand = n => { const b = crypto.randomBytes(n); let s = ''; for (let i = 0; i < n; i++) s += ALPHA[b[i] % ALPHA.length]; return s; };
const genKey = () => 'STANIC-' + rand(4) + '-' + rand(4) + '-' + rand(4);

function readBody(req) {
  return new Promise(resolve => {
    let data = '';
    req.on('data', c => data += c);
    req.on('end', () => { try { resolve(JSON.parse(data)); } catch (e) { resolve({}); } });
  });
}

http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', '*');
  res.setHeader('Access-Control-Allow-Methods', '*');
  if (req.method === 'OPTIONS') { res.writeHead(204); res.end(); return; }

  const url = req.url.split('?')[0];

  if (req.method === 'GET' && url === '/') {
    const htmlPath = path.join(__dirname, 'index.html');
    if (fs.existsSync(htmlPath)) {
      res.writeHead(200, { 'Content-Type': 'text/html' });
      res.end(fs.readFileSync(htmlPath, 'utf8'));
    } else {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('Falta el archivo index.html');
    }
  } else if (req.method === 'GET' && url === '/api/keys') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ keys: Object.keys(db).map(key => Object.assign({ key }, db[key])) }));
  } else if (req.method === 'POST' && url === '/api/generate') {
    const body = await readBody(req);
    const duration = body.duration || 86400000;
    const key = genKey();
    const expiresAt = duration === 0 ? null : Date.now() + duration;
    
    db[key] = { hwid: null, created: Date.now(), expiresAt };
    save();
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ key, expiresAt }));
  } else if (req.method === 'POST' && url === '/api/validate') {
    const body = await readBody(req);
    const entry = db[body.key];
    let valid = false;
    
    if (entry) {
      const now = Date.now();
      if (entry.expiresAt && now > entry.expiresAt) {
        valid = false;
      } else {
        if (!entry.hwid && body.hwid) entry.hwid = body.hwid;
        valid = !entry.hwid || entry.hwid === body.hwid;
        save();
      }
    }
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ valid }));
  } else if (req.method === 'POST' && url === '/api/revoke') {
    const body = await readBody(req);
    if (db[body.key]) {
      delete db[body.key]; // Elimina la key completamente de la base de datos
      save();
    }
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ ok: true }));
  } else if (req.method === 'POST' && url === '/api/reset-hwid') {
    const body = await readBody(req);
    if (db[body.key]) {
      db[body.key].hwid = null;
      save();
    }
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ ok: true }));
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'not found' }));
  }
}).listen(PORT, () => console.log('Nash Vault API en http://localhost:' + PORT));