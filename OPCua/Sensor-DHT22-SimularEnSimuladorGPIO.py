#!/usr/bin/env python3
import time
import os
import sys
import random

"""
Script que simula la transmisión de datos del DHT22 en el pin /tmp/gpio/gpioN/value.
- Comprueba primero que exista el archivo para ese pin.
- Envía 40 bits a microsegundos (simulación cruda).
- Al final de cada ciclo (1 seg), escribe "HUM=xx.x;TEMP=yy.y"
  para que sea interpretable fácilmente por un servidor OPC UA o SCADA.
"""

# 1) DEFINIR el pin
PIN_USED = 4  # Modifica este valor al pin que desees
GPIO_PATH = f"/tmp/rbp-gpio-simul/gpio{PIN_USED}/value"

# 2) COMPROBAR que el archivo relacionado a ese pin exista
if not os.path.exists(GPIO_PATH):
  print(f"[ERROR] No existe el archivo para el pin {PIN_USED}: {GPIO_PATH}")
  print("Por favor, crea la carpeta y el archivo:")
  print(f"  sudo mkdir -p /tmp/gpio/gpio{PIN_USED}")
  print(f"  sudo touch {GPIO_PATH}")
  sys.exit(1)

def write_pin(level: int):
  """
  Escribe '0' o '1' en el archivo del pin.
  level = 0 o 1
  """
  with open(GPIO_PATH, "w") as f:
    f.write(str(level))

def send_start_signal():
  """
  Envía la señal de inicio DHT22 simulada:
  - Pin en LOW ~18ms
  - Pin en HIGH ~40us
  """
  # LOW por 18ms
  write_pin(0)
  time.sleep(0.018)

  # HIGH ~40us
  write_pin(1)
  time.sleep(0.00004)

def send_bit(bit: int):
  """
  Envía un bit (0 o 1) con tiempos aproximados del DHT22.
  DHT22:
    - LOW ~50us
    - HIGH ~26us para bit=0
             ~70us para bit=1
  """
  # LOW ~50us
  write_pin(0)
  time.sleep(0.00005)

  # HIGH depende del bit
  write_pin(1)
  if bit == 0:
    # ~26us para bit=0
    time.sleep(0.000026)
  else:
    # ~70us para bit=1
    time.sleep(0.00007)

def send_byte(byte_val: int):
  """
  Envía 8 bits (MSB primero) usando send_bit().
  """
  for i in range(8):
    # Extraer bit 7-i => MSB primero
    bit = (byte_val & (1 << (7 - i))) >> (7 - i)
    send_bit(bit)

def send_data_packet(humidity: int, temperature: int):
  """
  Construye y envía 5 bytes (40 bits):
    - 16 bits de humedad
    - 16 bits de temperatura
    - 8 bits de checksum
  """
  hum_high = (humidity >> 8) & 0xFF
  hum_low  = humidity & 0xFF
  temp_high = (temperature >> 8) & 0xFF
  temp_low  = temperature & 0xFF
  checksum = (hum_high + hum_low + temp_high + temp_low) & 0xFF

  send_byte(hum_high)
  send_byte(hum_low)
  send_byte(temp_high)
  send_byte(temp_low)
  send_byte(checksum)

def simulate_dht22(pin: int):
  """
  Bucle principal:
    - Genera humedad y temperatura ficticias
    - Envía start signal y los 40 bits del protocolo (tiempos microsegundos)
    - Al terminar, sobreescribe el archivo con "HUM=xx.x;TEMP=yy.y"
    - Repite cada 1 segundo
  """
  while True:
    # 1) Generar valores ficticios de humedad y temp
    hum_dec = int(random.uniform(20.0, 90.0) * 10)  # p.ej. 201..899 => 20.1%..89.9%
    tmp_dec = int(random.uniform(15.0, 35.0) * 10)  # p.ej. 150..349 => 15.0º..34.9º

    # 2) Start signal (simulado)
    send_start_signal()

    # 3) El DHT22 “respondería” con ~80us LOW + ~80us HIGH
    write_pin(0)
    time.sleep(0.00008)
    write_pin(1)
    time.sleep(0.00008)

    # 4) Enviar paquete de 40 bits
    send_data_packet(hum_dec, tmp_dec)

    # 5) Sobrescribir el archivo con la lectura final interpretada
    humidity_f = hum_dec / 10.0
    temp_f = tmp_dec / 10.0
    with open(GPIO_PATH, "w") as f:
      # Ej: HUM=54.2;TEMP=23.1
      f.write(f"HUM={humidity_f:.1f};TEMP={temp_f:.1f}")

    # Mostrar en pantalla
    print(f"Enviado => Pin GPIO{pin}, Hum: {humidity_f:.1f}%, Temp: {temp_f:.1f}°C")
    # 6) Esperar 1s antes del siguiente ciclo
    time.sleep(1)

if __name__ == "__main__":
  simulate_dht22(PIN_USED)
