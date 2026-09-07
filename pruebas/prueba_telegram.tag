// prueba_telegram.tag
// Prueba SOLO el envio por Telegram, sin correr todo el calculo de compras.
// Sirve para verificar rapido que el token y el chat_id andan, y para probar
// contra el id de un GRUPO sin tener que tocar config.txt ni compras.tag.
//
// COMO SE EJECUTA
//   Windows:  tagui pruebas\prueba_telegram.tag -n
//   Linux:    tagui pruebas/prueba_telegram.tag -n
//
// api http  <- NO BORRAR (explicacion completa en Ejecutables/compras.tag)
//
// NOTA: el parseo de config.txt esta repetido aca a proposito. TagUI no tiene
// ningun mecanismo de include/import entre archivos .tag, asi que no hay forma
// de compartir codigo entre flujos sin duplicarlo.

load ../config.txt to config_texto
lineas_config = config_texto.split(/\r?\n/)

TELEGRAM_TOKEN = ""
TELEGRAM_CHAT_ID = ""

for i from 0 to lineas_config.length-1
  linea_cfg = lineas_config[i].trim()
  if linea_cfg.indexOf("=") > 0
    pos_igual = linea_cfg.indexOf("=")
    clave = linea_cfg.substring(0, pos_igual).trim()
    valor = linea_cfg.substring(pos_igual + 1).trim()
    if clave equals to "TELEGRAM_TOKEN"
      TELEGRAM_TOKEN = valor
    if clave equals to "TELEGRAM_CHAT_ID"
      TELEGRAM_CHAT_ID = valor

echo ===============================================
echo   PRUEBA DE ENVIO POR TELEGRAM
echo ===============================================
aviso_chat = "El chat_id de config.txt es: " + TELEGRAM_CHAT_ID
echo `aviso_chat`
echo Para probar contra un grupo, pega aca el id del grupo (empieza con -100).
echo -----------------------------------------------

ask Chat id a usar (Enter = el de config.txt):
chat_destino = ask_result.trim()
if chat_destino equals to ""
  chat_destino = TELEGRAM_CHAT_ID

ask Texto del mensaje (Enter = mensaje por defecto):
texto = ask_result.trim()
if texto equals to ""
  texto = "Prueba de envio del bot de compras - Grupo 13"

texto_codificado = encodeURIComponent(texto)
url_envio = "https://api.telegram.org/bot" + TELEGRAM_TOKEN + "/sendMessage?chat_id=" + chat_destino + "&text=" + texto_codificado

api `url_envio`

envio_ok = 0
if api_result.length > 0
  if api_json.ok equals to true
    envio_ok = 1

echo -----------------------------------------------
if envio_ok equals to 1
  resultado = "OK - mensaje enviado al chat " + chat_destino
  echo `resultado`
else
  echo FALLO el envio. Respuesta cruda de Telegram:
  echo `api_result`
  echo -----------------------------------------------
  echo Errores comunes:
  echo   "chat not found"       -> el chat_id esta mal, o el bot nunca hablo con ese chat
  echo   "bot was blocked"      -> el usuario bloqueo al bot
  echo   "Unauthorized"         -> el token esta mal o fue revocado en BotFather
  echo   respuesta vacia []     -> falta la linea "api http" en los comentarios
