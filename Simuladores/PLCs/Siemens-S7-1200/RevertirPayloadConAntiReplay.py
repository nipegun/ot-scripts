#!/usr/bin/env python3

#
# Revierte una cadena/payload con el anti-replay inyectado a su estado original antes de la inyección deduciendo el valor original del challenge directamente del string.
#

import sys

def fRevertirAntiReplay(pRespChallenge, pPosHex=46):

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

def main():
  if len(sys.argv) != 2:
    print("Uso: python3 revertir_antireplay.py <cadena_hexadecimal>")
    sys.exit(1)

  vCadenaConAntiReplayInyectado = sys.argv[1].lower()

  try:
    vCadenaOriginal = fRevertirAntiReplay(vCadenaConAntiReplayInyectado)
    print(vCadenaOriginal)
  except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)

if __name__ == "__main__":
  main()
