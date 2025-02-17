import os
import time
import logging

from opcua import Server, ua

# Si quieres ocultar avisos "missing attribute":
# logging.basicConfig(level=logging.WARNING)
# logging.getLogger("opcua").setLevel(logging.WARNING)

GPIO_BASE_PATH = "/tmp/rbp-gpio-simul/"

# ------------------------------------------------------------------------------
# 1) Diccionarios originales de ENTRADAS y SALIDAS
#    (todos se crearán, sin inventar nodos nuevos).
# ------------------------------------------------------------------------------
vGpiosDeEntrada = {
  2: "%IX0.0",
  3: "%IX0.1",
  4: "%IX0.2",
  17: "%IX0.3",
  27: "%IX0.4",
  22: "%IX0.5",
  10: "%IX0.6",
  9: "%IX0.7",
  11: "%IX1.0",
  5: "%IX1.1",
  6: "%IX1.2",
  13: "%IX1.3",
  19: "%IX1.4",
  26: "%IX1.5"
}

vGpiosDeSalida = {
  14: "%QX0.0",
  15: "%QX0.1",
  23: "%QX0.2",
  24: "%QX0.3",
  25: "%QX0.4",
  8: "%QX0.5",
  7: "%QX0.6",
  12: "%QX0.7",
  16: "%QX1.0",
  20: "%QX1.1",
  21: "%QX1.2"
}

# ------------------------------------------------------------------------------
# 2) Definiciones “manuales” (OPC UA type, valor inicial, descripción...).
#    - Clave => plc_var ("%IX0.2", "%QX0.1", etc.)
#    - Valor => dict con "opcua_type", "initial_value", "description"
#    - La dirección ("in"/"out") sigue dependiendo de si es %IX o %QX
# ------------------------------------------------------------------------------
manual_configs = {
  # Ejemplo: redefinimos "%IX0.1" como Float en lugar de Boolean
  "%IX0.2": {
    "opcua_type": ua.ObjectIds.Float,
    "initial_value": 12.34,
    "description": "Entrada manual definida como Float"
  },
  # Ejemplo: redefinimos "%IX0.3" como Int16 en lugar de Boolean
  "%IX0.3": {
    "opcua_type": ua.ObjectIds.Int16,
    "initial_value": 0,
    "description": "Salida manual definida como Int16"
  }
}

# ------------------------------------------------------------------------------
# Funciones de lectura/escritura en los ficheros simulados
# ------------------------------------------------------------------------------
def read_gpio_as_type(pin, opcua_type):
  """
  Lee el contenido de /tmp/rbp-gpio-simul/gpio{pin}/value y lo convierte
  a un tipo Python apropiado: Boolean, Float, Int...
  """
  path = f"{GPIO_BASE_PATH}/gpio{pin}/value"
  try:
    with open(path, "r") as f:
      raw = f.read().strip()
  except FileNotFoundError:
    raw = "0"

  if opcua_type == ua.ObjectIds.Boolean:
    return (raw == "1")
  elif opcua_type == ua.ObjectIds.Float:
    try:
      return float(raw)
    except ValueError:
      return 0.0
  elif opcua_type in (ua.ObjectIds.Int16, ua.ObjectIds.Int32, ua.ObjectIds.UInt16, ua.ObjectIds.UInt32):
    try:
      return int(raw)
    except ValueError:
      return 0
  else:
    # Por defecto, intenta int, si falla deja el raw
    try:
      return int(raw)
    except ValueError:
      return raw

def write_gpio_as_type(pin, value, opcua_type):
  """
  Escribe 'value' en /tmp/rbp-gpio-simul/gpio{pin}/value,
  en función del tipo OPC UA (Boolean => "0"/"1", Float => "1.23", etc.).
  """
  path = f"{GPIO_BASE_PATH}/gpio{pin}/value"
  try:
    if opcua_type == ua.ObjectIds.Boolean:
      to_write = "1" if value else "0"
    elif opcua_type == ua.ObjectIds.Float:
      to_write = str(float(value))
    else:
      # Int (Int16, Int32, etc.)
      to_write = str(int(value))

    with open(path, "w") as f:
      f.write(to_write)
  except FileNotFoundError:
    pass

# ------------------------------------------------------------------------------
# Función para crear nodos con atributos, reduciendo warnings en UaExpert
# ------------------------------------------------------------------------------

# Para modificar valores:
# Booleanos:
#   echo 1 > /tmp/rbp-gpio-simul/gpio22/value
# Int64 o Int16:
#   echo 1234567890123456789 > > /tmp/rbp-gpio-simul/gpio22/value
# Double (O coma flotante):
#   echo 3.14159 > /tmp/rbp-gpio-simul/gpio22/value
