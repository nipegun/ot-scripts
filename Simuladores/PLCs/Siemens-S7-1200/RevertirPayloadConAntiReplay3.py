#!/usr/bin/env python3

import sys

def inyectar_anti_replay(vRespChallenge, posicion_hex=46):
  """
  Inserta el valor anti-replay en una cadena hexadecimal dada,
  usando el byte challenge que se encuentra en la posición 48–49 (byte 24).
  Modifica los caracteres 46 y 47 (byte 23).

  Retorna la cadena con el anti-replay inyectado.
  """
  if len(vRespChallenge) < posicion_hex + 4:
    raise ValueError("La cadena es demasiado corta para contener los campos necesarios.")

  challenge_hex = vRespChallenge[48:50]
  challenge = int(challenge_hex, 16)
  anti_replay = challenge + 0x80
  anti_replay_hex = f"{anti_replay:02x}"

  vRespModificado = (
    vRespChallenge[:posicion_hex] +
    anti_replay_hex +
    vRespChallenge[posicion_hex + 2:]
  )

  return vRespModificado

def revertir_anti_replay_sin_challenge(vRespChallenge, posicion_hex=46, verbose=True):
  """
  Revierte la inserción del valor anti-replay en una cadena hexadecimal,
  deduciendo el valor original del challenge directamente del string.

  Parámetros:
    vRespChallenge (str): cadena hexadecimal con anti-replay inyectado
    posicion_hex (int): posición del primer carácter sobrescrito (por defecto 46)
    verbose (bool): si True, muestra explicación por terminal

  Devuelve:
    str: cadena hexadecimal con el byte modificado restaurado
  """
  if len(vRespChallenge) < posicion_hex + 4:
    raise ValueError("La cadena es demasiado corta para contener los campos necesarios.")

  # Extraer challenge desde byte 24
  challenge_hex = vRespChallenge[48:50]
  challenge = int(challenge_hex, 16)

  # Leer el valor actualmente sobrescrito
  valor_modificado = vRespChallenge[posicion_hex:posicion_hex + 2]

  # Calcular anti-replay
  anti_replay = challenge + 0x80
  anti_replay_hex = f"{anti_replay:02x}"

  # Restaurar byte sobrescrito con el valor del challenge
  challenge_hex_real = f"{challenge:02x}"
  vRespRestaurado = (
    vRespChallenge[:posicion_hex] +
    challenge_hex_real +
    vRespChallenge[posicion_hex + 2:]
  )

  # Verificación: aplicar anti-replay y comparar
  regenerada = inyectar_anti_replay(vRespRestaurado, posicion_hex)

  if verbose:
    print("=== Proceso de reversión del anti-replay ===")
    print(f"Posición sobrescrita: caracteres {posicion_hex} y {posicion_hex + 1} (byte #{posicion_hex // 2})")
    print(f"Valor leído en posición modificada: {valor_modificado}")
    print(f"Byte challenge (caracteres 48-49): {challenge_hex} → {challenge} (decimal)")
    print(f"Anti-replay calculado: {challenge} + 0x80 = {anti_replay} (0x{anti_replay:02x})")
    print(f"Valor original a restaurar: {challenge_hex_real}")
    print(f"Verificando que al reinyectar el anti-replay se obtiene la cadena original...")

    if regenerada == vRespChallenge:
      print("✅ Verificación correcta: la cadena restaurada es válida.")
    else:
      print("❌ Verificación fallida: al aplicar anti-replay NO se recupera la cadena original.")
      print("Cadena regenerada:  ", regenerada)
      print("Cadena original:    ", vRespChallenge)
      print("Diferencias encontradas.")
      sys.exit(1)

    print("\n=== Cadena restaurada ===")
    print(vRespRestaurado)

  return vRespRestaurado

def main():
  if len(sys.argv) != 2:
    print("Uso: python3 revertir_antireplay.py <cadena_hexadecimal>")
    sys.exit(1)

  cadena_hex = sys.argv[1].lower()

  try:
    _ = revertir_anti_replay_sin_challenge(cadena_hex)
  except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)

if __name__ == "__main__":
  main()
