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

### 2.1 — Por qué TagUI

Es multiplataforma (Windows / Linux / macOS) y fue la única herramienta analizada en
profundidad en la clase del 20/08. Se descartó **Power Automate Desktop** porque no
tiene versión para Linux, lo que rompía el requisito de Etapa 2.

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

### 2.3 — Por qué los datos se leen de CSV como texto plano

TagUI tiene un comando `excel` con notación `[archivo]Hoja!Rango` que en un momento se
pensó que leía `.xlsx` / `.csv` sin depender de tener Excel instalado. **Eso es
incorrecto:** la documentación oficial confirma que ese comando necesita Microsoft Excel
instalado (solo Windows/Mac).

Por eso el proyecto usa `.csv` leídos como texto plano con `load`, que no depende de
ningún programa instalado y funciona igual en cualquier sistema operativo.

### 2.4 — Alcance: se amplió respecto de lo aprobado

El alcance validado originalmente con los docentes era **solo el menú semanal completo**.
Poder elegir una sola comida estaba explícitamente fuera de alcance.

Se amplió a pedido del grupo: ahora hay 3 opciones (una comida / varias comidas / semana
completa). **El flujo semanal completo se mantuvo intacto como opción 3**, así lo
aprobado sigue estando y lo nuevo es un agregado, no un reemplazo.

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

### 2.6 — Un solo archivo por flujo (no es descuido)

**TagUI no tiene ningún mecanismo de `include` / `import` entre archivos `.tag`**
(verificado leyendo el parser de la herramienta). Por eso el bloque que lee `config.txt`
está **duplicado** en los tres scripts: no hay forma de compartir código entre flujos.
Está aclarado con un comentario en cada archivo.

### 2.7 — Las credenciales van fuera del código

El token y el chat_id están en `config.txt`, que está en `.gitignore`. La plantilla
versionada es `config.ejemplo.txt`.

Se verificó que **el token nunca llegó a entrar al historial de git**. Cada integrante
del grupo se arma su propio `config.txt`.

---

## 3. El contratiempo grande: el envío por Telegram

Vale la pena contarlo en la exposición, porque la causa raíz se encontró leyendo el
código fuente de TagUI, no adivinando.

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
   confusos. Es la trampa más probable para el grupo de Linux en Etapa 2.

---

## 5. Estado actual

**Funciona y está probado de punta a punta en Windows:**

- Menú interactivo con las 3 opciones.
- Cálculo de ingredientes acumulando repeticiones, con advertencia si una comida no
  tiene receta cargada.
- Descuento contra el stock actual.
- Unidades de medida en el mensaje final.
- Envío por Telegram.
- Credenciales fuera del código y protegidas por `.gitignore`.

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

**No probado todavía:** la corrida en **Linux** (ítem 7 del checklist).

Repositorio: `https://github.com/matufle/Etapa-1-Automatizacion-RPA.git`
(remote `origin`, rama `main`).

---

## 6. Los tres conceptos teóricos de la materia

Los tres están marcados con comentarios dentro de `Ejecutables/compras.tag`, en el punto
exacto del código donde ocurren, para poder mostrarlos en la demo.

| Concepto | Dónde aparece en el bot |
|---|---|
| **Retroalimentación negativa** | El bot lee `StockActual.csv` (mide el estado actual del sistema) antes de decidir qué salida producir. |
| **Perturbación exógena** | Una comida del menú que no está cargada en la base de recetas, o un error de formato en un CSV. El error viene de **afuera** del sistema. *(Antes esto estaba mal anotado como "endógena". Endógena sería, por ejemplo, que el propio motor de TagUI se cuelgue: un fallo de sus propios componentes.)* |
| **Error en estado estable** | El cálculo sale bien pero el sistema no llega al resultado esperado porque falla el token, el chat_id o la conexión: el mensaje no sale. *(Se eligió este en lugar de "Control de Calidad del Proceso", que no está definido literalmente en las clases de teoría y era más difícil de defender oralmente.)* |

---

## 7. Checklist de lo que falta para Etapa 1

1. ~~Terminar y confirmar el envío por Telegram.~~ **HECHO.**
2. Escribir el párrafo de fundamentación de por qué se eligió TagUI (argumento: única
   herramienta vista en profundidad en clase + corre igual en Windows y Linux, algo que
   Power Automate no cumple). El material está en la sección 2.1.
3. Guardar el mail/mensaje de aprobación de los docentes sobre el proceso elegido, para
   tenerlo a mano en la expo. **Sumar el aviso de la ampliación de alcance** (sección 2.4).
4. Cerrar por escrito las restricciones del proceso: **quién actualiza `StockActual.csv`
   y con qué frecuencia**; qué pasa si una comida no está en la base de recetas (ya
   resuelto en código con el log de advertencia, falta documentarlo como decisión).
5. **Completar `BaseDatos.csv` con recetas reales del grupo** — hoy son datos de ejemplo.
   Idea: cada uno de los 6 integrantes aporta 2-3 comidas reales, para llegar a 15-20.
6. Definir los valores reales de `StockActual.csv` y de `Menu.csv` (hoy también son de
   ejemplo).
7. **Probar el flujo completo en Linux.** En Windows ya está probado de punta a punta.
   No debería requerir cambios de código: no quedó nada Windows-only. Ojo con el
   requisito de PHP (sección 4, punto 3). **Al probarlo, actualizar la sección de Linux
   del instructivo de instalación con lo que realmente pase.**
8. ~~Corregir los 3 conceptos teóricos.~~ **HECHO** (sección 6). Falta poder explicarlos
   con palabras propias en la exposición.
9. ~~Armar el instructivo de instalación y el de uso.~~ **HECHO.** Falta **sacar las
   capturas de pantalla**: están marcados los lugares con 📸 dentro del instructivo de
   instalación (BotFather, `getUpdates`, el mensaje llegando a Telegram).
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
    - **Parte 2 (ZIP al Campus Virtual):** flujo exportado (.txt) + capturas; CSV de
      ejemplo; instructivo de instalación completo; documento con definición del proceso
      + los 3 conceptos + mejora sugerida.

### Mejoras identificadas, fuera del alcance de Etapa 1

- Manejo de presentaciones/envases para las cantidades (sección 2.5).
- Módulo de scraping de precios para calcular el presupuesto (ítem 10).
