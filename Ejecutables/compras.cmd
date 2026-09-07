@echo off
rem Lanzador para Windows. Doble click para correr el bot de compras.
rem El -n hace que TagUI corra sin abrir Chrome, para que las preguntas
rem salgan por consola y no en un popup del navegador.
cd /d "%~dp0"
call tagui compras.tag -n
echo.
pause
