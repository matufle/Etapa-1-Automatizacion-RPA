// prueba_conexion.tag
// Verifica que el token de config.txt sea valido, SIN mandarle un mensaje a
// nadie. Llama al metodo getMe de la Bot API, que solo devuelve los datos del
// bot. Es la primera prueba a correr cuando algo no anda.
//
// COMO SE EJECUTA
//   Windows:  tagui pruebas\prueba_conexion.tag -n
//   Linux:    tagui pruebas/prueba_conexion.tag -n
//
// api http  <- NO BORRAR (explicacion completa en Ejecutables/compras.tag)

load ../config.txt to config_texto
lineas_config = config_texto.split(/\r?\n/)

TELEGRAM_TOKEN = ""

for i from 0 to lineas_config.length-1
  linea_cfg = lineas_config[i].trim()
  if linea_cfg.indexOf("=") > 0
    pos_igual = linea_cfg.indexOf("=")
    clave = linea_cfg.substring(0, pos_igual).trim()
    valor = linea_cfg.substring(pos_igual + 1).trim()
    if clave equals to "TELEGRAM_TOKEN"
      TELEGRAM_TOKEN = valor

echo ===============================================
echo   PRUEBA DE CONEXION CON TELEGRAM (no envia nada)
echo ===============================================

url_getme = "https://api.telegram.org/bot" + TELEGRAM_TOKEN + "/getMe"
api `url_getme`

conexion_ok = 0
if api_result.length > 0
  if api_json.ok equals to true
    conexion_ok = 1

if conexion_ok equals to 1
  resultado = "OK - el token es valido. Bot: @" + api_json.result.username
  echo `resultado`
else
  echo FALLO. Respuesta cruda de Telegram:
  echo `api_result`
  echo -----------------------------------------------
  echo Si la respuesta es "Unauthorized", el token de config.txt esta mal.
  echo Si la respuesta vino vacia [], falta la linea "api http" en los comentarios.
