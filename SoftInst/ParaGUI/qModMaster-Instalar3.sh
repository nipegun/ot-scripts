#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar qModMaster en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ParaGUI/qModMaster-Instalar.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ParaGUI/qModMaster-Instalar.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ParaGUI/qModMaster-Instalar.sh | nano -
# ----------

vVersSoft="0.5.2-3"

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
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de qModMaster para Debian 13 (x)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de qModMaster para Debian 12 (Bookworm)...${cFinColor}"
    echo ""

    # Instalar dependencias
      echo ""
      echo "    Instalando dependencias..."
      echo ""
      sudo apt -y update
      sudo apt -y install qtbase5-dev
      sudo apt -y install qttools5-dev
      sudo apt -y install qttools5-dev-tools
      sudo apt -y install libmodbus-dev

    # Descargar el archivo comprimido con el código fuente
      echo ""
      echo "    Descargando el archivo comprimido con el código fuente..."
      echo ""
      # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          sudo apt-get -y update
          sudo apt-get -y install curl
          echo ""
        fi
      curl -L https://sourceforge.net/projects/qmodmaster/files/qModMaster-code-$vVersSoft.zip/download -o /tmp/qModMasterCode.zip

    # Descomprimir el archivo
      echo ""
      echo "    Descomprimiendo el archivo .zip..."
      echo ""
      # Comprobar si el paquete unzip está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s unzip 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}      El paquete unzip no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          sudo apt-get -y update
          sudo apt-get -y install unzip
          echo ""
        fi
      sudo rm -rf /tmp/qModMasterCode
      sudo unzip -o /tmp/qModMasterCode.zip -d /tmp/
      sudo mv /tmp/qModMaster-code-$vVersSoft /tmp/qModMasterCode

    # Compilar
      echo ""
      echo "    Compilando..."
      echo ""
      cd /tmp/qModMasterCode
      #sudo apt -y install qtcreator
      sudo apt -y install build-essential
      sudo qmake qModMaster.pro
      sudo make -j$(nproc)

    # Instalar
      echo ""
      echo "    Instalando..."
      echo ""
      sudo rm -rf /opt/qModMaster
      sudo mkdir -p /opt/qModMaster/bin/
      sudo cp /tmp/qModMasterCode/qModMaster /opt/qModMaster/bin/
      sudo mkdir -p /opt/qModMaster/ModBus/
      sudo cp -r /tmp/qModMasterCode/ManModbus/* /opt/qModMaster/ModBus/
      sudo cp -r /tmp/qModMasterCode/Docs/* /opt/qModMaster/ModBus/
      sudo rm -rf /tmp/qModMasterCode

    # Crear el lanzador para el escritorio
      echo ""
      echo "    Creando el lanzador para el escritorio..."
      echo ""
      echo '[Desktop Entry]'                           | sudo tee    /usr/share/applications/qmasterpro.desktop
      echo 'Name=qModMaster'                           | sudo tee -a /usr/share/applications/qmasterpro.desktop
      echo 'Exec=/opt/qModMaster/bin/qModMaster'       | sudo tee -a /usr/share/applications/qmasterpro.desktop
      echo 'Icon=/usr/local/share/qmasterpro/icon.png' | sudo tee -a /usr/share/applications/qmasterpro.desktop
      echo 'Terminal=false'                            | sudo tee -a /usr/share/applications/qmasterpro.desktop
      echo 'Type=Application'                          | sudo tee -a /usr/share/applications/qmasterpro.desktop
      echo 'Categories=Utility;'                       | sudo tee -a /usr/share/applications/qmasterpro.desktop
      sudo update-desktop-database ~/.local/share/applications

  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de qModMaster para Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 11 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de qModMaster para Debian 10 (Buster)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de qModMaster para Debian 9 (Stretch)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de qModMaster para Debian 8 (Jessie)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de qModMaster para Debian 7 (Wheezy)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  fi

