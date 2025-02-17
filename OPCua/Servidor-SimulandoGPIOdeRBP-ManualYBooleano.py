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

def add_variable_with_attributes(parent, nodeid, browsename, initial_value, opcua_type, description=""):
  node = parent.add_variable(nodeid, browsename, initial_value)
  node.set_writable()

  node.set_attribute(
    ua.AttributeIds.DataType,
    ua.DataValue(ua.Variant(ua.NodeId(opcua_type), ua.VariantType.NodeId))
  )

  node.set_attribute(
    ua.AttributeIds.ValueRank,
    ua.DataValue(ua.Variant(-1, ua.VariantType.Int32))  # -1 => Escalar
  )

  node.set_attribute(
    ua.AttributeIds.ArrayDimensions,
    ua.DataValue(ua.Variant([], ua.VariantType.UInt32))
  )

  node.set_attribute(
    ua.AttributeIds.AccessLevel,
    ua.DataValue(ua.Variant(
      ua.AccessLevel.CurrentRead | ua.AccessLevel.CurrentWrite,
      ua.VariantType.Byte
    ))
  )

  node.set_attribute(
    ua.AttributeIds.UserAccessLevel,
    ua.DataValue(ua.Variant(
      ua.AccessLevel.CurrentRead | ua.AccessLevel.CurrentWrite,
      ua.VariantType.Byte
    ))
  )

  node.set_attribute(
    ua.AttributeIds.Description,
    ua.DataValue(ua.LocalizedText(description))
  )

  node.set_attribute(
    ua.AttributeIds.Value,
    ua.DataValue(ua.Variant(initial_value))
  )

  return node

# ------------------------------------------------------------------------------
# Crear servidor
# ------------------------------------------------------------------------------
server = Server()
server.set_endpoint("opc.tcp://0.0.0.0:4840/freeopcua/server/")

uri = "http://example.org/gpio"
idx = server.register_namespace(uri)

gpio_nodes = {}

# ------------------------------------------------------------------------------
# Crear nodos de ENTRADA (%IX...), direction = "in"
# ------------------------------------------------------------------------------

for pin, plc_var in vGpiosDeEntrada.items():
  if plc_var in manual_configs:
    # Usa definición manual
    cfg = manual_configs[plc_var]
    opcua_type = cfg.get("opcua_type", ua.ObjectIds.Boolean)
    init_val = cfg.get("initial_value", False)
    desc = cfg.get("description", f"Entrada digital {plc_var}")
  else:
    # Por defecto => boolean
    opcua_type = ua.ObjectIds.Boolean
    init_val = False
    desc = f"Entrada digital {plc_var}"

  nodeid = ua.NodeId(plc_var, idx)  # p.ej. (string="%IX0.2", ns=idx)
  browsename = f"{plc_var} (GPIO{pin})"

  node = add_variable_with_attributes(
    server.nodes.objects,
    nodeid,
    browsename,
    init_val,
    opcua_type,
    desc
  )

  gpio_nodes[plc_var] = {
    "node": node,
    "pin": pin,
    "opcua_type": opcua_type,
    "direction": "in"  # %IX => ENTRADA
  }

# ------------------------------------------------------------------------------
# Crear nodos de SALIDA (%QX...), direction = "out"
# ------------------------------------------------------------------------------

for pin, plc_var in vGpiosDeSalida.items():
  if plc_var in manual_configs:
    cfg = manual_configs[plc_var]
    opcua_type = cfg.get("opcua_type", ua.ObjectIds.Boolean)
    init_val = cfg.get("initial_value", False)
    desc = cfg.get("description", f"Salida digital {plc_var}")
  else:
    # Por defecto => boolean
    opcua_type = ua.ObjectIds.Boolean
    init_val = False
    desc = f"Salida digital {plc_var}"

  nodeid = ua.NodeId(plc_var, idx)
  browsename = f"{plc_var} (GPIO{pin})"

  node = add_variable_with_attributes(
    server.nodes.objects,
    nodeid,
    browsename,
    init_val,
    opcua_type,
    desc
  )

  gpio_nodes[plc_var] = {
    "node": node,
    "pin": pin,
    "opcua_type": opcua_type,
    "direction": "out"  # %QX => SALIDA
  }

# ------------------------------------------------------------------------------
# Iniciar el servidor
# ------------------------------------------------------------------------------
server.start()
print("Servidor OPC UA iniciado...")

try:
  while True:
    # Bucle de actualización
    for plc_var, info in gpio_nodes.items():
      node = info["node"]
      pin = info["pin"]
      opcua_type = info["opcua_type"]
      direction = info["direction"]

      if direction == "in":
        # LEER fichero => OPC UA
        real_value = read_gpio_as_type(pin, opcua_type)
        current_val = node.get_value()
        if real_value != current_val:
          node.set_value(real_value)

      else:  # direction == "out"
        # LEER nodo => fichero
        current_val = node.get_value()
        real_value = read_gpio_as_type(pin, opcua_type)
        if current_val != real_value:
          write_gpio_as_type(pin, current_val, opcua_type)

    time.sleep(1)

except KeyboardInterrupt:
  print("\nDeteniendo servidor...")

except Exception as e:
  print(f"\nError inesperado: {e}")

finally:
  server.stop()
  print("Servidor detenido correctamente.")



# Para modificar valores:
# Booleanos:
#   echo 1 > /tmp/rbp-gpio-simul/gpio22/value
# Int64 o Int16:
#   echo 1234567890123456789 > > /tmp/rbp-gpio-simul/gpio22/value
# Double (O coma flotante):
#   echo 3.14159 > /tmp/rbp-gpio-simul/gpio22/value
