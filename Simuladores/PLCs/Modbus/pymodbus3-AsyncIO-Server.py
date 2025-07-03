#!/usr/bin/env python3

# ----------
# Script de NiPeGun para crear un servidor modbus asíncrono con la librería pymodbus 3
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Simuladores/PLCs/Modbus/pymodbus3-AsyncIO-Server.py | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Simuladores/PLCs/Modbus/pymodbus3-AsyncIO-Server.py | sed 's-sudo--g' | python3 -
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Simuladores/PLCs/Modbus/pymodbus3-AsyncIO-Server.py | python3 -
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Simuladores/PLCs/Modbus/pymodbus3-AsyncIO-Server.py | python3 - Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Simuladores/PLCs/Modbus/pymodbus3-AsyncIO-Server.py | nano -
#
# Para desinstalar por completo pymodbus
#   sudo apt-get -y autoremove --purge python3-pymodbus
#
# ----------

# ------------------------
# Comprobaciones iniciales
# ------------------------

import importlib
import subprocess
import sys

# Comprobar que python3-pymodbus esté instaldo
def fAsegurarInstDePaqueteDebian(pNombreDelPaquete):
  try:
    subprocess.run(["dpkg", "-s", pNombreDelPaquete], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
  except subprocess.CalledProcessError:
    print(f"\n[!] El paquete '{pNombreDelPaquete}' de Debian no está instalado. Instalando...\n")
    try:
      subprocess.run(["sudo", "apt-get", "update"], check=True, stdout=subprocess.DEVNULL)
      subprocess.run(["sudo", "apt-get", "install", "-y", pNombreDelPaquete], check=True)
      print(f"\n[+] Paquete '{pNombreDelPaquete}' instalado correctamente.\n")
    except subprocess.CalledProcessError:
      print(f"\n[!] Error al instalar el paquete '{pNombreDelPaquete}'. Saliendo.\n")
      sys.exit(1)
fAsegurarInstDePaqueteDebian("python3-pymodbus")

# Comprobar que pymodbus sea, como mínimo, la versión 3.0.0
def fAsegurarVersionDeModuloPython(pNombreDelModulo, pVersionMayorMinimo, pVersionMayorMaximo):
  try:
    vVersModuloInstalado = importlib.import_module(pNombreDelModulo)
    try:
      from packaging import version
    except ImportError:
      print("\n[!] El módulo 'packaging' no está instalado. Instalando...\n")
      subprocess.check_call([sys.executable, "-m", "pip", "install", "packaging"])
      from packaging import version
    vVersInstalada = getattr(vVersModuloInstalado, "__version__", "0.0.0")
    vParsed = version.parse(vVersInstalada)
    if vParsed.major < pVersionMayorMinimo or vParsed.major >= pVersionMayorMaximo:
      print(f"\n[!] {pNombreDelModulo} {vVersInstalada} detectado. Instalando versión >= {pVersionMayorMinimo}.0.0 y < {pVersionMayorMaximo}.0.0...\n")
      spec = f"{pNombreDelModulo}>={pVersionMayorMinimo}.0.0,<{pVersionMayorMaximo}.0.0"
      subprocess.check_call([sys.executable, "-m", "pip", "install", "--upgrade", spec])
  except ImportError:
    print(f"\n[!] El módulo {pNombreDelModulo} no está instalado. Instalando versión >= {pVersionMayorMinimo}.0.0 y < {pVersionMayorMaximo}.0.0...\n")
    spec = f"{pNombreDelModulo}>={pVersionMayorMinimo}.0.0,<{pVersionMayorMaximo}.0.0"
    subprocess.check_call([sys.executable, "-m", "pip", "install", spec])
fAsegurarVersionDeModuloPython("pymodbus", 3, 4)

# ---
# App
# ---

import argparse
import asyncio
import logging
import socket
import os
from pathlib import Path
from pymodbus.server.async_io import StartAsyncTcpServer
from pymodbus.datastore import ModbusServerContext, ModbusSlaveContext, ModbusSequentialDataBlock
from pymodbus.device import ModbusDeviceIdentification

unit_locks = {}
lock_enabled = False
unit_ids_activas = []

def fComprobarSiPuertoLibre(port):
  with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
      sock.bind(("0.0.0.0", port))
      return True
    except OSError:
      return False

def create_slave_context():
  return ModbusSlaveContext(
    di=ModbusSequentialDataBlock(0, [0]*65536),
    co=ModbusSequentialDataBlock(0, [0]*65536),
    hr=ModbusSequentialDataBlock(0, [0]*65536),
    ir=ModbusSequentialDataBlock(0, [0]*65536),
    zero_mode=True
  )

def configurar_logging(modo):
  if not modo:
    logging.disable(logging.CRITICAL)
    return None

  log_path = Path("modbus_server.log")
  handlers = []

  if "screen" in modo:
    handlers.append(logging.StreamHandler())
  if "file" in modo:
    handlers.append(logging.FileHandler(log_path))

  logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=handlers
  )
  return logging.getLogger("modbus")

async def main():
  global lock_enabled
  parser = argparse.ArgumentParser(description="Servidor Modbus TCP Async con soporte opcional a Unit ID 0 (broadcast).")
  parser.add_argument("--standard", type=int, default=0, help="Cantidad de Unit IDs estándar (1–247)")
  parser.add_argument("--reserved", type=int, default=0, help="Cantidad de Unit IDs reservadas (248–255)")
  parser.add_argument("--port", type=int, default=502, help="Puerto TCP (por defecto: 502)")
  parser.add_argument("--log", choices=["screen", "file", "screen,file"], help="Salida de log: pantalla, archivo o ambos")
  parser.add_argument("--lock", action="store_true", help="Activar protección con locks por Unit ID")
  args = parser.parse_args()

  if args.standard > 247:
    print("\n❌ Máximo permitido para units estándar es 247\n")
    sys.exit(1)
  if args.reserved > 8:
    print("\n❌ Máximo permitido para units reservadas es 8 (IDs 248 a 255)\n")
    sys.exit(1)
  if not fComprobarSiPuertoLibre(args.port):
    if args.port < 1024 and os.geteuid() != 0:
      print(f"\n❌ El puerto {args.port} requiere privilegios de superusuario. Ejecuta el script con sudo o usa --port 1502, por ejemplo.\n")
    else:
      print(f"\n❌ El puerto {args.port} ya está en uso o no se puede usar.\n")
    sys.exit(1)

  lock_enabled = args.lock
  logger = configurar_logging(args.log)

  slaves = {}
  unit_id = 1
  for _ in range(args.standard):
    slaves[unit_id] = create_slave_context()
    unit_ids_activas.append(unit_id)
    if lock_enabled:
      unit_locks[unit_id] = asyncio.Lock()
    unit_id += 1

  unit_id = 248
  for _ in range(args.reserved):
    slaves[unit_id] = create_slave_context()
    unit_ids_activas.append(unit_id)
    if lock_enabled:
      unit_locks[unit_id] = asyncio.Lock()
    unit_id += 1

  if not slaves:
    print("\n❌ No se ha definido ninguna unidad Modbus. Usa --standard N o --reserved N.\n")
    return

  context = ModbusServerContext(slaves=slaves, single=False)

  identity = ModbusDeviceIdentification()
  identity.VendorName = "Simulador"
  identity.ProductCode = "SIM"
  identity.VendorUrl = "http://example.com"
  identity.ProductName = "Servidor Modbus Async"
  identity.ModelName = "v1"
  identity.MajorMinorRevision = "1.0"

  class LoggingRequestHandler:
    async def __call__(self, request):
      peer = request.transport.get_extra_info("peername")
      ip = peer[0] if peer else "desconocido"
      unit_id = request.unit_id
      function = request.function_code

      if logger:
        msg = f"📥 {ip} → Unit {unit_id} - Función {function:#04x}"
        if hasattr(request, "values"):
          msg += f" - Valores escritos: {request.values}"
        elif hasattr(request, "value"):
          msg += f" - Valor escrito: {request.value}"
        elif hasattr(request, "read_address"):
          msg += f" - Dirección lectura: {request.read_address}"
        elif hasattr(request, "address"):
          msg += f" - Dirección: {request.address}"
        logger.info(msg)

      # Soporte de broadcast simulado para unit ID 0
      if unit_id == 0:
        for uid, slave in context.slaves.items():
          if lock_enabled and uid in unit_locks:
            async with unit_locks[uid]:
              await request.execute(slave)
          else:
            await request.execute(slave)
        if logger:
          logger.info(f"\n📤 Broadcast → Ejecutado en {len(context.slaves)} unidades (sin respuesta)\n")
        return None  # no se envía respuesta

      # Normal (unit ID != 0)
      if lock_enabled and unit_id in unit_locks:
        async with unit_locks[unit_id]:
          response = await request.execute()
      else:
        response = await request.execute()

      if logger and hasattr(response, "registers"):
        logger.info(f"\n📤 Respuesta a {ip} → Unit {unit_id}: Valores leídos = {response.registers}\n")

      return response

  resumen = [
    f"\n🟢 Iniciando servidor Modbus TCP en puerto {args.port}",
    f"  • Units estándar: {args.standard}",
    f"  • Units reservadas: {args.reserved}",
    f"  • Locks: {'activados' if lock_enabled else 'desactivados'}",
    f"  • Logging: {args.log if args.log else 'ninguno'}",
    f"  • Unit IDs activas: {', '.join(str(uid) for uid in unit_ids_activas)}",
    f"  • Soporte de Unit ID 0 (broadcast): ACTIVADO"
  ]
  for r in resumen:
    print(r)
    if logger:
      logger.info(r)

  await StartAsyncTcpServer(
    context=context,
    identity=identity,
    address=("0.0.0.0", args.port)
  )

if __name__ == "__main__":
  asyncio.run(main())
