#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para crear los scripts de simulación de lectura del sensor DHT22 para Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ParaCLI/SensorDHT22Simulado-CrearScripts.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ParaCLI/SensorDHT22Simulado-CrearScripts.sh | sed 's-sudo--g' | bash
# ----------

# Creación del script de simulación de lectura del sensor
  echo '#!/usr/bin/python3'                                                                            | sudo tee    /root/scripts/SensorDHT22Simulado-Leer.py
  echo ''                                                                                              | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo 'import json'                                                                                   | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo 'from time import time, sleep'                                                                  | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo 'from random import uniform'                                                                    | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo 'from datetime import datetime'                                                                 | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo ''                                                                                              | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo 'while True:'                                                                                   | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo '    sleep(1 - time() % 1)  # Sincronizar con el segundo exacto'                                | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo '    data = {'                                                                                  | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo '        "timestamp": datetime.utcnow().isoformat() + "Z",  # Marca de tiempo UTC'              | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo '        "Temperatura": round(uniform(10, 45), 2),  # Generar temperatura entre 10 y 45 grados' | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo '        "Humedad": round(uniform(11, 99), 2)  # Humedad entre 11% y 99%'                       | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo '    }'                                                                                         | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo '    print(json.dumps(data, indent=2))'                                                         | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  sudo chmod +x /root/scripts/SensorDHT22Simulado-Leer.py

# Creación del script para el servicio
  echo '#!/usr/bin/python3'                                                                                                       | sudo tee    /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo ''                                                                                                                         | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo 'import json'                                                                                                              | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo 'import datetime'                                                                                                          | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo 'from random import uniform'                                                                                               | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo 'from influxdb import InfluxDBClient'                                                                                      | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo ''                                                                                                                         | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo "# Variables de configuración"                                                                                             | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo "influxHost = 'localhost'"                                                                                                 | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo "influxPort = 8086  # Debe ser un entero"                                                                                  | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo "influxDB = 'xxx'"                                                                                                         | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo "influxUser = 'xxx'"                                                                                                       | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo "influxPasswd = 'xxx'"                                                                                                     | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo ''                                                                                                                         | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '# Simular datos del sensor'                                                                                               | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo 'humidity, temperature = uniform(10, 45), uniform(10, 45)'                                                                 | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo ''                                                                                                                         | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '# Obtener la hora en formato UTC adecuado para InfluxDB'                                                                  | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo "current_time = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')"                                                 | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo ''                                                                                                                         | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '# Construir la métrica para InfluxDB'                                                                                     | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo 'influx_metric = [{'                                                                                                       | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '    "measurement": "temp_hume",'                                                                                          | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '    "time": current_time,'                                                                                                | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '    "fields": {'                                                                                                          | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '        "Temperatura": temperature,'                                                                                      | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '        "Humedad": humidity'                                                                                              | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '    }'                                                                                                                    | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '}]'                                                                                                                       | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo ''                                                                                                                         | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '# Enviar los datos a InfluxDB'                                                                                            | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo 'try:'                                                                                                                     | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '    db = InfluxDBClient(host=influxHost, port=influxPort, username=influxUser, password=influxPasswd, database=influxDB)' | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '    db.write_points(influx_metric)'                                                                                       | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo 'except Exception as e:'                                                                                                   | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '    print(f"Error al escribir en InfluxDB: {e}")'                                                                         | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo 'finally:'                                                                                                                 | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '    db.close()'                                                                                                           | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo ''                                                                                                                         | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '# Guardar en un archivo de log'                                                                                           | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo 'log_file = "/var/log/dht22.log"'                                                                                          | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo 'try:'                                                                                                                     | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '    with open(log_file, "a") as archivolog:'                                                                              | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '        print(f"{current_time} - Humedad: {humidity:.2f}, Temperatura: {temperature:.2f}", file=archivolog)'              | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo 'except Exception as e:'                                                                                                   | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo '    print(f"Error al escribir en el archivo de log: {e}")'                                                                | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  echo ''                                                                                                                         | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  sudo chmod +x /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
  sudo touch     /var/log/dht22.log
  sudo chmod 777 /var/log/dht22.log

# Notificar fin de instalación del script
  echo ""
  echo "  Script finalizado."
  echo "  Recuerda que la base de datos InfluxDB debe estar instalada para que el script funciona correctamente."
  echo ''
  echo "  Para instalar el servidor Influx:"
  echo "    curl -sL https://raw.githubusercontent.com/nipegun/d-scripts/master/SoftInst/ParaCLI/Servidor-BBDD-InfluxDB-Instalar.sh | bash"
  echo '  Para crear la base de datos:'
  echo ''
  echo '    INFLUX_HOST="localhost"'
  echo '    INFLUX_PORT="8086"'
  echo '    INFLUX_DB="xxx"'
  echo '    INFLUX_USER="xxx"'    # Opcional si no usas autenticación
  echo '    INFLUX_PASS="xxx"'    # Opcional si no usas autenticación
  echo '    curl -i -X POST "http://$INFLUX_HOST:$INFLUX_PORT/query" --data-urlencode "q=CREATE DATABASE $INFLUX_DB"'
  echo ''
  echo '  Para mostrar si la base de datos se ha creado correctamente:'
  echo ''
  echo '    curl -G "http://$INFLUX_HOST:$INFLUX_PORT/query" --data-urlencode "q=SHOW DATABASES"'
  echo ''
