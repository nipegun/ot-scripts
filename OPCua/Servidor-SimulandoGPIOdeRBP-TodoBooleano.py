import os
import time
import logging

# Ajusta el nivel de log si quieres suprimir avisos de atributos faltantes:
# logging.basicConfig(level=logging.WARNING)
# logging.getLogger("opcua").setLevel(logging.WARNING)

from opcua import Server, ua

GPIO_BASE_PATH = "/tmp/rbp-gpio-simul/"

vGpiosDeEntrada = {
  2: "%IX0.0", 3: "%IX0.1", 4: "%IX0.2", 17: "%IX0.3", 27: "%IX0.4",
  22: "%IX0.5", 10: "%IX0.6", 9: "%IX0.7", 11: "%IX1.0", 5: "%IX1.1",
  6: "%IX1.2", 13: "%IX1.3", 19: "%IX1.4", 26: "%IX1.5"
}

vGpiosDeSalida = {
  14: "%QX0.0", 15: "%QX0.1", 23: "%QX0.2", 24: "%QX0.3", 25: "%QX0.4",
  8: "%QX0.5", 7: "%QX0.6", 12: "%QX0.7", 16: "%QX1.0", 20: "%QX1.1",
  21: "%QX1.2"
}

def read_gpio(pin):
  """
  Lee el valor (0 o 1) de un GPIO simulado (fichero /tmp/rbp-gpio-simul/gpio{pin}/value).
  Si no existe, devuelve 0.
  """
  path = f"{GPIO_BASE_PATH}/gpio{pin}/value"
  try:
    with open(path, "r") as f:
      return int(f.read().strip())
  except (FileNotFoundError, ValueError):
    return 0

def write_gpio(pin, value):
  """
  Escribe valor (0 o 1) en un GPIO simulado (fichero /tmp/rbp-gpio-simul/gpio{pin}/value).
  Si no existe el fichero, no hace nada.
  """
  path = f"{GPIO_BASE_PATH}/gpio{pin}/value"
  try:
    with open(path, "w") as f:
      f.write(str(value))
  except FileNotFoundError:
    pass

def add_variable_with_attributes(parent, nodeid, browsename, initial_value):
  """
  Crea una variable OPC UA con los atributos básicos y algunos opcionales
  para que UaExpert no muestre avisos de atributos faltantes.
  """
  # Creamos la variable
  node = parent.add_variable(nodeid, browsename, initial_value)
  
  # Aseguramos que sea writable desde clientes OPC UA
  node.set_writable()

  # Atributos recomendados:
  # 1) DataType => Boolean (ns=0, i=1 => ObjectIds.Boolean)
  node.set_attribute(
    ua.AttributeIds.DataType,
    ua.DataValue(ua.Variant(ua.NodeId(ua.ObjectIds.Boolean), ua.VariantType.NodeId))
  )

  # 2) ValueRank => -1 (Escalar)
  node.set_attribute(
    ua.AttributeIds.ValueRank,
    ua.DataValue(ua.Variant(-1, ua.VariantType.Int32))
  )

  # 3) ArrayDimensions => vacío (no es array)
  node.set_attribute(
    ua.AttributeIds.ArrayDimensions,
    ua.DataValue(ua.Variant([], ua.VariantType.UInt32))
  )

  # 4) AccessLevel => Leer/Escribir
  node.set_attribute(
    ua.AttributeIds.AccessLevel,
    ua.DataValue(ua.Variant(
      ua.AccessLevel.CurrentRead | ua.AccessLevel.CurrentWrite,
      ua.VariantType.Byte
    ))
  )

  # 5) UserAccessLevel => Leer/Escribir
  node.set_attribute(
    ua.AttributeIds.UserAccessLevel,
    ua.DataValue(ua.Variant(
      ua.AccessLevel.CurrentRead | ua.AccessLevel.CurrentWrite,
      ua.VariantType.Byte
    ))
  )

  # 6) Description => Texto descriptivo
  node.set_attribute(
    ua.AttributeIds.Description,
    ua.DataValue(ua.LocalizedText(f"Nodo {browsename}"))
  )

  # (Opcional) Fijar manualmente el Value por si se requiere
  node.set_attribute(
    ua.AttributeIds.Value,
    ua.DataValue(ua.Variant(bool(initial_value), ua.VariantType.Boolean))
  )

  return node

# Crear servidor OPC UA
server = Server()
server.set_endpoint("opc.tcp://0.0.0.0:4840/freeopcua/server/")

uri = "http://example.org/gpio"
idx = server.register_namespace(uri)

gpio_nodes = {}

# Añadimos nodos OPC UA para entradas
for pin, plc_var in vGpiosDeEntrada.items():
  nodeid = ua.NodeId(plc_var, idx)   # NodeId de tipo String en nuestro namespace
  browsename = f"{plc_var} (GPIO{pin})"

  gpio_nodes[plc_var] = add_variable_with_attributes(
    server.nodes.objects, nodeid, browsename, 0
  )

# Añadimos nodos OPC UA para salidas
for pin, plc_var in vGpiosDeSalida.items():
  nodeid = ua.NodeId(plc_var, idx)
  browsename = f"{plc_var} (GPIO{pin})"

  gpio_nodes[plc_var] = add_variable_with_attributes(
    server.nodes.objects, nodeid, browsename, 0
  )

# Iniciamos el servidor
server.start()
print("Servidor OPC UA iniciado...")

try:
  while True:
    # Leer y actualizar las entradas
    for pin, plc_var in vGpiosDeEntrada.items():
      value = read_gpio(pin)
      gpio_nodes[plc_var].set_value(bool(value))

    # Leer y actualizar las salidas (cliente -> fichero)
    for pin, plc_var in vGpiosDeSalida.items():
      node = gpio_nodes[plc_var]
      opcua_value = node.get_value()     # Valor que el cliente escribió en el nodo
      file_value = read_gpio(pin)        # Valor real que tenemos en fichero

      if opcua_value != bool(file_value):
        write_gpio(pin, int(opcua_value))

    time.sleep(1)

except KeyboardInterrupt:
  print("\nDeteniendo servidor...")

except Exception as e:
  print(f"\nError inesperado: {e}")

finally:
  server.stop()
  print("\n  Servidor detenido correctamente. \n")

# Para modificar valores:
# Booleanos:
#   echo 1 > /tmp/rbp-gpio-simul/gpio22/value
