// compras.tag
// Bot de gestion de inventario y compras de supermercado - Grupo 13
// TPI Tecnologias para la Automatizacion - UTN FRCU 2026
//
// QUE HACE
//   Pregunta que queres cocinar (una comida, varias, o el menu semanal
//   entero), busca los ingredientes en la base de recetas, les descuenta lo
//   que ya tenes en la alacena y te manda por Telegram la lista de lo que
//   falta comprar.
//
// COMO SE EJECUTA
//   Windows:  Ejecutables\compras.cmd     (o: tagui Ejecutables\compras.tag -n)
//   Linux:    ./Ejecutables/compras.sh    (o: tagui Ejecutables/compras.tag -n)
//
//   El -n (nobrowser) es OBLIGATORIO: hace que TagUI corra solo con su motor,
//   sin abrir Chrome. Sin -n, el paso `ask` abre un popup del navegador en vez
//   de preguntar por consola (ver tagui_parse.php linea 997).
//
// api http  <- NO BORRAR ESTA LINEA NI ESTE COMENTARIO.
//   TagUI busca el texto literal "api http" dentro del codigo que genera para
//   decidir si le pasa --web-security=false a PhantomJS. Sin ese flag, el paso
//   `api` con una URL armada en una variable falla EN SILENCIO (devuelve vacio
//   por CORS). Ver tagui.cmd linea 1084 (Windows) y tagui linea 331 (Linux).
//
// OJO CON LAS RUTAS
//   TagUI resuelve las rutas relativas respecto de la ubicacion de ESTE
//   archivo, no de la carpeta desde donde ejecutas. Por eso "../data/".


// ==================================================================
// 1. CONFIGURACION
//    El token y el chat_id salen de config.txt, que esta en .gitignore
//    para no subir las credenciales del bot al repositorio del grupo.
// ==================================================================
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


// ==================================================================
// 2. CARGA DE DATOS
//    Los 3 CSV se leen como texto plano con `load`. NO se usa el paso
//    `excel` de TagUI: ese comando necesita Microsoft Excel instalado
//    (solo Windows/Mac) y el proyecto tiene que correr tambien en Linux.
// ==================================================================
load ../data/BaseDatos.csv to basedatos_texto
load ../data/StockActual.csv to stock_texto
load ../data/Menu.csv to menu_texto

lineas_bd = basedatos_texto.split(/\r?\n/)
lineas_stock = stock_texto.split(/\r?\n/)
lineas_menu = menu_texto.split(/\r?\n/)

// lista de comidas distintas que existen en la base de recetas
comidas = []
for i from 1 to lineas_bd.length-1
  linea = lineas_bd[i]
  if linea.length > 0
    campos = linea.split(",")
    nombre_comida = campos[0].trim()
    if comidas.indexOf(nombre_comida) equals to -1
      comidas[comidas.length] = nombre_comida


// ==================================================================
// 3. MENU INTERACTIVO
// ==================================================================
echo ===============================================
echo   LISTA DE COMPRAS - Grupo 13
echo ===============================================
echo   1 - Una sola comida
echo   2 - Varias comidas (las que quieras)
echo   3 - El menu semanal completo (data/Menu.csv)
echo -----------------------------------------------

ask Elegi una opcion (1, 2 o 3):
opcion = ask_result.trim()

seleccionadas = []

// --- opcion 1: una sola comida ---
if opcion equals to "1"
  echo -----------------------------------------------
  echo Comidas disponibles:
  for i from 0 to comidas.length-1
    linea_opcion = "  " + (i+1) + " - " + comidas[i]
    echo `linea_opcion`
  ask Numero de la comida:
  numero = Number(ask_result.trim())
  if numero > 0
    if numero <= comidas.length
      seleccionadas[0] = comidas[numero-1]

// --- opcion 2: varias comidas ---
// Se pueden repetir numeros a proposito (ej: 1,1,3 = dos veces la comida 1),
// igual que cuando una comida aparece dos veces en el menu de la semana.
if opcion equals to "2"
  echo -----------------------------------------------
  echo Comidas disponibles:
  for i from 0 to comidas.length-1
    linea_opcion = "  " + (i+1) + " - " + comidas[i]
    echo `linea_opcion`
  ask Numeros separados por coma (ej: 1,5,3):
  numeros = ask_result.split(",")
  for i from 0 to numeros.length-1
    numero = Number(numeros[i].trim())
    if numero > 0
      if numero <= comidas.length
        seleccionadas[seleccionadas.length] = comidas[numero-1]

// --- opcion 3: el menu semanal completo ---
// Este es el alcance original validado con los docentes: se lee Menu.csv
// entero, sin preguntar nada mas.
if opcion equals to "3"
  for d from 1 to lineas_menu.length-1
    linea_menu = lineas_menu[d]
    if linea_menu.length > 0
      campos_menu = linea_menu.split(",")
      seleccionadas[seleccionadas.length] = campos_menu[1].trim()

if seleccionadas.length equals to 0
  echo No se selecciono ninguna comida valida (opcion o numero fuera de rango).


// ==================================================================
// 4. CALCULO DE LO QUE HACE FALTA
// ==================================================================
necesario = {}
disponible = {}
unidad_de = {}
ingredientes = []

// pasada 1: arrancar en 0 todos los ingredientes de la base de recetas
// y guardar la unidad de medida de cada uno (kg, unidad, etc.)
for i from 1 to lineas_bd.length-1
  linea = lineas_bd[i]
  if linea.length > 0
    campos = linea.split(",")
    ingrediente = campos[1].trim()
    necesario[ingrediente] = 0
    disponible[ingrediente] = 0
    unidad = "unidad"
    if campos.length > 3
      unidad = campos[3].trim()
    unidad_de[ingrediente] = unidad
    if ingredientes.indexOf(ingrediente) equals to -1
      ingredientes[ingredientes.length] = ingrediente

// pasada 2: acumular lo necesario segun las comidas elegidas
for s from 0 to seleccionadas.length-1
  comida_elegida = seleccionadas[s]
  encontrada = 0
  for i from 1 to lineas_bd.length-1
    linea_bd = lineas_bd[i]
    if linea_bd.length > 0
      campos_bd = linea_bd.split(",")
      comida_bd = campos_bd[0].trim()
      if comida_bd equals to comida_elegida
        encontrada = 1
        ingrediente = campos_bd[1].trim()
        cantidad = Number(campos_bd[2])
        necesario[ingrediente] = necesario[ingrediente] + cantidad
  // PERTURBACION EXOGENA: el menu pide una comida que no esta cargada en la
  // base de recetas. El error viene de los datos de entrada, no del bot.
  if encontrada equals to 0
    echo ADVERTENCIA: `comida_elegida` no esta en BaseDatos.csv

// pasada 3: descontar lo que ya hay en la alacena
// (RETROALIMENTACION NEGATIVA: el bot mide el estado actual del sistema
//  antes de decidir la salida)
for i from 1 to lineas_stock.length-1
  linea_stock = lineas_stock[i]
  if linea_stock.length > 0
    campos_stock = linea_stock.split(",")
    ingrediente = campos_stock[0].trim()
    disponible[ingrediente] = Number(campos_stock[1])


// ==================================================================
// 5. ARMADO DEL MENSAJE
// ==================================================================
mensaje = "Lista de compras:" + "\n"
hay_algo_para_comprar = 0

for i from 0 to ingredientes.length-1
  ingrediente = ingredientes[i]
  falta = necesario[ingrediente] - disponible[ingrediente]
  if falta > 0
    unidad = unidad_de[ingrediente]
    if unidad equals to "unidad"
      // lo que se cuenta de a uno (huevos, lechugas) se redondea PARA ARRIBA:
      // no tiene sentido ir al super a comprar "media lechuga"
      falta = Math.ceil(falta)
    else
      // pesos y volumenes se redondean a 2 decimales, para que la suma de
      // numeros flotantes no escriba cosas como 0.30000000000000004
      falta = Math.round(falta * 100) / 100
    mensaje = mensaje + "- " + ingrediente + ": " + falta + " " + unidad + "\n"
    hay_algo_para_comprar = 1

echo -----------------------------------------------
echo `mensaje`


// ==================================================================
// 6. ENVIO POR TELEGRAM
//    Se usa el paso `api` (llamada HTTP directa a la Bot API) y NO curl
//    con el paso `run`: `run` se ejecuta sobre PhantomJS
//    (casper.waitForExec) y crashea en Windows con
//    "Fatal Windows exception, code 0xc0000005". `api` funciona igual
//    en Windows y en Linux, sin prefijos tipo "cmd /c".
// ==================================================================
if hay_algo_para_comprar equals to 1

  // queda guardado como evidencia local de la ultima corrida
  dump `mensaje` to ../mensaje.txt

  texto_codificado = encodeURIComponent(mensaje)
  url_envio = "https://api.telegram.org/bot" + TELEGRAM_TOKEN + "/sendMessage?chat_id=" + TELEGRAM_CHAT_ID + "&text=" + texto_codificado

  api `url_envio`

  envio_ok = 0
  if api_result.length > 0
    if api_json.ok equals to true
      envio_ok = 1

  if envio_ok equals to 1
    echo Mensaje enviado a Telegram correctamente
  else
    // ERROR EN ESTADO ESTABLE: el calculo salio bien pero el sistema no llega
    // al resultado esperado porque falla el token, el chat_id o la conexion.
    echo ERROR al enviar por Telegram. Respuesta cruda: `api_result`

else
  echo No hay nada para comprar: el stock actual alcanza para lo elegido.
