# Instructivo de instalación

Cómo dejar el bot funcionando desde cero, en una máquina donde no hay nada instalado.
Está pensado para alguien que no participó del desarrollo.

Para usarlo una vez instalado, ver el [instructivo de uso](instructivo-uso.md).

---

## Qué vas a necesitar

1. **TagUI** — la herramienta de RPA que ejecuta el programa.
2. **Un bot de Telegram** — con su token y el chat_id a dónde mandar los mensajes.
3. **Este repositorio** descargado.

No hace falta instalar Microsoft Excel ni ningún otro programa: los datos se leen de
archivos `.csv` como texto plano, justamente para que funcione igual en cualquier sistema.

---

## Paso 1 — Instalar TagUI

### Windows

1. Descargá TagUI desde las releases oficiales:
   https://github.com/aisingapore/TagUI/releases
   (el archivo para Windows, `TagUI_Windows.zip`)
2. Descomprimilo en `C:\tagui`.
   Te tiene que quedar existiendo la carpeta `C:\tagui\src`.
3. Agregá `C:\tagui\src` al **PATH** del sistema, para poder escribir `tagui` desde
   cualquier carpeta:
   - Menú Inicio → "Editar las variables de entorno del sistema"
   - Botón *Variables de entorno* → en *Variables del sistema*, seleccioná `Path` → *Editar*
   - *Nuevo* → pegá `C:\tagui\src` → Aceptar en todas las ventanas
   - **Cerrá y volvé a abrir la terminal** para que tome el cambio.
4. Verificá que quedó bien. Abrí una terminal nueva y escribí:
   ```
   tagui
   ```
   Tiene que responder con la ayuda de TagUI. Si dice "no se reconoce el comando",
   el PATH no quedó bien cargado.

> **PHP en Windows:** no hace falta instalarlo. TagUI trae su propia copia adentro
> (`C:\tagui\src\php\php.exe`) y la usa automáticamente.

### Linux

1. **Instalá PHP primero.** En Linux, a diferencia de Windows, TagUI **no** trae PHP
   incluido: lo busca en el sistema. Si falta, TagUI falla con errores confusos.
   ```bash
   sudo apt update && sudo apt install php-cli
   ```
   (en Fedora/RHEL: `sudo dnf install php-cli`)

   Verificá con:
   ```bash
   php --version
   ```

2. Descargá y descomprimí TagUI:
   ```bash
   cd ~
   wget https://github.com/aisingapore/TagUI/releases/latest/download/TagUI_Linux.zip
   unzip TagUI_Linux.zip
   ```
   Te tiene que quedar la carpeta `~/tagui/src`.

3. Agregá TagUI al PATH:
   ```bash
   echo 'export PATH=$PATH:~/tagui/src' >> ~/.bashrc
   source ~/.bashrc
   ```

4. Verificá:
   ```bash
   tagui
   ```

> **Nota honesta:** la instalación en Linux **todavía no se probó** en este proyecto
> (está pendiente como ítem 7 del checklist en [`contexto.md`](../contexto.md)). Los pasos son los del
> procedimiento oficial de TagUI más el requisito de PHP, que sí está confirmado leyendo
> el código del launcher. Si al correrlo aparecen errores de PhantomJS relacionados a
> librerías gráficas, puede llegar a hacer falta `sudo apt install libfontconfig1`.
> **Cuando alguien lo pruebe en Linux, actualizar esta sección con lo que realmente pasó.**

---

## Paso 2 — Crear el bot de Telegram

### 2.1 — Crear el bot y obtener el TOKEN

1. Abrí Telegram y buscá el contacto **@BotFather** (es el bot oficial de Telegram).
2. Mandale `/newbot`.
3. Te va a pedir dos cosas:
   - un **nombre** para el bot (cualquiera, ej: `Compras Grupo 13`)
   - un **username**, que tiene que terminar en `bot` (ej: `ComprasGrupo13_bot`)
4. Cuando termine, BotFather te responde con el **token**. Es una cadena larga con dos
   partes separadas por dos puntos, así:
   ```
   1234567890:AAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```
   Guardalo: es la contraseña del bot. **No lo compartas ni lo subas al repositorio.**

> 📸 *Sacar acá una captura de la conversación con BotFather (tapando el token) para
> incluir en el entregable.*

### 2.2 — Obtener el CHAT_ID

El chat_id es a dónde el bot va a mandar los mensajes.

**Importante:** un bot de Telegram **no puede escribirte primero**. Tenés que hablarle
vos antes, o el envío va a fallar con `chat not found`.

**Para mandarte los mensajes a vos mismo:**

1. Buscá tu bot en Telegram por el username que le pusiste y mandale cualquier mensaje
   (por ejemplo `hola`).
2. Abrí esta dirección en el navegador, reemplazando `<TOKEN>` por tu token:
   ```
   https://api.telegram.org/bot<TOKEN>/getUpdates
   ```
3. Vas a ver un texto en formato JSON. Buscá `"chat":{"id":` — ese número es tu chat_id.

**Para mandarlos a un grupo:**

1. Agregá el bot al grupo.
2. Escribí cualquier mensaje **en el grupo**.
3. Abrí la misma dirección `getUpdates` y buscá el `id` del chat cuyo `"type"` sea
   `"group"` o `"supergroup"`.
4. El id de un grupo es **negativo** y suele empezar con `-100`
   (ej: `-1001234567890`). Copialo entero, con el signo menos.

> 📸 *Sacar acá una captura del resultado de `getUpdates` (tapando el token) para el
> entregable.*

---

## Paso 3 — Descargar el proyecto y configurarlo

1. Cloná o descargá este repositorio.

2. En la carpeta raíz del proyecto vas a encontrar `config.ejemplo.txt`.
   **Copialo y renombrá la copia como `config.txt`**, en la misma carpeta.

   ```bash
   # Linux / macOS
   cp config.ejemplo.txt config.txt
   ```
   ```
   rem Windows
   copy config.ejemplo.txt config.txt
   ```

3. Abrí `config.txt` con cualquier editor de texto y completá tus datos:
   ```
   TELEGRAM_TOKEN=1234567890:AAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   TELEGRAM_CHAT_ID=1234567890
   ```
   Sin espacios alrededor del `=` y sin comillas.

> **Por qué `config.txt` está separado del código:** las credenciales del bot no se
> suben al repositorio (`config.txt` está en `.gitignore`). Así cada integrante del
> grupo usa su propio bot sin pisarle la configuración a los demás, y el token no queda
> guardado para siempre en el historial de git.

---

## Paso 4 — Verificar que quedó todo bien

Parado en la carpeta raíz del proyecto, corré la prueba de conexión.
**Esta prueba no le manda un mensaje a nadie**, solo comprueba que el token sirva:

```
tagui pruebas/prueba_conexion.tag -n
```

Tiene que responder algo así:

```
OK - el token es valido. Bot: @ComprasGrupo13_bot
```

Después probá un envío real:

```
tagui pruebas/prueba_telegram.tag -n
```

Te va a preguntar el chat_id (Enter para usar el de `config.txt`) y el texto.
Si te llega el mensaje a Telegram, la instalación está terminada.

> 📸 *Sacar acá una captura del mensaje llegando a Telegram para el entregable.*

---

## Errores comunes en la instalación

| Qué ves | Qué pasa |
|---|---|
| `tagui` no se reconoce como comando | TagUI no quedó en el PATH, o no cerraste y volviste a abrir la terminal después de agregarlo. |
| `Unauthorized` en la prueba de conexión | El token de `config.txt` está mal copiado, o lo revocaste en BotFather. Copialo entero, incluyendo la parte antes de los dos puntos. |
| `chat not found` al enviar | El chat_id está mal, **o nunca le hablaste al bot**. Mandale un mensaje al bot y volvé a sacar el chat_id con `getUpdates`. |
| La respuesta de Telegram viene vacía `[]` | Se borró de algún `.tag` la línea de comentario que contiene el texto `api http`. Está explicado en [`contexto.md`](../contexto.md) y en el encabezado de cada script: esa línea es obligatoria. |
| Se abre una ventana de Chrome con un cartelito preguntando | Ejecutaste sin el flag `-n`. Agregalo, o usá los lanzadores `compras.cmd` / `compras.sh`. |
| `cannot find file ../data/...` | Se movió un archivo de lugar. TagUI resuelve las rutas relativas **respecto de dónde está el `.tag`**, no desde dónde ejecutás. Los scripts esperan la estructura de carpetas original. |
| (Linux) errores raros de PHP o de parseo | Falta instalar `php-cli`. Ver el Paso 1. |
