# Nash.exe — Vault Key System & Voice Panel

Sistema de licencias (key system) + panel de voz para Roblox.
**100% estático, desplegado en GitHub Pages** — sin servidor ni backend externo.

## Estructura

```
Satanic_Nash/
├── index.html        # Panel de owner (gestión de keys)
├── dashboard.html    # Panel alternativo
├── keys.json         # Base de datos de keys (archivo estático)
├── satanic.lua       # Script de Roblox (ejecutor)
└── README.md
```

## Cómo funciona

GitHub Pages sirve archivos estáticos. Las keys viven en `keys.json` (en la raíz del repo).
La web y el script de Roblox leen ese archivo para validar.

- **Editar keys**: modifica `keys.json` y haz push → se actualiza el sitio y la validación.
- **Script Lua**: `satanic.lua` descarga `keys.json` cada 30 s y valida la key localmente.

## Despliegue

1. Sube el repo a GitHub.
2. En **Settings → Pages**: Source → `Deploy from a branch` → `main` / root `/`.
3. El sitio queda en `https://TU-USUARIO.github.io/TU-REPO/`.

> Aviso de seguridad: al ser código abierto (estático), `keys.json` es visible para cualquiera. Esto es válido para uso personal/demo. Para proteger llaves de venta real necesitarás un backend privado.

## Configurar el script Lua

En `satanic.lua` (línea 38) la URL debe apuntar a tu GitHub Pages:

```lua
local API_BASE = "https://TU-USUARIO.github.io/TU-REPO"
```

## keys.json

```json
{
  "keys": [
    { "key": "STANIC-XXXX-XXXX-XXXX", "hwid": null, "expiresAt": 4102444800000 },
    { "key": "STANIC-YYYY-YYYY-YYYY", "hwid": null, "expiresAt": null }
  ]
}
```

- `hwid`: deja `null` para venderla nueva; se llena automáticamente al vincular al script.
- `expiresAt`: timestamp en ms (0 o `null` = sin límite).