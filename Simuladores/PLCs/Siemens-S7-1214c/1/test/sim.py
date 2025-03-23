#!/usr/bin/env python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para simular un PLC Siemens S7-1200, versión 1214c
#
# Ejecución remota (puede requerir permisos sudo):
#   wget -q -N --no-cache https://raw.githubusercontent.com/nipegun/Zubiri/refs/heads/main/CETI/SegInd/zubiri-test/sim.py && sudo python3 sim.py
#
# Bajar y editar directamente el archivo en nano:
#   curl -sL https://raw.githubusercontent.com/nipegun/Zubiri/refs/heads/main/CETI/SegInd/zubiri-test/sim.py | nano -
# ----------

import socket
import struct

# Definir constantes para colores
cColorAzul =      '\033[0;34m'
cColorAzulClaro = '\033[1;34m'
cColorVerde =     '\033[1;32m'
cColorRojo =      '\033[1;31m'
cFinColor =       '\033[0m'     # Vuelve al color normal


# Función para obtener la IP local
def fObtenerIPLocal():
  s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  try:
    s.connect(('8.8.8.8', 80))
    vIPLocal = s.getsockname()[0]
  except Exception:
    vIPLocal = '127.0.0.1'
  finally:
    s.close()
  return vIPLocal


# Función principal para gestionar las conexiones de clientes
def fGestionarCliente(pSocketConCliente):
  try:
    # Recibir el primer payload para determinar qué tipo de comunicación es
    vPrimerPayload = pSocketConCliente.recv(1024)
    if not vPrimerPayload:
      return  # Desconexión del cliente
    
    vPrimerPayloadHex = vPrimerPayload.hex()
    
    # Determinar el tipo de comunicación y derivar a la función correspondiente
    if vPrimerPayloadHex == '030000231ee00000006400c1020600c20f53494d415449432d524f4f542d4553c0010a':
      print(cColorAzulClaro + "\n    Iniciando comunicación para encendido/apagado del PLC\n" + cFinColor)
      fGestEncApagPLC(pSocketConCliente, vPrimerPayload)
    elif vPrimerPayloadHex == '0300001611e00000cfc400c0010ac1020100c2020101':
      print(cColorAzulClaro + "\n    Iniciando comunicación para encendido/apagado de salida\n" + cFinColor)
      fGestEncApagSalida(pSocketConCliente, vPrimerPayload)
    else:
      print("      Envió payload desconocido:")
      print(f"        {vPrimerPayloadHex}")
      # Aquí se podría añadir lógica para otros tipos de comunicación en el futuro

  except Exception as e:
    print(f"Error en comunicación: {e}")
  finally:
    pSocketConCliente.close()
    print(cColorRojo + "\n    Cliente desconectado.\n" + cFinColor)

# Función para gestionar el encendido y apagado del PLC
def fGestEncApagPLC(pSocketConCliente, pPrimerPayload):
  vEstadoEncendido = 0
  
  # Procesar el primer payload
  vPayloadHex = pPrimerPayload.hex()
  
  if vPayloadHex == '030000231ee00000006400c1020600c20f53494d415449432d524f4f542d4553c0010a':
    # Respuesta al primer payload (COTP_RQ)
    vTipoDeSolicitud = 'Solicitud de comunicación COTP para encendido/apagado del PLC.'
    print("      Envió:")
    print(f"        {vPayloadHex}")
    print("      Tipo de solicitud:")
    print("        " + vTipoDeSolicitud)
    vRespuesta = bytearray.fromhex('030000231ed00064000b00c0010ac1020600c20f53494d415449432d524f4f542d4553')
    pSocketConCliente.send(vRespuesta)
    print("      Se le respondió:")
    print("        " +  str(vRespuesta.hex()))
    vEstadoEncendido = 1
  
  # Continuar recibiendo y procesando los demás payloads
  try:
    while True:
      vPayload = pSocketConCliente.recv(1024)
      if not vPayload:
        break  # Desconexión del cliente

      vPayloadHex = vPayload.hex()
      
      if vEstadoEncendido == 1 and vPayloadHex == '030000ee02f080720100df31000004ca0000000100000120360000011d00040000000000a1000000d3821f0000a3816900151553657276657253657373696f6e5f31433943333846a38221001532302e302e302e303a305265616c74656b20555342204762452046616d696c7920436f6e74726f6c6c65722e54435049502e33a38228001500a38229001500a3822a0015194445534b544f502d494e414d4455385f313432323331343036a3822b000401a3822c001201c9c38fa3822d001500a1000000d3817f0000a38169001515537562736372697074696f6e436f6e7461696e6572a2a20000000072010000':
        # Respuesta al segundo payload (S7_COMM_RQ)
        vTipoDeSolicitud = 'Solicitud de comunicación S7comm para encendido del PLC.'
        print("      Envió:")
        print(f"        {vPayloadHex}")
        print("      Tipo de solicitud:")
        print("        " + vTipoDeSolicitud)
        vRespuesta = bytearray.fromhex('0361f89bc8f607501810004f8800000300008902f0807201007a32000004ca0000000136110287248711a100000120821f0000a38169001500a3823200170000013a823b00048200823c00048140823d00048480c040823e00048480c040823f00151b313b36455337203231342d31414533302d30584230203b56322e328240001505323b37393482410003000300a20000000072010000')
        pSocketConCliente.send(vRespuesta)
        print("      Se le respondió:")
        print("        " +  str(vRespuesta.hex()))
        vEstadoEncendido = 2
      
      elif vEstadoEncendido == 2 and vPayloadHex == '0300008f02f08072020080310000054200000002000003b834000003b8010182320100170000013a823b00048200823c00048140823d00048480c040823e00048480c040823f001500824000151a313b36455337203231342d31414533302d305842303b56322e328241000300030000000004e88969001200000000896a001300896b000400000000000072020000':
        # Respuesta al tercer payload (S7_COMM_ANTI)
        vTipoDeSolicitud = 'Anti-replay para encendido del PLC.'
        print("      Envió:")
        print(f"        {vPayloadHex}")
        print("      Tipo de solicitud:")
        print("        " + vTipoDeSolicitud)
        vRespuesta = bytearray.fromhex('0361f89bc8f607501810004f8800000300008902f0807201007a32000004ca0000000136110287248711a100000120821f0000a38169001500a3823200170000013a823b00048200823c00048140823d00048480c040823e00048480c040823f00151b313b36455337203231342d31414533302d30584230203b56322e328240001505323b37393482410003000300a20000000072010000')
        pSocketConCliente.send(vRespuesta)
        print("      Se le respondió:")
        print("        " +  str(vRespuesta.hex()))
        vEstadoEncendido = 3
      
      elif vEstadoEncendido == 3 and vPayloadHex == '0300004302f0807202003431000004f200000010000003ca3400000034019077000803000004e88969001200000000896a001300896b00040000000000000072020000':
        # Respuesta al cuarto payload (START7)
        vTipoDeSolicitud = 'Comando START7 para encendido del PLC.'
        print("      Envió:")
        print(f"        {vPayloadHex}")
        print("      Tipo de solicitud:")
        print("        " + vTipoDeSolicitud)
        vRespuesta = bytearray.fromhex('0361f89bc8f607501810004f8800000300008902f0807201007a32000004ca0000000136110287248711a100000120821f0000a38169001500a3823200170000013a823b00048200823c00048140823d00048480c040823e00048480c040823f00151b313b36455337203231342d31414533302d30584230203b56322e328240001505323b37393482410003000300a20000000072010000')
        pSocketConCliente.send(vRespuesta)
        print("      Se le respondió:")
        print("        " +  str(vRespuesta.hex()))
        print(cColorVerde + "\n      PLC encendido correctamente\n" + cFinColor)
        vEstadoEncendido = 0  # Reiniciar el estado para futuras secuencias
      
      # Si no coincide con ninguno de los patrones conocidos, mostrar información genérica
      else:
        print("      Envió payload desconocido:")
        print(f"        {vPayloadHex}")
        # Enviar una respuesta genérica o ninguna respuesta según sea apropiado

  except Exception as e:
    print(f"Error en comunicación (encendido/apagado PLC): {e}")


# Función para gestionar el encendido y apagado de salidas
def fGestEncApagSalida(pSocketConCliente, pPrimerPayload):
  vPayloadHex = pPrimerPayload.hex()
  
  if vPayloadHex == '0300001611e00000cfc400c0010ac1020100c2020101':
    # Respuesta al primer payload (COTP para salidas)
    vTipoDeSolicitud = 'Solicitud de comunicación COTP para encendido/apagado de salida.'
    print("      Envió:")
    print(f"        {vPayloadHex}")
    print("      Tipo de solicitud:")
    print("        " + vTipoDeSolicitud)
    vRespuesta = bytearray.fromhex('0300001611d0cfc4000900c0010ac1020100c2020101')
    pSocketConCliente.send(vRespuesta)
    print("      Se le respondió:")
    print("        " +  str(vRespuesta.hex()))
  
  # Continuar recibiendo y procesando los demás payloads
  try:
    while True:
      vPayload = pSocketConCliente.recv(1024)
      if not vPayload:
        break  # Desconexión del cliente

      vPayloadHex = vPayload.hex()
      
      # Procesar solicitud S7 para salidas
      if vPayloadHex == '0300001902f08032010000000000080000f0000008000803c0':
        vTipoDeSolicitud = 'Solicitud S7 para encendido/apagado de salida.'
        print("      Envió:")
        print(f"        {vPayloadHex}")
        print("      Tipo de solicitud:")
        print("        " + vTipoDeSolicitud)
        vRespuesta = bytearray.fromhex('0300001b02f080320100000000000801000001000008000803c0010001')
        pSocketConCliente.send(vRespuesta)
        print("      Se le respondió:")
        print("        " +  str(vRespuesta.hex()))
      
      # Procesar comandos de encendido de salidas (Q0.0 - Q0.9)
      elif vPayloadHex.startswith('0300002502f08032010000001f000e00060501120a10010001000082000') and vPayloadHex.endswith('0300010100'):
        vNumeroSalida = vPayloadHex[68:69]  # Extraer el número de salida del payload
        vTipoDeSolicitud = f'Comando para encender salida Q0.{vNumeroSalida}'
        print("      Envió:")
        print(f"        {vPayloadHex}")
        print("      Tipo de solicitud:")
        print("        " + vTipoDeSolicitud)
        vRespuesta = bytearray.fromhex('0300000902f00000')
        pSocketConCliente.send(vRespuesta)
        print("      Se le respondió:")
        print("        " +  str(vRespuesta.hex()))
        print(cColorVerde + f"\n      Salida Q0.{vNumeroSalida} encendida correctamente\n" + cFinColor)
      
      # Procesar comandos de apagado de salidas (Q0.0 - Q0.9)
      elif vPayloadHex.startswith('0300002502f08032010000001f000e00060501120a10010001000082000') and vPayloadHex.endswith('0300010000'):
        vNumeroSalida = vPayloadHex[68:69]  # Extraer el número de salida del payload
        vTipoDeSolicitud = f'Comando para apagar salida Q0.{vNumeroSalida}'
        print("      Envió:")
        print(f"        {vPayloadHex}")
        print("      Tipo de solicitud:")
        print("        " + vTipoDeSolicitud)
        vRespuesta = bytearray.fromhex('0300000902f00000')
        pSocketConCliente.send(vRespuesta)
        print("      Se le respondió:")
        print("        " +  str(vRespuesta.hex()))
        print(cColorVerde + f"\n      Salida Q0.{vNumeroSalida} apagada correctamente\n" + cFinColor)
      
      # Si no coincide con ninguno de los patrones conocidos, mostrar información genérica
      else:
        print("      Envió payload desconocido:")
        print(f"        {vPayloadHex}")
        # Enviar una respuesta genérica o ninguna respuesta según sea apropiado

  except Exception as e:
    print(f"Error en comunicación (encendido/apagado salida): {e}")


if __name__ == "__main__":
  # Obtener IP local
  vIPLocal = fObtenerIPLocal()

  # Configurar el servidor TCP en el puerto 102 (S7comm)
  vSocketServidor = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  vSocketServidor.bind(("0.0.0.0", 102))
  vSocketServidor.listen(1)

  print(cColorAzulClaro + f"\n  Simulador de PLC Siemens S7-1200 1214c escuchando en el puerto 102" + cFinColor)
  print(cColorAzulClaro + f"  IP Local del servidor: {vIPLocal}\n" + cFinColor)

  # Aceptar conexiones de clientes
  while True:
    client_socket, addr = vSocketServidor.accept()
    print(cColorVerde + f"\n    Cliente conectado desde {addr}.\n" + cFinColor)
    fGestionarCliente(client_socket)
