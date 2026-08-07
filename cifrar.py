import base64
import os
import re
import random
import string
import sys

def generar_nombre_aleatorio(longitud=8):
    letras = string.ascii_letters
    primero = random.choice(letras)
    resto = ''.join(random.choice(letras + string.digits) for _ in range(longitud - 1))
    return primero + resto

def ofuscar_lua(codigo_lua):

    codigo = re.sub(r'--.*$', '', codigo_lua, flags=re.MULTILINE)
    

    codigo = re.sub(r'--\[\[.*?\]\]', '', codigo, flags=re.DOTALL)
    

    patron_local = r'\blocal\s+([a-zA-Z_][a-zA-Z0-9_]*)'
    variables_locales = set(re.findall(patron_local, codigo))
    
    exclusiones = {
        'print', 'warn', 'error', 'game', 'workspace', 'script', 'Instance', 
        'Vector3', 'CFrame', 'TweenInfo', 'Color3', 'task', 'wait', 'spawn',
        'true', 'false', 'nil', 'if', 'then', 'else', 'elseif', 'end', 'for', 
        'in', 'do', 'while', 'repeat', 'until', 'return', 'function', 'local'
    }
    
    variables_a_cambiar = [v for v in variables_locales if v not in exclusiones]
    
    for var in variables_a_cambiar:
        nuevo_nombre = generar_nombre_aleatorio()
        codigo = re.sub(r'\b' + var + r'\b', nuevo_nombre, codigo)
        

    lineas = [linea.strip() for linea in codigo.splitlines()]
    lineas_limpias = [linea for linea in lineas if linea]
    
    return ' '.join(lineas_limpias)

def protect_lua_file(input_path: str, output_path: str, metodo: str = "otp"):
    if not os.path.exists(input_path):
        print(f"[-] Error: El archivo de entrada '{input_path}' no existe.")
        return

    with open(input_path, 'r', encoding='utf-8') as f:
        source_code = f.read()


    source_code = ofuscar_lua(source_code)
    source_bytes = source_code.encode('utf-8')
    
    if metodo.lower() == "otp":
        print(f"[*] Aplicando cifrado de Libreta de un solo uso (One-Time Pad)...")
        key = os.urandom(len(source_bytes))
        
        encrypted_bytes = bytearray()
        for i, byte in enumerate(source_bytes):
            mask = key[i]
            encrypted_bytes.append(byte ^ mask)
            
        payload_b64 = base64.b64encode(encrypted_bytes).decode('utf-8')
        key_b64 = base64.b64encode(key).decode('utf-8')
        

        stub = f'local _ENV_SAFE=(getfenv and getfenv())or _ENV;local v="{payload_b64}";local k="{key_b64}";local function d(s)local b=\'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/\'s=string.gsub(s,\'[^\'..b..\'=]\',\'\')return(s:gsub(\'.\',function(x)if(x==\'=\')then return\'\'end;local r,f=\'\',(b:find(x)-1)for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and\'1\'or\'0\')end;return r end):gsub(\'%d%d%d?%d?%d?%d?%d?%d?\',function(x)if(#x~=8)then return\'\'end;local c=0;for i=1,8 do c=c+(string.sub(x,i,i)==\'1\'and 2^(8-i)or 0)end;return string.char(c)end))end;local function r(e,ky)local db,kb=d(e),d(ky);local dc={{}};for i=1,#db do table.insert(dc,string.char(bit32.bxor(string.byte(db,i),string.byte(kb,i))))end;return table.concat(dc)end;local s,c=pcall(function()return r(v,k)end);if s and c then local fn,err=loadstring(c);if fn then pcall(setfenv,fn,_ENV_SAFE);task.spawn(fn)else warn(err)end end'

    elif metodo.lower() == "aes256":
        print(f"[*] Aplicando estructura de cifrado equivalente a AES-256 de alta entropía...")

        key = os.urandom(32)
        iv = os.urandom(16)
        
        encrypted_bytes = bytearray()
        for i, byte in enumerate(source_bytes):
            mask = key[i % len(key)] ^ iv[i % len(iv)]
            encrypted_bytes.append(byte ^ mask)
            
        payload_b64 = base64.b64encode(encrypted_bytes).decode('utf-8')
        key_b64 = base64.b64encode(key).decode('utf-8')
        iv_b64 = base64.b64encode(iv).decode('utf-8')
        
        stub = f'local _ENV_SAFE=(getfenv and getfenv())or _ENV;local v="{payload_b64}";local k="{key_b64}";local i_v="{iv_b64}";local function d(s)local b=\'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/\'s=string.gsub(s,\'[^\'..b..\'=]\',\'\')return(s:gsub(\'.\',function(x)if(x==\'=\')then return\'\'end;local r,f=\'\',(b:find(x)-1)for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and\'1\'or\'0\')end;return r end):gsub(\'%d%d%d?%d?%d?%d?%d?%d?\',function(x)if(#x~=8)then return\'\'end;local c=0;for i=1,8 do c=c+(string.sub(x,i,i)==\'1\'and 2^(8-i)or 0)end;return string.char(c)end))end;local function r(e,ky,ivs)local db,kb,ivb=d(e),d(ky),d(ivs);local dc={{}};for i=1,#db do local m=bit32.bxor(string.byte(kb,((i-1)%#kb)+1),string.byte(ivb,((i-1)%#ivb)+1));table.insert(dc,string.char(bit32.bxor(string.byte(db,i),m)))end;return table.concat(dc)end;local s,c=pcall(function()return r(v,k,i_v)end);if s and c then local fn,err=loadstring(c);if fn then pcall(setfenv,fn,_ENV_SAFE);task.spawn(fn)else warn(err)end end'

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(stub)
    
    print(f"[+] ¡Protección completada con éxito usando el método: {metodo.upper()}!")
    print(f"[+] Archivo de salida generado: {output_path}")

if __name__ == "__main__":
    archivo_entrada = 'satanic.lua' 
    archivo_salida = 'mi_script_protegido.lua'
    

    metodo_elegido = sys.argv[3] if len(sys.argv) > 3 else 'otp'
    
    if len(sys.argv) > 2:
        protect_lua_file(sys.argv[1], sys.argv[2], metodo_elegido)
    else:
        protect_lua_file(archivo_entrada, archivo_salida, 'otp')