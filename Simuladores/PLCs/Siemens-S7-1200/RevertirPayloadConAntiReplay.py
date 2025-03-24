def fRevertirAntiReplay(pRespChallenge, pPosHex=46):
  """ Revierte la inserción del valor anti-replay en una cadena hexadecimal, deduciendo el valor original del challenge directamente del string.

  Parámetros:
    pRespChallenge (str): cadena hexadecimal con anti-replay inyectado
    pPosHex (int): posición del primer carácter sobrescrito (por defecto 46)

  Devuelve:
    str: cadena hexadecimal con el byte modificado restaurado
  """
  if len(pRespChallenge) < pPosHex + 4:
    raise ValueError("La cadena es demasiado corta para contener los campos necesarios.")

  # Extraer el challenge desde los caracteres 48–49 (byte 24)
  challenge_hex = pRespChallenge[48:50]
  challenge = int(challenge_hex, 16)

  # Calcular el valor anti-replay (no lo usamos para nada aquí, pero sirve para entender)
  anti_replay = challenge + 0x80

  # Convertimos el challenge original a 2 dígitos hex
  challenge_hex_real = f"{challenge:02x}"

  # Reemplazamos los caracteres modificados (46 y 47) por el byte original
  vRespRestaurado = (
    pRespChallenge[:pPosHex] +
    challenge_hex_real +
    pRespChallenge[pPosHex + 2:]
  )

  return vRespRestaurado

if __name__ == "__main__":
  vCadenaConAntiReplayInyectado = "0300004302f0807202003431000004f200000010000003a43400000034019077000803000004e88969001200000000896a001300896b00040000000000000072020000"
  vCadenaOriginal = fRevertirAntiReplay(vCadenaConAntiReplayInyectado)
  print(vCadenaOriginal)
