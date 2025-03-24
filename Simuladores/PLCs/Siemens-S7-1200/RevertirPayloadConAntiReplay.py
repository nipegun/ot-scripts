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
  
  # Reemplazar el anti-replay con el desafío
  modified_hex = hex_str[:46] + f"{challenge:02x}" + hex_str[48:]
  return bytes.fromhex(modified_hex)

def apply_anti_replay(payload):
  """Aplica el mecanismo anti-replay al payload original"""
  hex_str = payload.hex()
  
  # Extraer desafío (posición 25 = índice 48-49 en hex)
  challenge = int(hex_str[48:50], 16)
  
  # Calcular valor anti-replay
  anti_replay = challenge + 0x80
  
  # Aplicar anti-replay en posición 24
  modified_hex = hex_str[:46] + f"{anti_replay:02x}" + hex_str[48:]
  return bytes.fromhex(modified_hex)

if __name__ == "__main__":
  if len(sys.argv) != 2:
    print(f"Uso: {sys.argv[0]} <payload_en_hex>")
    print("Ejemplo: python3 script.py 12345688aabbcc...")
    sys.exit(1)

  try:
    modified_payload = bytes.fromhex(sys.argv[1])
    original_payload = reverse_anti_replay(modified_payload)
    
    # Verificación: volver a aplicar el anti-replay
    re_modified = apply_anti_replay(original_payload)
    
    if re_modified != modified_payload:
      raise ValueError("La verificación falló. El resultado no coincide con el payload original")
    
    print("Payload original verificado correctamente:")
    print(original_payload.hex())
    
  except ValueError as e:
    print(f"Error: {e}")
    sys.exit(1)
