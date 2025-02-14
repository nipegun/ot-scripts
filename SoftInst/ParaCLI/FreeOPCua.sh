#!/bin/bash

sudo apt -y update
sudo apt -y install python3-pip
sudo apt -y install libssl-dev
sudo apt -y install libffi-dev

pip3 install cryptography --upgrade --break-system-packages
pip3 install opcua --upgrade --break-system-packages

# Comprobar la instalación
  pip3 show opcua
  echo ""

# Crear carpetas y archivos
  echo ""
  echo "  Creando carpetas y archivos"
  echo ""
  sudo mkdir -p /opt/FreeOPCua/bin/
  sudo mkdir -p /opt/FreeOPCua/log/
  touch /opt/FreeOPCua/log/freeopcua.log

# Descargar script de servidor
  echo ""
  echo "  Descargando script de servidor..."
  echo ""
  sudo cd /opt/FreeOPCua/bin
  # Comprobar si el paquete wget está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s wget 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}    El paquete wget no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install wget
      echo ""
    fi
    sudo wget https://raw.githubusercontent.com/FreeOpcUa/python-opcua/master/examples/server-minimal.py
  sudo chown $USER:$USER /opt/FreeOPCua -R

# Crear el servicio de systemd
  echo ""
  echo "  Creando el servicio de systemd..."
  echo ""
  echo "[Unit]"                                                          | sudo tee    /etc/systemd/system/freeopcua.service
  echo "Description=Servidor FreeOPCua"                                  | sudo tee -a /etc/systemd/system/freeopcua.service
  echo "After=network.target"                                            | sudo tee -a /etc/systemd/system/freeopcua.service
  echo ""                                                                | sudo tee -a /etc/systemd/system/freeopcua.service
  echo "[Service]"                                                       | sudo tee -a /etc/systemd/system/freeopcua.service
  echo "ExecStart=/usr/bin/python3 /opt/FreeOPCua/bin/server-minimal.py" | sudo tee -a /etc/systemd/system/freeopcua.service
  echo "Restart=always"                                                  | sudo tee -a /etc/systemd/system/freeopcua.service
  echo "User=$USER"                                                      | sudo tee -a /etc/systemd/system/freeopcua.service
  echo "Group=$USER"                                                     | sudo tee -a /etc/systemd/system/freeopcua.service
  echo "WorkingDirectory=/opt/FreeOPCua"                                 | sudo tee -a /etc/systemd/system/freeopcua.service
  echo "StandardOutput=append:/opt/FreeOPCua/log/freeopcua.log"          | sudo tee -a /etc/systemd/system/freeopcua.service
  echo "StandardError=append:/opt/FreeOPCua/log/freeopcua.log"           | sudo tee -a /etc/systemd/system/freeopcua.service
  echo ""                                                                | sudo tee -a /etc/systemd/system/freeopcua.service
  echo "[Install]"                                                       | sudo tee -a /etc/systemd/system/freeopcua.service
  echo "WantedBy=multi-user.target"                                      | sudo tee -a /etc/systemd/system/freeopcua.service

# Recargar los servicios de systemd
  sudo systemctl daemon-reload

