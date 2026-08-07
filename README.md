# Nash.exe — Key System & Voice Panel (Netlify)

Sistema de licencias (key system) + panel de voz para Roblox. Web y API desplegadas juntas en **Netlify** (se sube a GitHub y de ahí se importa a Netlify).

## Estructura

```
Satanic_Nash/
├── public/                     # Sitio web (frontend)
│   ├── index.html              # Panel: generar key por tiempo / ver HWID / reset / delete
│   └── dashboard.html          # Panel alternativo (días)
├── netlify/functions/          # Backend API (Netlify Functions)
│   ├── validate.js             # Validación key + HWID (usada por el script Lua)
│   ├── keys.js                 # CRUD de keys (listar, crear por tiempo, reset HWID, eliminar)
│   └── auth.js                 # Login de owner
├── satanic.lua                 # Script de Roblox
├── netlify.toml                # Config de build + CORS
└── package.json
```

## Despliegue

1. Sube este repo a GitHub.
2. En Netlify: **Add new site → Import an existing project** → selecciona el repo.
3. Se detecta automáticamente:
   - Publish directory: `public`
   - Functions: `netlify/functions`
4. Configura variables de entorno:

   | Variable | Descripción | Default |
   |----------|-------------|---------|
   | `OWNER_SECRET` | Contraseña del login de owner | `nash1234` |
   | `OWNER_TOKEN` | Token que firma el dashboard | `nash_owner_token` |

5. Deploy.

> Cambia ambas variables para que no queden en los valores por defecto.

## API Endpoints

| Método | Ruta | Autent. | Descripción |
|--------|------|---------|-------------|
| `POST` | `/.netlify/functions/validate` | no | Valida key + vincula HWID (script Lua) |
| `GET`  | `/.netlify/functions/keys` | Bearer token | Lista keys |
| `POST` | `/.netlify/functions/keys` | Bearer token | `action: create/reset/delete` |
| `POST` | `/.netlify/functions/auth` | no | Login owner (secret → token) |

### Crear key con duración
```json
POST /.netlify/functions/keys
{ "action": "create", "duration": 86400000 }   // 0 = permanente
```

## Configurar el script Lua

`Satanic.lua` valida contra el backend. Reemplaza `TU-SITIO` con tu dominio Netlify:

```lua
local API_BASE = "https://tu-sitio.netlify.app/.netlify/functions"
```

El script:
- Hace health check contra `/validate` cada 30 s.
- Valida la key + HWID contra el backend (y vincula el dispositivo).
- Key system centrado, acepta solo Enter, no muestra la URL.

## Notas

- El frontend y el API viven en el mismo dominio de Netlify, así que el dashboard usa rutas relativas (`/.netlify/functions/...`) y no hay problemas de CORS para la web.
- CORS abierto (`*`) para `/.netlify/functions/*` permite que el script de Roblox consuma `/validate` desde cualquier origen.