// compras.tag
// Bot de gestion de inventario y compras de supermercado - Grupo 13
// Lee Menu.csv, cruza con BaseDatos.csv, descuenta StockActual.csv,
// arma el mensaje final y lo envia por WhatsApp Web

contacto = "Lista de Compras Bot"

load data/Menu.csv to menu_texto
load data/BaseDatos.csv to basedatos_texto
load data/StockActual.csv to stock_texto

lineas_menu = menu_texto.split(/\r?\n/)
lineas_bd = basedatos_texto.split(/\r?\n/)
lineas_stock = stock_texto.split(/\r?\n/)

necesario = {}
disponible = {}
ingredientes = []

// pasada 1: registrar en 0 todos los ingredientes que existen en BaseDatos.csv
for i from 1 to lineas_bd.length-1
  linea = lineas_bd[i]
  if linea.length > 0
    campos = linea.split(",")
    ingrediente = campos[1]
    necesario[ingrediente] = 0
    disponible[ingrediente] = 0
    if ingredientes.indexOf(ingrediente) equals to -1
      ingredientes[ingredientes.length] = ingrediente

// pasada 2: acumular lo necesario segun el menu de la semana
for d from 1 to lineas_menu.length-1
  linea_menu = lineas_menu[d]
  if linea_menu.length > 0
    campos_menu = linea_menu.split(",")
    comida_del_dia = campos_menu[1]
    encontrada = 0

    for i from 1 to lineas_bd.length-1
      linea_bd = lineas_bd[i]
      if linea_bd.length > 0
        campos_bd = linea_bd.split(",")
        comida_bd = campos_bd[0]
        if comida_bd equals to comida_del_dia
          encontrada = 1
          ingrediente = campos_bd[1]
          cantidad = Number(campos_bd[2])
          necesario[ingrediente] = necesario[ingrediente] + cantidad

    if encontrada equals to 0
      echo ADVERTENCIA: `comida_del_dia` no esta en BaseDatos.csv

// pasada 3: cargar el stock actual (lo que ya tenes en la alacena)
for i from 1 to lineas_stock.length-1
  linea_stock = lineas_stock[i]
  if linea_stock.length > 0
    campos_stock = linea_stock.split(",")
    ingrediente = campos_stock[0]
    disponible[ingrediente] = Number(campos_stock[1])

// armar el mensaje final con lo que falta comprar
mensaje = "Lista de compras de la semana:" + "\n"
hay_algo_para_comprar = 0

for i from 0 to ingredientes.length-1
  ingrediente = ingredientes[i]
  falta = necesario[ingrediente] - disponible[ingrediente]
  if falta > 0
    mensaje = mensaje + "- " + ingrediente + ": " + falta + "\n"
    hay_algo_para_comprar = 1

echo `mensaje`

// control: no interactuar con WhatsApp si no hay nada para comprar
if hay_algo_para_comprar equals to 1

  https://web.whatsapp.com
  wait 20

  sesion_activa = 0
  if exist('Buscar un chat o iniciar uno nuevo')
    sesion_activa = 1

  if sesion_activa equals to 1
    type Buscar un chat o iniciar uno nuevo as `contacto`
    wait 2
    click `contacto`
    wait 2
    type Escribe un mensaje as [clear]
    wait 1
    type Escribe un mensaje as `mensaje`
    wait 1
    click Enviar
    wait 2
    echo Mensaje enviado a `contacto`
  else
    echo ERROR: no se detecto la sesion de WhatsApp Web activa

else
  echo No hay nada para comprar esta semana, no se envia mensaje