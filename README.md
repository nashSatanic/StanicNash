# Nash.exe — Vault API & Voice Panel

Sistema de licencias (key system) + panel de voz para Roblox, desplegado en Netlify.

## Estructura

```
Satanic_Nash/
├── public/                    # Sitio estático (Netlify publish)
│   ├── index.html             # Login de owner
│   └── dashboard.html         # Panel de gestión de keys
├── func/functions/            # Netlify Functions (API)
│   ├── auth.js                # POST /.func/functions/auth      - login owner
│   ├── keys.js                # GET/POST /.func/functions/keys  - CRUD de keys
│   └── validate.js            # POST /.func/functions/validate  - validación key + HWID
├── satanic.lua                # Script de Roblox (ejecutor)
├── server.js                  # Servidor local de desarrollo (opcional)
├── netlify.toml               # Config de build de Netlify
└── package.json
```

## Despliegue en Netlify

1. Sube este repositorio a GitHub.
2. En Netlify: **New site from Git** → selecciona el repo.
3. Build settings se detectan automáticamente desde `netlify.toml`:
   - Publish directory: `public`
   - Functions: `func/functions`
4. Configura variables de entorno:

   | Variable | Descripción |
   |----------|-------------|
   | `OWNER_SECRET` | Contraseña del login de owner |

5. Deploy.

## API Endpoints (Netlify Functions)

| Método | Ruta | Uso |
|--------|------|-----|
| `POST` | `/.func/functions/validate` | Validar key + vincular HWID (Lua) |
| `GET`  | `/.func/functions/keys` | Listar keys (dashboard) |
| `POST` | `/.func/functions/keys` | Crear / resetear / eliminar keys |
| `POST` | `/.func/functions/auth` | Login de owner |

## Configurar el script Lua

En `satanic.lua` línea 38, reemplaza `TU-SITIO` con tu dominio de Netlify:

```lua
local API_BASE = "https://tu-sitio.netlify.app/.func/functions"
```

El script hace un health check a la API cada 30 segundos y valida la key contra el endpoint `/validate`.

## Uso local (opcional)

```bash
npm install
npm start
```

Servidor local en `http://localhost:3000` solo para desarrollo (usa `keys.json` como base de datos).
