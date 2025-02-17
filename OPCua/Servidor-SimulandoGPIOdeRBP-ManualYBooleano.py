import os
import time
import logging

from opcua import Server, ua

# Opcional: bajar nivel de logs para ocultar avisos "attribute is missing"
# logging.basicConfig(level=logging.WARNING)
# logging.getLogger("opcua").setLevel(logging.WARNING)

GPIO_BASE_PATH = "/tmp/rbp-gpio-simul/"

# Diccionarios originales de entradas y salidas
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

# ------------------------------------------------------------------------
# DICCIONARIO DE DEFINICIONES MANUALES:
#   Clave: el plc_var (p.ej. "%IX0.0", "%QX0.0", etc.)
#   Valor: opciones especiales (tipo OPC UA, valor inicial, descripción, etc.)
#   -> Si un nodo aparece aquí, se creará con estos ajustes.
#   -> Si no aparece, se crea como Boolean por defecto.
# ------------------------------------------------------------------------
manual_configs = {
  # Ejemplo: este nodo de entrada se define manualmente como Float
  "%IX0.2": {
    "opcua_type": ua.ObjectIds.Float,
    "initial_value": 12.34,
    "description": "Entrada manual definida como Float"
  },
  # Otro ejemplo: este nodo de salida lo definimos como Int16
  "%QX0.1": {
    "opcua_type": ua.ObjectIds.Int16,
    "initial_value": 0,
    "description": "Salida manual definida como Int16"
  },
  # Puedes añadir más definiciones manuales aquí
}

# ------------------------------------------------------------------------
# FUNCIONES DE LECTURA Y ESCRITURA DE GPIO
# ------------------------------------------------------------------------
def read_gpio_as_type(pin, opcua_type):
  """
  Lee el valor desde //tmp/rbp-gpio-simul/gpio{pin}/value
  y lo convierte al tipo OPC UA que necesites (Boolean, Float, Int, etc.).
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
    # Por defecto, lo tratamos como int o string
    # Ajusta aquí si quieres manejar Strings, Double, etc.
    try:
      return int(raw)
    except ValueError:
      return raw

def write_gpio_as_type(pin, value, opcua_type):
  """
  Escribe 'value' en //tmp/rbp-gpio-simul/gpio{pin}/value,
  formateado según sea Boolean, Float, Int, etc.
  """
  path = f"{GPIO_BASE_PATH}/gpio{pin}/value"
  try:
    if opcua_type == ua.ObjectIds.Boolean:
      to_write = "1" if value else "0"
    elif opcua_type == ua.ObjectIds.Float:
      to_write = str(float(value))
    else:
      to_write = str(int(value))

    with open(path, "w") as f:
      f.write(to_write)
  except FileNotFoundError:
    pass

# ------------------------------------------------------------------------
# FUNCION PARA CREAR NODOS OPC UA CON ATRIBUTOS
# ------------------------------------------------------------------------
def add_variable_with_attributes(parent, nodeid, browsename, initial_value, opcua_type, description=""):
  """
  Crea un nodo OPC UA con varios atributos (DataType, ValueRank, etc.)
  para reducir avisos de 'missing attribute' en UaExpert.
  """
  node = parent.add_variable(nodeid, browsename, initial_value)
  node.set_writable()

  # DataType
  node.set_attribute(
    ua.AttributeIds.DataType,
    ua.DataValue(ua.Variant(ua.NodeId(opcua_type), ua.VariantType.NodeId))
  )

  # ValueRank => -1 => Escalar
  node.set_attribute(
    ua.AttributeIds.ValueRank,
    ua.DataValue(ua.Variant(-1, ua.VariantType.Int32))
  )

  # ArrayDimensions => vacío (no array)
  node.set_attribute(
    ua.AttributeIds.ArrayDimensions,
    ua.DataValue(ua.Variant([], ua.VariantType.UInt32))
  )

  # AccessLevel => Leer/Escribir
  node.set_attribute(
    ua.AttributeIds.AccessLevel,
    ua.DataValue(ua.Variant(
      ua.AccessLevel.CurrentRead | ua.AccessLevel.CurrentWrite,
      ua.VariantType.Byte
    ))
  )

  # UserAccessLevel => Leer/Escribir
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

  # Valor inicial
  node.set_attribute(
    ua.AttributeIds.Value,
    ua.DataValue(ua.Variant(initial_value))
  )

  return node

# ------------------------------------------------------------------------
#  CREACION DEL SERVIDOR
# ------------------------------------------------------------------------
server = Server()
server.set_endpoint("opc.tcp://0.0.0.0:4840/freeopcua/server/")

uri = "http://example.org/gpio"
idx = server.register_namespace(uri)

# Diccionario para guardar la info de cada nodo OPC UA
# { plc_var: {"node": ..., "pin": ..., "opcua_type": ..., "direction": ...} }
gpio_nodes = {}

# ------------------------------------------------------------------------
#  PROCESAR ENTRADAS
# ------------------------------------------------------------------------
for pin, plc_var in vGpiosDeEntrada.items():
  # Miramos si hay definición manual para este plc_var
  if plc_var in manual_configs:
    cfg = manual_configs[plc_var]
    opcua_type = cfg.get("opcua_type", ua.ObjectIds.Boolean)
    init_val = cfg.get("initial_value", False)
    desc = cfg.get("description", "")
  else:
    # Por defecto booleano
    opcua_type = ua.ObjectIds.Boolean
    init_val = False
    desc = f"Entrada digital {plc_var}"

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
    "direction": "in"   # entradas => se lee del fichero -> se setea en OPC UA
  }

# ------------------------------------------------------------------------
#  PROCESAR SALIDAS
# ------------------------------------------------------------------------
for pin, plc_var in vGpiosDeSalida.items():
  # Miramos si hay definición manual para este plc_var
  if plc_var in manual_configs:
    cfg = manual_configs[plc_var]
    opcua_type = cfg.get("opcua_type", ua.ObjectIds.Boolean)
    init_val = cfg.get("initial_value", False)
    desc = cfg.get("description", "")
  else:
    # Por defecto booleano
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
    "direction": "out"  # salidas => se escribe del OPC UA al fichero
  }

# ------------------------------------------------------------------------
# INICIAR SERVIDOR
# ------------------------------------------------------------------------
server.start()
print("Servidor OPC UA iniciado...")

try:
  while True:
    # Bucle principal de actualización
    for plc_var, data in gpio_nodes.items():
      node = data["node"]
      pin = data["pin"]
      opcua_type = data["opcua_type"]
      direction = data["direction"]

      if direction == "in":
        # Leer desde fichero y actualizar el nodo
        real_value = read_gpio_as_type(pin, opcua_type)
        current_opc_val = node.get_value()
        if real_value != current_opc_val:
          node.set_value(real_value)

      else:  # direction == "out"
        # Tomar el valor del nodo y escribirlo al fichero
        current_opc_val = node.get_value()
        real_value = read_gpio_as_type(pin, opcua_type)
        if current_opc_val != real_value:
          write_gpio_as_type(pin, current_opc_val, opcua_type)

    time.sleep(1)

except KeyboardInterrupt:
  print("\nDeteniendo servidor...")

except Exception as e:
  print(f"\nError inesperado: {e}")

finally:
  server.stop()
  print("Servidor detenido correctamente.")
