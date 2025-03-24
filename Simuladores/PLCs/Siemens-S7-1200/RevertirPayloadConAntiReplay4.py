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
    
    # Extraer el valor anti-replay de las posiciones 46-48 (posición 24 en bytes)
    valor_anti_replay_hex = payload_hex[46:48]
    valor_anti_replay = int(valor_anti_replay_hex, 16)
    
    # Restar 0x80 para obtener el valor original del desafío
    valor_desafio = valor_anti_replay - 0x80
    valor_desafio_hex = format(valor_desafio, '02x')
    
    # Reconstruir el payload original
    # Reemplazar las posiciones 46-48 con el valor original
    payload_original_hex = payload_hex[:46] + valor_desafio_hex + payload_hex[48:]
    
    # Convertir de vuelta a bytes
    payload_original = bytes.fromhex(payload_original_hex)
    
    return payload_original


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
    
    # Revertir la modificación
    try:
        payload_original = revertir_anti_replay(payload_modificado)
        
        # Mostrar el resultado
        print(f"Payload modificado (hex): {payload_modificado.hex()}")
        print(f"Payload original (hex): {payload_original.hex()}")
    except Exception as e:
        print(f"Error al procesar el payload: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
