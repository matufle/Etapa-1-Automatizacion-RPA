La idea de es archivo es explicar mas a detalle el archivo bot.py.
# Idea General
La idea general es que es un bot de telegram que corre en nuestra pc, queda esperando mensajes y cada cierto tiempo hace consulta mediante la API de telegram para ver si hay un mensaje nuevo.

# Explicacion Por Bloques
# Bloque 1 IMPORST Y CONFIGS #
En la primer parte podemos ver que tenemos ciertos imports, la idea es que utilizamos:
1. *Random*: para sortear un menú semanal al azar.
2. *subprocess*: para correr el robot como otro programa parte.
3. *sys*: esto lo usamos por que al momento de ejecutar el iniciar_bot esta corriendo ese archivo python, entonces con esto tenemos la misma ruta.
4. *time*: lo usamos para el time.sleep para cuando no hay internet o se corta.
5. *path*: Esto lo usamos para el manejo de rutas de archivos mas facilmente.
6. *request*: esto es para hacer llamadas HTTP a la Api de Telgram.
7. *compras*: este es el otro archivo donde trabajamos con las recetas, stock y calculos.
8. *robot_telegram_web*: este es el modulo que maneja la parte de RPA donde se abre chrome y todo eso.

**CONSTANTES GLOBALES**
En esta siguiente parte traemos todo del archivo de configuracion, la idea es que este se modifica segun el usuario ya que no todos tenemos el mismo bot, entonces segun el usuario este tiene que cambiar estos datos para que el robot funcione, osea el telegramid, token y demas.
El Robot = Path lo que hace es que el bot puedan encontrar esta carpeta por mas que lo ejecutemos desde otra.

**ESTADO EN MEMORIA**
Vemos que definimos menu = {}, el proposito de esto es un diccionario que guarda el chat y el mensaje del mismo entonces se guarda el estado en el que esta el chat, en caso de que se reinicie, como esta en memoria, se borraria.

# BLOQUE 2 - LLAMADAS A LA BOT API #
Esta capa es la que hace la base de comunicacion con telegram. El primer metodo es el *llamar*, esta es la funcion base, todas las demas la usan.

**llamar(metodo, archivos=None, **datos)**
el *metodo* es el nombre del metodo de la API que se utiliza para *sendMessage*,*editMessageText*,etc.
Dentro de esto tambien tenemos el  **datos, el cual junta todo lo que se mande de informacion, EJ:
*llamar("sendMessage", chat_id=1, text="hola") hace datos = {"chat_id": 1, "text": "hola"}*
En caso de que tengamos algun archivo, como una foto, manda la peticion como formulario(data=files=).Sino, lo manda como JSON.
Si telegram responde *"ok":false*, imprime el motivo en consola pero no corta el programa, dando continuidad.

**responder(chat_id, texto, botones=None)**
esta funcion se usa para mandar un mensaje nuevo, si les pasamos botones los agrega como inline_keyboard que son los botones que aparecen pegados abajo del mensaje.

**editar(chat_id, message_id, texto, botones=None)**
este modifica un mensaje que ya existe, por eso podemos ver la navegacion entre pantallas, no se manda un mensaje nuevo por cada toque, se reescribe el mensaje, en caso de no pasarle botones pone [] y los botones desaparecen.

**mandar_foto(chat_id, ruta, texto)**
esto se usa para poder capturar la pantalla final, se abre la imagen en modo binario y se la manda con el sendPhoto del API metodo.

# BLOQUE 3 - CONSTRUCCION DE MENUS Y TEXTO #
Estas funciones en si no mandan nada, solo arman botones y texto para desacoplar y separar funcionalidades, los cuales seran enviados en ciertos momentos determinados. Lo que dice *text* es lo que va a ver el usuario, lo que dice *callback_data* es lo que le llega al bot cuando se toca el boton.
La estructura que usamos es una lista de filas donde cada fila es una lista de botones

**botones principales()**
Esta devuelve el menu inicial.

**botones_de_comidas**
Esta funcion es la que se llama para generar un boton por comida, vemos que le cargamos prefijos, eso es por que al momento de generar los botones tenemos todos esos que son distintas formas de escribir o de accionar.
Usamos el numero de comida como el indice debido a que telegram limita los callback a 64 bytes.
En el caso de que queramos seleccionar varias comidas agrega el boton de *listo* y el de *borrar*, ademas de que siempre esta el boton de *volver* el cual vuelve  a la pagina anterior en la que estaba.

**resumen**
esta funcion se usa mas que nada para cuando seleccionamos varias y por ejemplo elegimos 2 veces asado, en vez de que aparezca como [asado, asado] aparece como [asado x2]. El dict ahi lo que hace es que saca los repetidos pero mantiene el orden.

**texto_varias**
Esto arma el texto de la pantalla varias comidas con lo que se eligio hasta el momento.
