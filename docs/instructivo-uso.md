# Instructivo de uso

Cómo usar el bot una vez instalado. Si todavía no lo instalaste, empezá por el
[instructivo de instalación](instructivo-instalacion.md).

---

## Ejecutar el bot

- **Windows:** doble click en `Ejecutables\compras.cmd`
- **Linux / macOS:** `./Ejecutables/compras.sh`

También podés correrlo a mano, pero **acordate del flag `-n`**:

```
tagui Ejecutables/compras.tag -n
```

El `-n` (de *nobrowser*) hace que TagUI corra sin abrir Chrome. Sin él, las preguntas
del programa aparecen en un popup del navegador en vez de la consola, que no es lo que
querés. Los lanzadores `.cmd` y `.sh` existen justamente para no tener que acordarse.

---

## Las tres opciones del menú

Al arrancar, el bot te muestra esto:

```
===============================================
  LISTA DE COMPRAS - Grupo 13
===============================================
  1 - Una sola comida
  2 - Varias comidas (las que quieras)
  3 - El menu semanal completo (data/Menu.csv)
-----------------------------------------------
Elegi una opcion (1, 2 o 3):
```

### Opción 1 — Una sola comida

Te muestra la lista de comidas cargadas, numeradas, y escribís el número de la que
querés cocinar.

```
Comidas disponibles:
  1 - Milanesas con pure
  2 - Fideos con tuco
  3 - Pollo al horno con ensalada
  4 - Tarta de verdura
  5 - Asado
Numero de la comida: 1

-----------------------------------------------
Lista de compras:
- Carne nalga: 0.5 kg
- Pan rallado: 0.2 kg

Mensaje enviado a Telegram correctamente
```

Fijate que la Papa y el Huevo que llevan las milanesas **no aparecen**: es porque
`StockActual.csv` dice que ya tenés suficiente en casa.

### Opción 2 — Varias comidas

Igual que la anterior, pero cargás **varios números separados por coma**:

```
Numeros separados por coma (ej: 1,5,3): 1,1,5
```

Ese ejemplo significa "dos veces milanesas y un asado". **Podés repetir números a
propósito**: si ponés una comida dos veces, las cantidades se suman, igual que cuando
una comida aparece dos veces en el menú de la semana.

### Opción 3 — El menú semanal completo

No pregunta nada más: agarra `data/Menu.csv` entero y calcula los ingredientes de toda
la semana de una. Es el modo original del proyecto.

---

## Cargar tus propias comidas y tu stock

Los tres archivos de `data/` son **archivos `.csv` comunes**. Los podés editar con
Excel, LibreOffice, o cualquier editor de texto.

> ⚠️ **Los datos que vienen cargados son de ejemplo.** Hay que reemplazarlos por las
> recetas y el stock reales del grupo.

### `data/BaseDatos.csv` — las recetas

Es el archivo principal. **Una fila por cada ingrediente de cada comida**, así que una
comida ocupa varias filas seguidas:

```csv
Comida,Ingrediente,Cantidad,Unidad
Milanesas con pure,Carne nalga,0.5,kg
Milanesas con pure,Papa,1,kg
Milanesas con pure,Pan rallado,0.2,kg
Milanesas con pure,Huevo,2,unidad
Fideos con tuco,Fideos,0.5,kg
```

- **Comida**: tiene que escribirse **exactamente igual** en todas sus filas, y también
  igual a como figure en `Menu.csv`. Si en un lado dice `Milanesas con pure` y en otro
  `Milanesas con puré`, el bot los toma como dos comidas distintas.
- **Cantidad**: usá **punto** para los decimales (`0.5`), no coma. La coma separa
  columnas y rompería el archivo.
- **Unidad**: `kg`, `lt`, `unidad`, etc. Ver más abajo cómo afecta al redondeo.
- **No uses comas dentro de los nombres** de comidas ni de ingredientes.

Las comidas que aparecen en el menú de las opciones 1 y 2 salen **de este archivo**:
apenas agregás una comida acá, aparece sola en la lista numerada.

### `data/Menu.csv` — el menú de la semana

Solo lo usa la opción 3.

```csv
Dia,Comida
Lunes,Milanesas con pure
Martes,Fideos con tuco
```

Cada comida tiene que existir en `BaseDatos.csv`. Si no existe, el bot **no se rompe**:
sigue funcionando y te avisa por pantalla:

```
ADVERTENCIA: Empanadas no esta en BaseDatos.csv
```

### `data/StockActual.csv` — lo que ya tenés en casa

```csv
Ingrediente,CantidadDisponible,Unidad
Papa,1,kg
Huevo,6,unidad
```

- El nombre del ingrediente tiene que coincidir exactamente con el de `BaseDatos.csv`.
- Lo que no figure acá se toma como que **no tenés nada** de eso.
- Si tenés más de lo que hace falta, el ingrediente directamente no aparece en la lista.

---

## Cómo se redondean las cantidades

- Lo que se mide en **`unidad`** (huevos, lechugas) se redondea **para arriba**: si el
  cálculo da 0.5 lechugas, la lista dice `1 unidad`. No tiene sentido ir al súper a
  comprar media lechuga.
- Lo que se mide en **kg / lt** se redondea a 2 decimales. Esto es para que la suma de
  números decimales no escriba cosas como `0.30000000000000004`.

> **Limitación conocida:** el bot puede pedirte `0.2 kg de pan rallado`, que tampoco es
> algo que se compre así (comprás un paquete). Resolverlo bien requeriría agregar una
> columna de presentación/envase a `BaseDatos.csv`. Está anotado como mejora pendiente
> en [`contexto.md`](../contexto.md).

---

## Las pruebas

Sirven para verificar partes sueltas sin tener que correr todo el programa.

### `pruebas/prueba_conexion.tag`

```
tagui pruebas/prueba_conexion.tag -n
```

Comprueba que el token de `config.txt` sea válido. **No le manda un mensaje a nadie.**
Es la primera prueba a correr cuando algo falla, porque descarta de una si el problema
es la configuración o es otra cosa.

### `pruebas/prueba_telegram.tag`

```
tagui pruebas/prueba_telegram.tag -n
```

Manda un mensaje suelto y te pregunta dos cosas:

- **Chat id a usar** — Enter para usar el de `config.txt`, o pegás otro. Sirve para
  probar el envío **a un grupo** sin tener que modificar `config.txt` ni el programa
  principal.
- **Texto del mensaje** — Enter para uno por defecto, o escribís el que quieras.

Es la prueba para usar cuando querés verificar que los mensajes llegan a donde tienen
que llegar, sin esperar a que se calcule toda la lista de compras.

---

## Qué hacer cuando algo falla

| Qué ves | Qué pasa |
|---|---|
| Se abre Chrome y la pregunta aparece en un popup | Te faltó el `-n`. Usá los lanzadores `.cmd` / `.sh`. |
| `No se selecciono ninguna comida valida` | Escribiste una opción que no es 1, 2 ni 3, o un número de comida fuera de la lista. |
| `ADVERTENCIA: <comida> no esta en BaseDatos.csv` | Esa comida está en `Menu.csv` pero no tiene receta cargada. No es un error grave: el resto de la lista se calcula igual. |
| Un ingrediente no aparece y debería | Fijate que el nombre esté escrito **exactamente igual** en `BaseDatos.csv` y `StockActual.csv` (tildes, mayúsculas y espacios cuentan). O puede ser que el stock ya lo cubra. |
| `No hay nada para comprar` cuando esperabas una lista | El stock cubre todo lo que elegiste, o no seleccionaste ninguna comida válida. |
| `ERROR al enviar por Telegram` | Corré `pruebas/prueba_conexion.tag -n` para saber si el problema es el token. Si el token está bien, revisá el chat_id. |
| La respuesta de Telegram viene vacía `[]` | Se borró de algún `.tag` la línea de comentario que contiene el texto `api http`. Es obligatoria — está explicado en el encabezado de cada script y en [`contexto.md`](../contexto.md). |
| `cannot find file ../data/...` | Se movió algún archivo de lugar. TagUI resuelve las rutas **relativas al `.tag`**, no a la carpeta desde donde ejecutás. |
