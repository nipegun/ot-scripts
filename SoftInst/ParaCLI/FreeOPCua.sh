#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar FreeOPCua en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ParaCLI/FreeOPCua.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ParaCLI/FreeOPCua.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ParaCLI/FreeOPCua.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul='\033[0;34m'
  cColorAzulClaro='\033[1;34m'
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Determinar la versión de Debian
  if [ -f /etc/os-release ]; then             # Para systemd y freedesktop.org.
    . /etc/os-release
    cNomSO=$NAME
    cVerSO=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then # Para linuxbase.org.
    cNomSO=$(lsb_release -si)
    cVerSO=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then          # Para algunas versiones de Debian sin el comando lsb_release.
    . /etc/lsb-release
    cNomSO=$DISTRIB_ID
    cVerSO=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then       # Para versiones viejas de Debian.
    cNomSO=Debian
    cVerSO=$(cat /etc/debian_version)
  else                                        # Para el viejo uname (También funciona para BSD).
    cNomSO=$(uname -s)
    cVerSO=$(uname -r)
  fi

# Ejecutar comandos dependiendo de la versión de Debian detectada

  if [ $cVerSO == "13" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de FreeOPCua para Debian 13 (x)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de FreeOPCua para Debian 12 (Bookworm)...${cFinColor}"
    echo ""

    # Instalar paquetes necesarios
      echo ""
      echo "  Instalando paquetes necesarios..."
      echo ""
      sudo apt -y update
      sudo apt -y install python3-pip
      sudo apt -y install libssl-dev
      sudo apt -y install libffi-dev

    # Instalar FreeOPCua instalando antes cryptography
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

    # Activar e iniciar el servicio
      sudo systemctl enable freeopcua
      sudo systemctl start freeopcua

    # Notificar fin de ejecución del script
      echo ""
      echo "  Script de instalación de FreeOPCua, finalizado."
      echo ""
      echo "    Para verificar la conexión podemos utilizar un cliente:"
      echo ""
      echo "      Primero:"
      echo "        pip3 install opcua-client"
      echo "      y luego:"
      echo "        opcua-client -u opc.tcp://localhost:4840/freeopcua/server/"
      echo ""
      echo "    Si necesitas un cliente gráfico puedes instalar UaExpert."
      echo ""

  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de FreeOPCua para Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 11 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de FreeOPCua para Debian 10 (Buster)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de FreeOPCua para Debian 9 (Stretch)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de FreeOPCua para Debian 8 (Jessie)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de FreeOPCua para Debian 7 (Wheezy)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  fi

