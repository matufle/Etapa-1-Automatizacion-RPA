#!/bin/sh
# Lanzador para Linux / macOS.
# El -n hace que TagUI corra sin abrir Chrome, para que las preguntas
# salgan por consola y no en un popup del navegador.
cd "$(dirname "$0")"
tagui compras.tag -n
