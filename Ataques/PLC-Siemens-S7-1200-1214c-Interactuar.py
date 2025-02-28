#!/usr/bin/env python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para interactuar con un PLC Siemens S7-1200, versión 1214c
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/PLC-Siemens-S7-1200-1214c-Interactuar.py | python3 -
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/PLC-Siemens-S7-1200-1214c-Interactuar.py | nano -
# ----------

import curses
import time

def accion_opcion_1(stdscr):
  stdscr.clear()
  # Aquí puedes colocar la serie de acciones que necesites para la opción 1
  stdscr.addstr(0, 0, "Ejecutando acción de la Opción 1...")
  stdscr.refresh()
  # Simulamos una acción con una espera
  time.sleep(2)

def accion_opcion_2(stdscr):
  stdscr.clear()
  # Aquí puedes colocar las acciones correspondientes a la opción 2
  stdscr.addstr(0, 0, "Ejecutando acción de la Opción 2...")
  stdscr.refresh()
  # Simulamos otra acción con una espera
  time.sleep(2)

def main(stdscr):
  # Ocultamos el cursor y configuramos el par de colores para resaltar la opción seleccionada
  curses.curs_set(0)
  curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_WHITE)

  # Definimos las opciones del menú
  menu = [
    "Encender salida 0",
    "  Apagar salida 0",
    "Encender salida 1",
    "  Apagar salida 1",
    "Encender salida 2",
    "  Apagar salida 2",
    "Encender salida 3",
    "  Apagar salida 3",
    "Encender salida 4",
    "  Apagar salida 4",
    "Encender salida 5",
    "  Apagar salida 5",
    "Encender salida 6",
    "  Apagar salida 6",
    "Encender salida 7",
    "  Apagar salida 7",
    "Encender salida 8",
    "  Apagar salida 8",
    "Encender salida 9",
    "  Apagar salida 9",
    "Salir"
  ]
  current_row = 0

  while True:
    stdscr.clear()
    height, width = stdscr.getmaxyx()

    # Mostramos el menú centrado en la pantalla
    for idx, row in enumerate(menu):
      x = width // 2 - len(row) // 2
      y = height // 2 - len(menu) // 2 + idx
      if idx == current_row:
        stdscr.attron(curses.color_pair(1))
        stdscr.addstr(y, x, row)
        stdscr.attroff(curses.color_pair(1))
      else:
        stdscr.addstr(y, x, row)
    stdscr.refresh()

    key = stdscr.getch()

    # Control de teclas para navegar
    if key == curses.KEY_UP and current_row > 0:
      current_row -= 1
    elif key == curses.KEY_DOWN and current_row < len(menu) - 1:
      current_row += 1
    elif key in [curses.KEY_ENTER, 10, 13]:
      # Al presionar Enter, verificamos la opción seleccionada
      if menu[current_row] == "Salir":
        break
      elif menu[current_row] == "Encendiendo salida 0":
        accion_opcion_1(stdscr)
      elif menu[current_row] == "Apagando salida 0":
        accion_opcion_2(stdscr)
      elif menu[current_row] == "Encendiendo salida 1":
        accion_opcion_1(stdscr)
      elif menu[current_row] == "Apagando salida 1":
        accion_opcion_2(stdscr)
      elif menu[current_row] == "Encendiendo salida 2":
        accion_opcion_1(stdscr)
      elif menu[current_row] == "Apagando salida 2":
        accion_opcion_2(stdscr)
      elif menu[current_row] == "Encendiendo salida 3":
        accion_opcion_1(stdscr)
      elif menu[current_row] == "Apagando salida 3":
        accion_opcion_2(stdscr)
      elif menu[current_row] == "Encendiendo salida 4":
        accion_opcion_1(stdscr)
      elif menu[current_row] == "Apagando salida 4":
        accion_opcion_2(stdscr)
      elif menu[current_row] == "Encendiendo salida 5":
        accion_opcion_1(stdscr)
      elif menu[current_row] == "Apagando salida 5":
        accion_opcion_2(stdscr)
      elif menu[current_row] == "Encendiendo salida 6":
        accion_opcion_1(stdscr)
      elif menu[current_row] == "Apagando salida 6":
        accion_opcion_2(stdscr)
      elif menu[current_row] == "Encendiendo salida 7":
        accion_opcion_1(stdscr)
      elif menu[current_row] == "Apagando salida 7":
        accion_opcion_2(stdscr)
      elif menu[current_row] == "Encendiendo salida 8":
        accion_opcion_1(stdscr)
      elif menu[current_row] == "Apagando salida 8":
        accion_opcion_2(stdscr)
      elif menu[current_row] == "Encendiendo salida 9":
       accion_opcion_1(stdscr)
      elif menu[current_row] == "Apagando salida 9":
        accion_opcion_2(stdscr)


  # Mensaje final antes de salir
  stdscr.clear()
  stdscr.addstr(0, 0, "Saliendo del programa...")
  stdscr.refresh()

if __name__ == "__main__":
  curses.wrapper(main)

