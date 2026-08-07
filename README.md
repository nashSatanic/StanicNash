# Nash.exe — Vault API & Voice Panel

Sistema de licencias (key system) + panel de voz para Roblox.
Frontend estático en **GitHub Pages** + backend de API en **Netlify Functions**.

## Arquitectura

```
Satanic_Nash/
├── index.html              # Panel de owner (GitHub Pages) — raíz del repo
├── dashboard.html          # Panel alternativo de gestión (GitHub Pages)
├── satanic.lua             # Script de Roblox (ejecutor)
├── func/functions/         # Backend API (Netlify Functions, desplegado en Netlify)
│   ├── auth.js             # POST /.func/functions/auth      - login owner
│   ├── keys.js             # GET/POST /.func/functions/keys  - CRUD de keys
│   └── validate.js         # POST /.func/functions/validate  - validación key + HWID
├── netlify.toml            # Config de Netlify (functions + CORS)
├── server.js               # Servidor local de desarrollo (opcional)
└── package.json
```

## Despliegue

### 1. GitHub Pages (frontend)
- `index.html` y `dashboard.html` están en la **raíz** del repo, así que GitHub Pages los sirve directamente.
- En Settings → Pages → Source: `Deploy from a branch` → `main` / root `/`.

### 2. Netlify Functions (backend / API)
1. En Netlify: **New site from Git** → selecciona este repo.
2. La configuración se lee de `netlify.toml` (functions dir: `func/functions`).
3. Configura variable de entorno:

   | Variable | Descripción |
   |----------|-------------|
   | `OWNER_SECRET` | Contraseña de auth (fallback `nash1234`) |

4. Deploy.

### 3. Conectar frontend al backend
En `index.html`, `dashboard.html` (constante `API_BASE`) **y en `satanic.lua`** (línea 38), reemplaza `TU-SITIO` por tu dominio Netlify:

```js
const API_BASE = 'https://tu-sitio.netlify.app/.func/functions';
```

```lua
local API_BASE = "https://tu-sitio.netlify.app/.func/functions"
```

## API Endpoints (Netlify Functions)

| Método | Ruta | Uso |
|--------|------|-----|
| `POST` | `/.func/functions/validate` | Validar key + vincular HWID (Lua) |
| `GET`  | `/.func/functions/keys` | Listar keys (dashboard) |
| `POST` | `/.func/functions/keys` | Crear / resetear / eliminar keys |
| `POST` | `/.func/functions/auth` | Login de owner |

El CORS está habilitado en `netlify.toml` para permitir que el frontend (GitHub Pages) consuma las funciones desde cualquier origen.

## Script Lua

`Satanic.lua` hace un health check a la API cada 30 segundos y valida la key contra el endpoint `/validate`. El key system está centrado, acepta solo Enter, y no muestra la URL del backend.

## Uso local (opcional)

```bash
npm install
npm start
```

` server.js` corre en `http://localhost:3000` solo para desarrollo (usa `keys.json`).