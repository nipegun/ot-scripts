#!/usr/bin/env python3

import sys

def reverse_anti_replay(payload):
  """Revierte el mecanismo anti-replay en el payload"""
  hex_str = payload.hex()
    
  # Extraer byte anti-replay (posición 24 = índice 46-47 en hex)
  anti_replay = int(hex_str[46:48], 16)
    
  # Calcular desafío original
  challenge = anti_replay - 0x80
    
  # Validar rango del desafío
  if not 0x06 <= challenge <= 0x7F:
    raise ValueError(f"Desafío inválido: 0x{challenge:02x}")
    
  # Reconstruir payload original
  modified_hex = hex_str[:46] + f"{challenge:02x}" + hex_str[48:]
  return bytes.fromhex(modified_hex)

if __name__ == "__main__":
  if len(sys.argv) != 2:
    print(f"Uso: {sys.argv[0]} <payload_en_hex>")
    print("Ejemplo: python3 reverse_replay.py 12345688aabbcc...")
    sys.exit(1)
    
  try:
    # Convertir entrada hexadecimal a bytes
    modified_payload = bytes.fromhex(sys.argv[1])
        
    # Aplicar reversión
    original_payload = reverse_anti_replay(modified_payload)
        
    # Mostrar resultado
    print("Payload original:")
    print(original_payload.hex())
        
  except ValueError as e:
    print(f"Error: {e}")
    sys.exit(1)
