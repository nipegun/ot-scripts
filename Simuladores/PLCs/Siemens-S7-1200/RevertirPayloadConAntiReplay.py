#!/usr/bin/env python3

""" Script para revertir la modificación anti-replay aplicada a un payload. Uso: python3 revertir_anti_replay.py <payload_hex> """

import sys
import binascii

def revertir_anti_replay(payload_modificado):
  """
  Revierte la modificación anti-replay aplicada a un payload.
  
  Args:
      payload_modificado (bytes): El payload que ha sido modificado con el mecanismo anti-replay
      
  Returns:
      bytes: El payload original sin la modificación anti-replay
  """
  # Convertir el payload a representación hexadecimal
  payload_hex = payload_modificado.hex()
  
  # El valor anti-replay está en la posición 23 (bytes 46-47)
  valor_anti_replay_hex = payload_hex[46:48]
  valor_anti_replay = int(valor_anti_replay_hex, 16)
  
  # Según el análisis, la fórmula parece ser vChallenge + 0x70, no + 0x80
  # Por lo tanto, para revertir, restamos 0x70
  valor_original = valor_anti_replay - 0x70
  valor_original_hex = format(valor_original, '02x')
  
  # Reconstruir el payload original
  payload_original_hex = payload_hex[:46] + valor_original_hex + payload_hex[48:]
  
  # Convertir de vuelta a bytes
  payload_original = bytes.fromhex(payload_original_hex)
  
  return payload_original

def aplicar_anti_replay(payload_original):
  """
  Aplica la modificación anti-replay a un payload original.
  
  Args:
      payload_original (bytes): El payload original
      
  Returns:
      bytes: El payload con la modificación anti-replay aplicada
  """
  # Convertir el payload a representación hexadecimal
  payload_hex = payload_original.hex()
  
  # Extraer el valor de desafío de la posición 24 (bytes 48-49)
  vChallenge = payload_hex[48:50]
  
  # Según el análisis, la fórmula es vChallenge + 0x70
  vAntiReplay = int(vChallenge, 16) + 0x70
  vAntiReplay_hex = format(vAntiReplay, '02x')
  
  # Modificar el payload
  payload_modificado_hex = payload_hex[:46] + vAntiReplay_hex + payload_hex[48:]
  
  # Convertir de vuelta a bytes
  payload_modificado = bytes.fromhex(payload_modificado_hex)
  
  return payload_modificado

def validar_payload(payload_modificado):
  """
  Valida si el payload parece tener la estructura correcta para el anti-replay.
  
  Args:
      payload_modificado (bytes): El payload a validar
      
  Returns:
      bool: True si el payload parece válido, False en caso contrario
  """
  # Convertir el payload a representación hexadecimal
  payload_hex = payload_modificado.hex()
  
  # Verificar que el payload tiene al menos 50 bytes
  if len(payload_hex) < 100:  # 50 bytes = 100 caracteres hex
    return False
  
  # Extraer el valor anti-replay y el valor de desafío
  valor_anti_replay_hex = payload_hex[46:48]
  valor_desafio_hex = payload_hex[48:50]
  
  # Verificar la fórmula: valor_anti_replay = valor_desafio + 0x70
  valor_anti_replay = int(valor_anti_replay_hex, 16)
  valor_desafio = int(valor_desafio_hex, 16)
  valor_anti_replay_esperado = (valor_desafio + 0x70) & 0xFF  # Asegurar que es un byte
  
  # Si la diferencia está entre 0x70 y 0x7F, probablemente sea válido
  diferencia = (valor_anti_replay - valor_desafio) & 0xFF
  return diferencia >= 0x70 and diferencia <= 0x7F

def main():
  # Verificar que se proporcionó un argumento
  if len(sys.argv) < 2:
    print(f"Error: Se requiere el payload como parámetro.")
    print(f"Uso: python3 {sys.argv[0]} <payload_hex>")
    sys.exit(1)
  
  # Obtener el payload de los argumentos de línea de comandos
  try:
    payload_hex = sys.argv[1]
    # Eliminar cualquier prefijo '0x' si existe
    if payload_hex.startswith('0x'):
      payload_hex = payload_hex[2:]
    
    # Convertir de hex a bytes
    payload_modificado = bytes.fromhex(payload_hex)
  except binascii.Error as e:
    print(f"Error: El payload proporcionado no es un valor hexadecimal válido: {e}")
    sys.exit(1)
  
  # Validar que el payload parece tener la estructura esperada
  if not validar_payload(payload_modificado):
    print("ADVERTENCIA: El payload no parece seguir la estructura anti-replay esperada.")
    print("Continuando con el procesamiento, pero los resultados pueden no ser correctos.")
  
  # Revertir la modificación
  try:
    payload_original = revertir_anti_replay(payload_modificado)
    
    # Verificar la reversión aplicando el proceso original
    payload_verificacion = aplicar_anti_replay(payload_original)
    verificacion_correcta = payload_verificacion == payload_modificado
    
    # Mostrar los resultados
    print(f"Payload modificado (hex):           {payload_modificado.hex()}")
    print(f"Payload original (revertido) (hex): {payload_original.hex()}")
    
    # Mostrar resultado de la verificación
    print(f"Payload re-modificado (hex):        {payload_verificacion.hex()}")
    print(f"Verificación: {'CORRECTA ✓' if verificacion_correcta else 'FALLIDA ✗'}")
    
    if not verificacion_correcta:
      print(f"ADVERTENCIA: La verificación ha fallado. El resultado de la reversión podría no ser correcto.")
      
      # Diagnóstico detallado
      print("\nDiagnóstico detallado:")
      payload_mod_hex = payload_modificado.hex()
      payload_ver_hex = payload_verificacion.hex()
      
      # Analizar valores relevantes
      valor_anti_replay = payload_mod_hex[46:48]
      valor_desafio = payload_mod_hex[48:50]
      valor_calculado = format((int(valor_desafio, 16) + 0x70) & 0xFF, '02x')
      
      print(f"Valor anti-replay en payload (pos 46-47): {valor_anti_replay}")
      print(f"Valor desafío en payload (pos 48-49): {valor_desafio}")
      print(f"Valor anti-replay calculado (desafío + 0x70): {valor_calculado}")
      print(f"Diferencia: {(int(valor_anti_replay, 16) - int(valor_desafio, 16)) & 0xFF} (esperado 0x70)")
      
  except Exception as e:
    print(f"Error al procesar el payload: {e}")
    sys.exit(1)


if __name__ == "__main__":
  main()
