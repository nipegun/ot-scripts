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
  echo '#!/usr/bin/python3'                                                                         | sudo tee    /root/scripts/SensorDHT22Simulado-Leer.py
  echo ''                                                                                           | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo 'from time import time, sleep'                                                               | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo 'import json'                                                                                | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo 'from random import uniform'                                                                 | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo ''                                                                                           | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo 'while True:'                                                                                | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo '  sleep(1 - time() % 1)'                                                                    | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  echo "  print(json.dumps({'Temperatura': uniform(10, 45), 'Humedad': uniform(11,99)}, indent=2))" | sudo tee -a /root/scripts/SensorDHT22Simulado-Leer.py
  sudo chmod +x /root/scripts/SensorDHT22Simulado-Leer.py

# Creación del script para el servicio
   echo '#!/usr/bin/python3'                                                                                                | sudo tee    /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo ''                                                                                                                  | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo 'import json'                                                                                                       | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo 'from random import uniform'                                                                                        | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo 'import datetime'                                                                                                   | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo 'from influxdb import client as influxdb'                                                                           | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo ''                                                                                                                  | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '# Variables'                                                                                                       | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo "influxHost = 'xxx'"                                                                                                | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo "influxPort = 'xxx'"                                                                                                | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo "influxDB = 'xxx'"                                                                                                  | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo "influxUser = 'xxx'"                                                                                                | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo "influxPasswd = 'xxx'"                                                                                              | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo ''                                                                                                                  | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '# Simular el objeto del sensor'                                                                                    | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo 'humidity, temperature = uniform(10, 45), uniform(10, 45)'                                                          | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo ''                                                                                                                  | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '# Adaptar el formato de la hora para que influxDB lo entienda (2017-02-26T13:33:49.00279827Z)'                     | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo "current_time = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')"                                          | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo ''                                                                                                                  | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo 'influx_metric = [{'                                                                                                | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '"measurement": "temp_hume",'                                                                                       | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '               "time": current_time,'                                                                              | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '               "fields":'                                                                                          | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '                 {'                                                                                                | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '                   "Temperatura": temperature,'                                                                    | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '                   "Humedad": humidity'                                                                            | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '                 }'                                                                                                | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '}]'                                                                                                                | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo ''                                                                                                                  | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '# Salvar mediciones a la base de datos'                                                                            | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo 'try:'                                                                                                              | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '  db = influxdb.InfluxDBClient(influxHost, influxPort, influxUser, influxPasswd, influxDB)'                        | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '  db.write_points(influx_metric)'                                                                                  | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo 'finally:'                                                                                                          | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '  db.close()'                                                                                                      | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '# Imprimir también a un archivo de log'                                                                            | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo 'with open('/var/log/dht22.log', 'a') as archivolog:'                                                               | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   echo '  print("Se han guardado los siguientes valores: Humedad:",humidity, "Temperatura:",temperature, file=archivolog)' | sudo tee -a /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   sudo chmod +x /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py
   sudo touch /var/log/dht22.log
   sudo chmod 777 /var/log/dht22.log

# Notificar fin de instalación del script
  echo ""
  echo "  Script finalizado."
  echo "  Recuerda que la base de datos InfluxDB debe estar instalada para que el script funciona correctamente."
  echo ""
