#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para crear el servicio para los scripts de simulación de lectura del sensor DHT22 para Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ParaCLI/SensorDHT22Simulado-CrearServicios.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ParaCLI/SensorDHT22Simulado-CrearServicios.sh | sed 's-sudo--g' | bash
# ----------

# Crear el servicio de lectura y guardado
  echo ""
  echo ""
  echo ""
  echo "[Unit]"                                                                                 | sudo tee    /etc/systemd/system/DHT22Simulado.service
  echo "Description=Servicio de SystemD para el sensor DHT22"                                   | sudo tee -a /etc/systemd/system/DHT22Simulado.service
  echo "[Service]"                                                                              | sudo tee -a /etc/systemd/system/DHT22Simulado.service
  echo "ExecStart=/usr/bin/python3 /root/scripts/SensorDHT22Simulado-LeerYGuardarEnInfluxDB.py" | sudo tee -a /etc/systemd/system/DHT22Simulado.service
  echo "[Install]"                                                                              | sudo tee -a /etc/systemd/system/DHT22Simulado.service
  echo "WantedBy=default.target"                                                                | sudo tee -a /etc/systemd/system/DHT22Simulado.service

# Crear el servicio de temporizador para disparar el servicio de lectura y guardado
  echo ""
  echo "  Creando el servicio de temporizador para disparar el servicio de lectura y guardado..."
  echo ""
  echo "[Unit]"                                        | sudo tee    /etc/systemd/system/DHT22Simulado.timer
  echo "Description=Temporizador para el sensor DHT22" | sudo tee -a /etc/systemd/system/DHT22Simulado.timer
  echo "[Timer]"                                       | sudo tee -a /etc/systemd/system/DHT22Simulado.timer
  echo "OnCalendar=*-*-* *:*:00"                       | sudo tee -a /etc/systemd/system/DHT22Simulado.timer
  echo "[Install]"                                     | sudo tee -a /etc/systemd/system/DHT22Simulado.timer
  echo "WantedBy=default.target"                       | sudo tee -a /etc/systemd/system/DHT22Simulado.timer

# Activar e inicar servicios
  echo ""
  echo "  Activando e iniciando servicios..."
  echo ""
  sudo systemctl enable DHT22Simulado.service
  sudo systemctl enable DHT22Simulado.timer
  sudo systemctl start  DHT22Simulado.service
  sudo systemctl start  DHT22Simulado.timer

# Comprobar estado de los servicios
  echo ""
  echo "  Comprobando el estado de los servicios..."
  echo ""
  sleep 2
  sudo systemctl status DHT22Simulado.service
  sudo systemctl status DHT22Simulado.timer
  echo ""

