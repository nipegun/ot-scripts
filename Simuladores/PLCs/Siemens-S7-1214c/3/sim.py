#!/usr/bin/env python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para interactuar con un PLC Siemens S7-1200, versión 1214c
#
# Ejecución remota (puede requerir permisos sudo):
#   wget -q -N --no-cache https://raw.githubusercontent.com/nipegun/zubiri/refs/heads/main/CETI/SegInd/PLCDeClase-Simular.py && sudo python3 PLCDeClase-Simular.py
#
# Bajar y editar directamente el archivo en nano:
#   curl -sL https://raw.githubusercontent.com/nipegun/zubiri/refs/heads/main/CETI/SegInd/PLCDeClase-Simular.py | nano -
# ----------

import socket
import struct

# Definir constantes para colores
cColorAzul =      '\033[0;34m'
cColorAzulClaro = '\033[1;34m'
cColorVerde =     '\033[1;32m'
cColorRojo =      '\033[1;31m'
cFinColor =       '\033[0m'     # Vuelve al color normal

# Definir la memoria del PLC simulado
E = bytearray(2)   # Entradas digitales %I0.0 - %I0.13
A = bytearray(2)   # Salidas digitales %Q0.0 - %Q0.9
DB1 = bytearray(1024)  # Simula una DB interna del PLC

# Configurar el servidor TCP en el puerto 102 (S7comm)
vSocketServidor = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
vSocketServidor.bind(("0.0.0.0", 102))
vSocketServidor.listen(1)

print(cColorAzulClaro + "\n  Simulador de PLC Siemens S7-1200 1214c escuchando en el puerto 102...\n" + cFinColor)

def fGestionarCliente(pSocketConCliente):
  """ Maneja la comunicación con un cliente S7 (TIA Portal, WinCC, SCADA). """
  try:
    while True:
      vPayload = pSocketConCliente.recv(1024)
      if not vPayload:
        break  # Desconexión del cliente

      # Solicitud de comunicación COTP para encendido/apagado del PLC
      # El cliente debe enviar algo como          '0300001611e00000000100c0010ac1020102c2020100c00109'
      # El servidor debe responder con algo como: '0300001611d00001000100c0010ac1020102c2020100c00109

      # Solicitud de comunicación COTP para encendido/apagado del PLC)
      # Payload TCP:         03 00 00 23 1e e0 00 00 00 64 00 c1 02 06 00 c2 0f 53 49 4d 41 54 49 43 2d 52 4f 4f 54 2d 45 53 c0 01 0a
      #   TPKT:              03 00 00 23
      #     Version (3):     03
      #     Reserved (0):       00
      #     Lenght (35):           00 23
      #   COTP:                          1e e0 00 00 00 64 00 c1 02 06 00 c2 0f 53 49 4d 41 54 49 43 2d 52 4f 4f 54 2d 45 53 c0 01 0a
      #     Length (30):                 1e
      #     PDU Connect Request (0x0e):     e0
      #     Destination reference (0x0000):    00 00
      #     Source reference (0x0064):               00 64 
      #     Class (0):                                     00 
      #     Parameter code src-tsap (0xc1):                   c1
      #     Parameter lenght (2):                                02
      #     Source TSAP (0600):                                     06 00
      #     Parameter code dst-tsap (0xc2):                               c2
      #     Parameter lenght (15):                                           0f
      #     Destination TSAP (SIMATIC-ROOT-ES):                                 53 49 4d 41 54 49 43 2d 52 4f 4f 54 2d 45 53
      #     Parameter code tpdu-size (0xc0):                                                                                 c0
      #     Parameter lenght (1):                                                                                               01
      #     TPDU size (1024):                                                                                                      0a
      if vPayload.hex() == '030000231ee00000006400c1020600c20f53494d415449432d524f4f542d4553c0010a':
        vTipoSolicitud = '(Solicitud de comunicación COTP para encendido/apagado del PLC).'
        print(f"      Envió: {vPayload.hex()} " + vTipoSolicitud)
        vRespuestaCOTP = b'\x03\x00\x00\x23\x1e\xd0\x00\x64\x00\x0b\x00\xc0\x01\x0a\xc1\x02\x06\x00\xc2\x0f\x53\x49\x4d\x41\x54\x49\x43\x2d\x52\x4f\x4f\x54\x2d\x45\x53'
        pSocketConCliente.send(vRespuestaCOTP)
        print("        Se le respondió: " + str(vRespuesta.hex()))


      # Solicitud de comunicación COTP para encendido/apagado de salida
      # Payload TCP:         03 00 00 16 11 e0 00 00 cf c4 00 c0 01 0a c1 02 01 00 c2 02 01 01
      #   TPKT:              03 00 00 16
      #     Version (3):     03
      #     Reserved (0):       00
      #     Lenght (22):           00 16
      #   COTP:                          11 e0 00 00 cf c4 00 c0 01 0a c1 02 01 00 c2 02 01 01
      #     Length (17):                 11
      #     PDU Connect Request (0x0e):     e0
      #     Destination reference (0x0000):    00 00
      #     Source reference (0xcfc4):               cf c4 
      #     Class (0):                                     00 
      #     Parameter code tpdu-size (0xc0):                  c0
      #     Parameter lenght (1):                                01
      #     TPDU size (1024):                                       0a
      #     Parameter code src-tsap (0xc1):                            c1
      #     Parameter lenght (2):                                         02
      #     Source TSAP (0100):                                              01 00
      #     Parameter code dst-tsap (0xc2):                                        c2
      #     Parameter lenght (2):                                                     02
      #     TPDU size (1024):                                                            01 01
      if vPayload.hex() == '0300001611e00000cfc400c0010ac1020100c2020101':
        vTipoSolicitud = '(Solicitud de comunicación COTP para encendido/apagado de salida).'
        print(f"      Envió: {vPayload.hex()} " + vTipoSolicitud)
        vRespuestaCOTP = b'\x03\x00\x00\x16\x11\xd0\xcf\xc4\x00\x09\x00\xc0\x01\x0a\xc1\x02\x01\x00\xc2\x02\x01\x01'
        pSocketConCliente.send(vRespuestaCOTP)
        print("        Se le respondió: " + str(vRespuesta))

      # Solicitud de comunicación s7comm
      # Payload TCP:        03 00 00 ee 02 f0 80 72 01 00 df 31 00 00 04 ca 00 00 00 01 00 00 01 20 36 00 00 01 1d 00 04 00 00 00 00 00 a1 00 00 00 d3 82 1f 00 00 a3 81 69 00 15 15 53 65 72 76 65 72 53 65 73 73 
      if vPayload.hex() == '030000ee02f080720100df31000004ca0000000100000120360000011d00040000000000a1000000d3821f0000a3816900151553657276657253657373':
        vTipoSolicitud = '(Solicitud de comunicación s7comm para encendido/apagado del PLC).'
        print(f"      Envió: {vPayload.hex()} " + vTipoSolicitud)
        vRespuesta = b'\x03\x00\x00\x16\x11\xe0\x00\x00\x00\x01\x00\xc0\x01\x0a\xc1\x02\x01\x00\xc2\x02\x01\x02'
        pSocketConCliente.send(vRespuesta)
        print("        Se le respondió: " + str(vRespuesta))




      # SETUP COMMUNICATION REQUEST (Configurar conexión S7)
      if vPayload.startswith(b'\x03\x00\x00\x19\x02\xf0\x80\x32'):
        vRespuesta = b'\x03\x00\x00\x1d\x02\xf0\x80\x32\x03\x00\x00\x01\x00\x01\xe0\x00\x00\x01\x00\x01\xe0\x00'
        pSocketConCliente.send(vRespuesta)
        print("      Respondido: Setup Communication")

      # READ REQUEST - Cliente quiere leer memoria del PLC
      if vPayload.startswith(b'\x03\x00\x00\x21\x02\xf0\x80\x32\x07'):
        address = vPayload[-1]  # Último byte contiene la dirección
        
        if address == 0:
          response_data = E
        elif address == 1:
          response_data = A
        elif address == 2:
          response_data = DB1[:4]
        else:
          response_data = b'\x00'

        response = b'\x03\x00\x00\x25\x02\xf0\x80\x32\x07\x00\x00\x00\x04\xff\x04\x00\x00' + response_data
        pSocketConCliente.send(response)
        print(f"      Respondido: Datos de dirección {address}")

      # WRITE REQUEST - Cliente quiere escribir memoria del PLC
      elif vPayload.startswith(b'\x03\x00\x00\x24\x02\xf0\x80\x32\x05'):
        address = vPayload[-5]
        value = vPayload[-1]
        
        if address == 0:
          E[0] = value
        elif address == 1:
          A[0] = value
        elif address == 2:
          DB1[:4] = struct.pack(">I", value)

        response = b'\x03\x00\x00\x1e\x02\xf0\x80\x32\x05\x00\x00\x00\x01\xff\x00'
        pSocketConCliente.send(response)
        print(f"      Respondido: Escritura en dirección {address} con valor {value}")
  
  except Exception as e:
    print(f"Error en comunicación: {e}")
  
  finally:
    pSocketConCliente.close()
    print(cColorRojo + "\n    Cliente desconectado.\n" + cFinColor)

# Aceptar conexiones de clientes
while True:
  client_socket, addr = vSocketServidor.accept()
  print(cColorVerde + f"\n    Cliente conectado desde {addr}.\n" + cFinColor)
  fGestionarCliente(client_socket)
