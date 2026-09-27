# Contexto del proyecto — TPI RPA Grupo 13

Este documento es la **memoria del trabajo**: qué decisiones se tomaron, por qué, qué
contratiempos hubo y qué falta hacer. Es el documento para leer antes de retomar el
proyecto o de meterle mano.

No repite lo que ya está en otro lado:

- **Qué es cada archivo y cómo arrancar** → [`README.md`](README.md)
- **Cómo instalarlo desde cero** → [`docs/instructivo-instalacion.md`](docs/instructivo-instalacion.md)
- **Cómo usarlo y cómo cargar datos** → [`docs/instructivo-uso.md`](docs/instructivo-uso.md)

---

## 1. La materia y el trabajo

- Materia: Tecnologías para la Automatización — UTN FRCU, Ingeniería en Sistemas de
  Información, 2026.
- Trabajo Práctico Integrador (TPI), grupal, combina Microcontroladores + RPA.
- **Grupo 13:** Barreto Martin, Carmona Julian, Casagrande Joaquin, Flegler Mateo,
  Graciani Juan Pablo, Joannas Damián.
- **Docentes:** Ulises Rapallini y Ernesto Ledesma.
- **Etapa 1** (la actual): al grupo 13 le toca RPA. El grupo emparejado hace
  Microcontroladores/ESP32 y tiene integrantes en Windows y en Linux.
  Entrega **30/09/2026**, exposiciones 01/10, 06/10, 08/10 o 13/10.
- **Etapa 2** (roles invertidos): el grupo 13 toma y mejora el proyecto de
  microcontroladores del otro grupo; ese grupo toma y mejora este proyecto RPA.
  Entrega **09/11/2026**.

> **Consecuencia técnica que atraviesa todo el proyecto:** en Etapa 2 este proyecto lo
> va a instalar y correr gente con Linux. Por eso **todo tiene que funcionar igual en
> Windows y en Linux**, y por eso se descartaron varias herramientas y varios caminos
> técnicos que funcionaban solo en Windows.

---

## 2. Decisiones tomadas y por qué

### 2.0 — El requisito de los docentes que cambió la arquitectura (10/09)

Los docentes aclararon por mensaje que un bot de Telegram **solo** vale para la parte
RPA si se usa como **disparador de un proceso local** (probablemente en Python) que
**interactúe con la máquina como lo haría un usuario** (navegador, CSV, aplicación de
escritorio) y **devuelva un resultado**. Un bot de Telegram sin esa parte local no
entra en la definición de RPA vista en clase.

La versión 1 (hoy en `version-1-tagui/`) no cumplía bien: se disparaba desde un menú
por consola, corría con `-n` (sin navegador) y Telegram era solo la salida. Por eso se
pasó a la versión 2:

- **Disparador:** el bot de Telegram (`bot.py`), con botones.
- **Proceso local "como un usuario":** lee los CSV y además el robot **maneja Chrome**
  para escribir la lista en el grupo de Telegram Web.
- **Resultado:** la lista llega al grupo y el bot confirma con una captura.

Se evaluó y **se descartó** buscar precios en la web de un supermercado como la parte
de navegador: el grupo decidió no trabajar con precios. Queda como mejora para Etapa 2
(ver checklist).

### 2.1 — Por qué TagUI (y ahora Python con la librería `rpa`)

TagUI es multiplataforma (Windows / Linux / macOS) y fue la única herramienta analizada
en profundidad en la clase del 20/08. Se descartó **Power Automate Desktop** porque no
tiene versión para Linux, lo que rompía el requisito de Etapa 2.

En la versión 2 el código está en **Python con la librería `rpa` (RPA for Python)**, que
es del mismo autor que TagUI y **por dentro maneja TagUI**. O sea: la herramienta de RPA
sigue siendo TagUI, pero manejada desde Python, que es lo que sugirieron los docentes y
permite escribir el bot de Telegram en el mismo lenguaje.

### 2.2 — Por qué Telegram y no WhatsApp

Se armó y probó primero un envío por **WhatsApp Web** con automatización de navegador
(buscar contacto, limpiar el campo, escribir, click en Enviar) y **funcionaba**.

Se decidió migrar igual, por dos motivos:

1. Automatizar WhatsApp con un bot corre riesgo real de que Meta **banee el número de
   teléfono** por comportamiento tipo bot.
2. Depender de clicks sobre elementos de una página web es frágil: cualquier cambio de
   diseño de WhatsApp rompe el script.

Se eligió la **Bot API de Telegram** (no "Telegram Web" con clicks) justamente para no
repetir esa fragilidad: es una llamada HTTP a una interfaz estable y documentada.

La evidencia del intento por WhatsApp quedó en `docs/evidencia/`, para poder mostrarla
en la parte de "cronología y contratiempos" de la exposición.

### 2.2 bis — Por qué en la versión 2 sí se automatiza Telegram Web con clicks

Parece contradecir la decisión anterior, pero cambió el requisito (2.0): ahora la
interacción "como un usuario" con el navegador **es lo que se pide**. Se hace sobre
Telegram Web y no sobre WhatsApp Web porque el riesgo de baneo es mucho menor. La
fragilidad se mitiga así:

- Todo lo que depende del diseño de Telegram Web (los selectores) está junto, arriba de
  todo en `robot_telegram_web.py`: si Telegram cambia su web, se corrige en un lugar.
- Si el robot falla por lo que sea, **el bot manda la lista él mismo por la Bot API**,
  con el motivo. La Bot API de la versión 1 quedó como plan B.
- El robot corre en un proceso aparte con **tiempo máximo de 3 minutos**: si se cuelga,
  el bot lo corta y sigue atendiendo.

La lista sale desde la cuenta personal que inició sesión en Telegram Web (no desde el
bot). Eso es coherente con la tarea que se automatiza: una persona de la casa arma la
lista y la manda al grupo familiar.

### 2.3 — Por qué los datos se leen de CSV como texto plano

TagUI tiene un comando `excel` con notación `[archivo]Hoja!Rango` que en un momento se
pensó que leía `.xlsx` / `.csv` sin depender de tener Excel instalado. **Eso es
incorrecto:** la documentación oficial confirma que ese comando necesita Microsoft Excel
instalado (solo Windows/Mac).

Por eso el proyecto usa `.csv` leídos como texto plano (en la versión 1 con `load` de
TagUI, en la versión 2 con el módulo `csv` de Python), que no depende de ningún programa
instalado y funciona igual en cualquier sistema operativo.

### 2.4 — Alcance: se amplió respecto de lo aprobado

El alcance validado originalmente con los docentes era **solo el menú semanal completo**.
Poder elegir una sola comida estaba explícitamente fuera de alcance.

Se amplió a pedido del grupo: ahora hay 3 opciones (una comida / varias comidas / semana
completa), que en la versión 2 son los 3 botones del bot. **El flujo semanal completo se
mantuvo intacto** (botón "Menú de la semana"), así lo aprobado sigue estando y lo nuevo
es un agregado, no un reemplazo.

> ⚠️ **Pendiente:** avisarles a los docentes de la ampliación (ver checklist, ítem 3).

### 2.5 — Unidades de medida

El mensaje ahora incluye la unidad. Antes decía `Papa: 1`, sin aclarar si era 1 kg o
1 papa.

- Unidad `unidad` (huevos, lechugas) → se redondea **para arriba** (`Math.ceil`): no
  tiene sentido comprar media lechuga.
- kg / lt → se redondea a 2 decimales, para evitar que la suma de números decimales
  escriba cosas como `0.30000000000000004`.

> **Sin resolver, a discutir con el grupo:** comprar `0.2 kg de pan rallado` tampoco es
> realista — se compra un paquete. Resolverlo bien requeriría una columna de
> presentación/envase en `BaseDatos.csv`. Buena candidata a mejora futura.

### 2.6 — Un solo archivo por flujo en la versión 1 (no fue descuido)

**TagUI no tiene ningún mecanismo de `include` / `import` entre archivos `.tag`**
(verificado leyendo el parser de la herramienta). Por eso en `version-1-tagui/` el
bloque que lee `config.txt` está **duplicado** en los tres scripts. En la versión 2,
Python sí permite importar, así que está una sola vez (`configuracion.py`).

### 2.7 — Las credenciales van fuera del código

El token, el chat_id y el nombre del grupo (`GRUPO_TELEGRAM`) están en `config.txt`, que
está en `.gitignore`. La plantilla versionada es `config.ejemplo.txt`.

El bot **solo acepta pedidos del chat_id de `config.txt`**: como cada pedido pone a
trabajar un robot en la PC, no puede quedar abierto a cualquiera que encuentre el bot.
Además, al prenderse **descarta los pedidos que llegaron con el bot apagado**, para que
no se disparen solos.

Se verificó que **el token nunca llegó a entrar al historial de git**. Cada integrante
del grupo se arma su propio `config.txt`.

---

## 3. El contratiempo grande de la versión 1: el envío por Telegram

Vale la pena contarlo en la exposición, porque la causa raíz se encontró leyendo el
código fuente de TagUI, no adivinando. (Todo esto aplica a `version-1-tagui/`; en la
versión 2 los llamados a la Bot API se hacen con la librería `requests` de Python.)

### Los intentos fallidos

**Intento 1** — `run curl ...` con las variables interpoladas. No mandaba el mensaje.

**Intento 2** — armar el comando en una variable, volcarlo a un `.bat` y hacer
`run enviar.bat`. El comando se armaba bien (confirmado por el `dump`), pero crasheaba:

```
Fatal Windows exception, code 0xc0000005. PhantomJS has crashed
```

### Causa raíz del crash

El paso `run` de TagUI se compila a `casper.waitForExec(...)` (`tagui_parse.php:1087`),
que se ejecuta sobre **PhantomJS** y hace `spawn()` partiendo el comando por espacios.
Es un bug conocido y documentado en Windows: pasa hasta con un simple `dir`.

- [aisingapore/TagUI#824](https://github.com/aisingapore/TagUI/issues/824)
- [kelaberetiv/TagUI#503](https://github.com/kelaberetiv/TagUI/issues/503)
- [aisingapore/TagUI#473](https://github.com/aisingapore/TagUI/issues/473)

El workaround que propone la comunidad es anteponer `cmd /c`, pero eso es **Windows-only**
y rompía el requisito de Etapa 2.

### La solución: el paso `api`

Se pasó a usar el paso **`api`** de TagUI, que hace la llamada HTTP directa a la Bot API.
De un saque elimina curl, el `spawn` de PhantomJS, el `cmd /c` y toda diferencia entre
Windows y Linux.

### Pero `api` tiene su propia trampa (esta fue la parte difícil)

En `tagui.cmd:1084` (Windows) y `tagui:331` (Linux), TagUI hace esto:

```
find /i /c "api http" "%flow_file%.js" > nul
if not errorlevel 1 set api= --web-security=false
```

Busca el **texto literal `api http`** dentro del JavaScript que genera, para decidir si
le pasa `--web-security=false` a PhantomJS. Sin ese flag, el XHR cross-origin se bloquea
por CORS y la llamada devuelve string vacío **en silencio**, sin ningún mensaje de error.

Entonces:

| Cómo lo escribís | Qué genera | Resultado |
|---|---|---|
| `api https://...` (URL literal) | contiene `api http` | ✅ anda |
| ``api `url` `` (URL en variable) | genera `api '+url+'` | ❌ falla mudo |

Y la URL **tiene** que estar en una variable, porque el token viene de `config.txt`.

**El fix:** dejar en los comentarios del script una línea que contenga el texto
`api http`. Es un hack, pero es el mismo mecanismo que usa TagUI internamente: en
`tagui_parse.php:1010`, el paso `telegram` nativo de TagUI genera el comentario
`// 'api http' to allow API calls` exactamente por este motivo.

Por eso los tres `.tag` del proyecto llevan esa línea con un cartel de **NO BORRAR**.

### Dato aparte: el paso `telegram` nativo de TagUI

TagUI tiene un paso `telegram` incorporado, pero **no se usa**: manda el mensaje a través
de un servidor intermediario de AI Singapore (`telegram_endpoint + '/sendMessage.php'`),
o sea que dependés de un tercero y de su bot, no del bot propio. Llamar a la Bot API
oficial directo es mejor y era lo que pedía la consigna.

---

## 3 bis. Contratiempos de la versión 2 (robot en Telegram Web)

También sirven para la parte de "cronología y contratiempos":

1. **Chrome se abría y no pasaba nada.** La primera vez que TagUI estrena su perfil de
   Chrome, Chrome reemplaza la pestaña en blanco inicial. TagUI se había enganchado a
   esa pestaña, y al querer manejarla Chrome contestaba `No such target id` (se vio en
   `tagui_chrome.log`). Solución: cortar con Ctrl+C y correrlo de nuevo; pasa una sola
   vez. Está en el instructivo de instalación.

2. **El buscador de Telegram mezcla tus chats con desconocidos.** Al buscar "Mensajes
   guardados" aparecieron canales y bots **públicos de desconocidos** con ese nombre (uno
   con 687 suscriptores), en la sección "Global Search". Con el primer selector, el robot
   podría haberle escrito a un extraño. Se corrigió antes de enviar nada: ahora el robot
   solo acepta resultados de secciones cuyo título **no** diga "global". Se verificó
   contando coincidencias para varios nombres antes de la primera prueba de envío.

3. **Con la PC bloqueada, Telegram Web queda en blanco.** Una prueba se colgó de
   madrugada: la sesión de Windows estaba bloqueada, Chrome deja de dibujar las páginas y
   el robot esperaba un buscador que nunca aparecía. Es una limitación de todo RPA que
   maneja la pantalla (necesita la sesión abierta, igual que una persona). Consecuencia
   en el diseño: el bot corre el robot en un proceso aparte con **tiempo máximo**, y si
   se pasa lo corta y manda la lista por la Bot API.

4. **La espera de `exist()` no fue confiable.** Devolvió "no existe" con la sesión
   iniciada y la página cargada. Se reemplazó por una espera propia que pregunta con
   `present()` una vez por segundo. También se agregaron reintentos a la búsqueda y al
   click, porque Telegram Web a veces redibuja el panel mientras termina de cargar y se
   pierde lo tipeado.

5. **Tipeada, la lista hubiera salido en 14 mensajes.** Leyendo `tagui_header.js` se
   vio que TagUI convierte cada salto de línea en la tecla **Enter**, y en Telegram Enter
   envía. Se detectó antes de la primera prueba de envío. Solución: la lista se **pega**
   entera en la caja de mensaje (como Ctrl+V) y después se hace click en el botón
   "enviar". Se verificó pegando una lista con tildes, «» y Ñ **sin enviarla**, y
   después con un envío real a "Saved Messages": llegó un solo mensaje de 3 renglones.

6. **La captura mostraba la lista de chats de la persona.** La captura de confirmación
   se recortó a la columna del chat abierto, para no mandar nombres de contactos ni
   vistas previas de otros mensajes.

---

## 4. Otros hallazgos técnicos sobre TagUI

Cosas que costó descubrir y conviene tener anotadas:

1. **El flag `-n` (nobrowser) cambia el comportamiento de `ask`.** TagUI lo compila de
   dos formas distintas (`tagui_parse.php:997`): sin `-n` abre un `prompt()` de Chrome,
   con `-n` pregunta por consola. Además la corrida es bastante más rápida.

2. **Las rutas relativas son relativas al archivo `.tag`, no al directorio desde donde
   ejecutás.** Por eso los scripts usan `../data/` y `../config.txt`. Verificado.

3. **PHP es un requisito, y se resuelve distinto según el sistema.** En Windows TagUI
   trae su propia copia (`src/php/php.exe`) y la agrega al PATH sola. En Linux llama al
   `php` del sistema, así que hay que instalarlo (`php-cli`) o falla con errores
   confusos. Es la trampa más probable para el grupo de Linux en Etapa 2. La librería
   `rpa` lo confirma: al instalarse en Linux chequea que exista `php`.

4. **La librería `rpa` trae su propio TagUI.** La primera vez descarga ~200 MB a
   `%APPDATA%\tagui` (Windows) o `~/.tagui` (Linux), separado de cualquier TagUI que ya
   esté instalado. Su Chrome usa un perfil propio (`src/chrome/tagui_user_profile`), y
   ahí queda guardada la sesión de Telegram Web.

5. **`rpa` escribe letra por letra, y los saltos de línea son Enter.** Salvo en
   `turbo_mode`, `type()` manda cada carácter como una tecla; `\n` y `[enter]` se
   convierten en la tecla Enter, y `[clear]` borra el campo antes de escribir.

6. **Los clicks de TagUI en Chrome son clicks de mouse reales** (eventos
   `mousePressed`/`mouseReleased` en el centro del elemento), no un `.click()` de
   JavaScript. Por eso conviene esperar a que terminen las animaciones antes de hacer
   click.

---

## 5. Estado actual

**Versión 1 (`version-1-tagui/`):** funcionó y se probó de punta a punta en Windows
(menú por consola, cálculo, envío por la Bot API).

**Versión 2 — probado en Windows:**

- Cálculo en Python: da **idéntico** a las corridas de la versión 1 (abajo).
- Lógica del bot (botones, "Varias" con repetidas, comida sin receta, chats ajenos
  ignorados, menú viejo, robot que falla → la lista la manda el bot): probada con una
  simulación que reemplaza a Telegram y al robot.
- Corte del robot por tiempo máximo: probado con robots falsos (colgado, con error,
  exitoso).
- Robot en Telegram Web: inicio de sesión por QR, búsqueda limitada a chats propios
  (verificada contra resultados públicos con el mismo nombre), pegado con renglones,
  tildes y Ñ, envío real a "Saved Messages" y captura recortada.

**Falta probar:** la corrida **punta a punta** (pedido con botones → robot → grupo real)
y todo en **Linux**.

Salidas de las corridas de prueba (con los datos de ejemplo):

```
Opción 1, comida "Milanesas con pure":
  - Carne nalga: 0.5 kg
  - Pan rallado: 0.2 kg
  (Papa y Huevo no aparecen: el stock actual ya los cubre)

Opción 2, "1,1,5" (Milanesas x2 + Asado):
  - Carne nalga: 1 kg / Papa: 1 kg / Pan rallado: 0.4 kg
  - Carne asado: 1.5 kg / Chorizo: 0.5 kg

Opción 3, menú semanal completo:
  13 ingredientes + la advertencia de que Empanadas no tiene receta cargada.
```

Repositorio: `https://github.com/matufle/Etapa-1-Automatizacion-RPA.git`
(remote `origin`, rama `main`).

---

## 6. Los tres conceptos teóricos de la materia

Los tres están marcados con comentarios en MAYÚSCULAS dentro del código, en el punto
exacto donde ocurren, para poder mostrarlos en la demo: `Ejecutables/compras.py` y
`Ejecutables/bot.py` (en la versión 1, en `version-1-tagui/compras.tag`).

| Concepto | Dónde aparece en el bot |
|---|---|
| **Retroalimentación negativa** | El bot lee `StockActual.csv` (mide el estado actual del sistema) antes de decidir qué salida producir. (`compras.py`) |
| **Perturbación exógena** | Una comida del menú que no está cargada en la base de recetas, o un error de formato en un CSV. El error viene de **afuera** del sistema. (`compras.py` y `bot.py`) *(Antes esto estaba mal anotado como "endógena". Endógena sería, por ejemplo, que el propio motor de TagUI se cuelgue: un fallo de sus propios componentes.)* |
| **Error en estado estable** | El cálculo sale bien pero el sistema no llega al resultado esperado: el robot no puede entregar la lista (no hay sesión en Telegram Web, no encuentra el grupo, la PC está bloqueada, se cortó la conexión). En la versión 2 el sistema además **corrige** ese error: el bot manda la lista él mismo por la Bot API. (`bot.py`) *(Se eligió este en lugar de "Control de Calidad del Proceso", que no está definido literalmente en las clases de teoría y era más difícil de defender oralmente.)* |

---

## 7. Checklist de lo que falta para Etapa 1

1. ~~Terminar y confirmar el envío por Telegram.~~ **HECHO** (versión 1).
1b. **Probar la versión 2 punta a punta**: pedido con botones desde Telegram → robot →
   lista en el grupo real → confirmación con captura. Todo lo demás de la versión 2 ya
   está probado por partes (sección 5).
1c. Contarles a los docentes (¿el jueves?) cómo quedó la arquitectura según su mensaje
   del 10/09 (sección 2.0), y guardar ese mensaje para la expo.
2. Escribir el párrafo de fundamentación de por qué se eligió TagUI (argumento: única
   herramienta vista en profundidad en clase + corre igual en Windows y Linux, algo que
   Power Automate no cumple) y por qué se maneja desde Python con `rpa`. El material está
   en las secciones 2.0 y 2.1.
3. Guardar el mail/mensaje de aprobación de los docentes sobre el proceso elegido, para
   tenerlo a mano en la expo. **Sumar el aviso de la ampliación de alcance** (sección 2.4).
4. Cerrar por escrito las restricciones del proceso: **quién actualiza `StockActual.csv`
   y con qué frecuencia** *(22/09: decidido, lo actualiza la persona que usa el bot con
   el botón 🥫 Mi alacena; el bot no lo modifica solo)*; qué pasa si una comida no está en la base de recetas (ya
   resuelto en código con el log de advertencia, falta documentarlo como decisión).
5. **Completar `BaseDatos.csv` con recetas reales del grupo** — hoy son datos de ejemplo.
   *(22/09: se amplió a 25 comidas típicas de ejemplo, y el bot ahora permite ver las
   recetas, cargar recetas nuevas desde Telegram sin duplicados, y cambiar o sortear el
   menú de la semana. Falta revisar que las cantidades sean las reales del grupo.)*
   Idea: cada uno de los 6 integrantes aporta 2-3 comidas reales, para llegar a 15-20.
6. Definir los valores reales de `StockActual.csv` y de `Menu.csv` (hoy también son de
   ejemplo).
7. **Probar el flujo completo en Linux.** El código no tiene nada Windows-only (hay
   lanzador `.sh`, y el robot usa las rutas de TagUI de cada sistema). Ojo con el
   requisito de PHP (sección 4, punto 3) y con tener Google Chrome instalado. **Al
   probarlo, actualizar la sección de Linux del instructivo de instalación con lo que
   realmente pase.**
8. ~~Corregir los 3 conceptos teóricos.~~ **HECHO** (sección 6). Falta poder explicarlos
   con palabras propias en la exposición.
9. ~~Armar el instructivo de instalación y el de uso.~~ **HECHO** (actualizados a la
   versión 2). Falta **sacar las capturas de pantalla**: están marcados los lugares con
   📸 dentro del instructivo de instalación (BotFather, `getUpdates`, el robot
   escribiendo en Telegram Web).
10. Redactar la mejora sugerida para Etapa 2: módulo de web scraping que calcule el
    presupuesto total consultando precios en la web de un supermercado local de
    Concepción del Uruguay. Confirmar con los docentes qué sitio usar como referencia,
    para que el otro grupo no se trabe en eso.
11. Subir todo a GitHub para el resto del grupo. El `.gitignore` ya protege `config.txt`.
    Aclararle al grupo que cada uno se arma el suyo a partir de `config.ejemplo.txt`.
12. Armar los entregables finales:
    - **Parte 1 (exposición oral):** diapositivas con herramienta, cronología y
      contratiempos, riesgos/desafíos, los 3 conceptos; termina con demo en vivo.
      Preparar un **video de respaldo** por si falla Telegram o la conexión en vivo.
      Para la demo: iniciar sesión en Telegram Web **antes** (el QR no se escanea en
      vivo), y dejar la PC con la sesión abierta y sin bloqueo de pantalla.
    - **Parte 2 (ZIP al Campus Virtual):** flujo exportado (.txt) + capturas; CSV de
      ejemplo; instructivo de instalación completo; documento con definición del proceso
      + los 3 conceptos + mejora sugerida.

### Mejoras identificadas, fuera del alcance de Etapa 1

- Manejo de presentaciones/envases para las cantidades (sección 2.5).
- Módulo de scraping de precios para calcular el presupuesto (ítem 10).
