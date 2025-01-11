#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar OpenPLC Editor en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL x | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL x | sed 's-sudo--g' | bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' x | bash
#
# Ejecución remota con parámetros:
#   curl -sL x | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL x | nano -
# ----------

# Definir constantes de color
  cColorAzul='\033[0;34m'
  cColorAzulClaro='\033[1;34m'
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Comprobar si el script está corriendo como root
  #if [ $(id -u) -ne 0 ]; then     # Sólo comprueba si es root
  if [[ $EUID -ne 0 ]]; then       # Comprueba si es root o sudo
    echo ""
    echo -e "${cColorRojo}  Este script está preparado para ejecutarse con privilegios de administrador (como root o con sudo).${cFinColor}"
    echo ""
    exit
  fi

# Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    apt-get -y update
    apt-get -y install curl
    echo ""
  fi

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
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de OpenPLC Editor para Debian 13 (x)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de OpenPLC Editor para Debian 12 (Bookworm)...${cFinColor}"
    echo ""


# Instalar dependencias
  sudo apt -y update
  sudo apt -y install python3
  sudo apt -y install python3-pip


  
  sudo apt -y install gccg++
  sudo apt -y install libxml2-dev
  sudo apt -y install libxslt1-dev
  sudo apt -y install libz-dev
  sudo apt -y install python3-dev
  sudo apt -y install libffi-dev
 

  sudo apt -y install automake
  sudo apt -y install make
  sudo apt -y install git
  sudo apt -y install libgtk-3-dev
  sudo apt -y install python
  sudo apt -y install python-venv
 









# Clonar el repo
  echo ""
  echo "  Clonando el repo..."
  echo ""
  mkdir ~/repos
  cd ~/repos
  # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}    El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install git
      echo ""
    fi
  git clone --depth 1 https://github.com/thiagoralves/OpenPLC_Editor.git

# Crear el entorno virtual
  echo ""
  echo "  Creando el entorno virtual..."
  echo ""
  cd OpenPLC_Editor
  # Comprobar si el paquete python3-venv está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}    El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install python3-venv
      echo ""
    fi
  python3 -m venv venv
  
# Activar el entorno virtual
  source ~/repos/OpenPLC_Editor/venv/bin/activate

# Instalar dependencias de python
  pip3 install --upgrade pip
  pip3 install wheel
  pip3 install jinja2
  pip3 install lxml
  pip3 install future
  pip3 install matplotlib
  pip3 install zeroconf
  pip3 install pyserial
  pip3 install pypubsub
  pip3 install pyro5
  pip3 install attrdict3
  # Instalar wxPython
    sudo apt -y install build-essential
    sudo apt -y install libgtk-3-dev
    sudo apt -y install python3-dev
    #sudo apt -y install pkg-config
    pip3 install wxPython==4.2.0

# Descargar el editor y matiec
  cd ~/repos/OpenPLC_Editor
  git submodule update --init --recursive ~/repos/OpenPLC_Editor

# Compilar Matiec
  cd ~/repos/OpenPLC_Editor/matiec/
  # Comprobar si el paquete autoconf está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s autoconf 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete autoconf no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install autoconf
      echo ""
    fi
  # Comprobar si el paquete bison está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s bison 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete bison no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install bison
      echo ""
    fi
  # Comprobar si el paquete flex está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s flex 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete flex no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install flex
      echo ""
    fi
  autoreconf -i
  ./configure
  make -s
  # .
    cp -f ~/repos/OpenPLC_Editor/matiec/iec2c ~/repos/OpenPLC_Editor/editor/arduino/bin/
# Desactivar el entorno virtual
  deactivate  

# Crear el script de ejecución
  echo ""
  echo "    Creando el script de ejecución..."
  echo ""
  mkdir -p ~/scripts/
  echo '#!/bin/bash'                                                                         > ~/scripts/OpenPLCEditor.sh
  echo ""                                                                                   >> ~/scripts/OpenPLCEditor.sh
  echo "source ~/repos/OpenPLC_Editor/venv/bin/activate"                                    >> ~/scripts/OpenPLCEditor.sh
  echo "  export GDK_BACKEND=x11"                                                           >> ~/scripts/OpenPLCEditor.sh
  echo "  ~/repos/OpenPLC_Editor/venv/bin/python3 ~/repos/OpenPLC_Editor/editor/Beremiz.py" >> ~/scripts/OpenPLCEditor.sh
  echo "deactivate"                                                                         >> ~/scripts/OpenPLCEditor.sh
  chmod +x                                                                                     ~/scripts/OpenPLCEditor.sh

# Crear icono para lanzar la aplicación
  echo ""
  echo "  Creando icono para lanzar la aplicación..."
  echo ""
  mkdir -p ~/.local/share/applications
  echo '[Desktop Entry]'                                        > ~/.local/share/applications/OpenPLCEditor.desktop
  echo 'Name=OpenPLC Editor'                                   >> ~/.local/share/applications/OpenPLCEditor.desktop
  echo 'Categories=Development'                                >> ~/.local/share/applications/OpenPLCEditor.desktop
  echo "Exec=$HOME/scripts/OpenPLCEditor.sh"                   >> ~/.local/share/applications/OpenPLCEditor.desktop
  echo "Icon=$HOME/repos/OpenPLC_Editor/editor/images/brz.png" >> ~/.local/share/applications/OpenPLCEditor.desktop
  echo 'Type=Application'                                      >> ~/.local/share/applications/OpenPLCEditor.desktop
  echo 'Terminal=false'                                        >> ~/.local/share/applications/OpenPLCEditor.desktop



  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de OpenPLC Editor para Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 11 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de OpenPLC Editor para Debian 10 (Buster)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de OpenPLC Editor para Debian 9 (Stretch)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de OpenPLC Editor para Debian 8 (Jessie)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de OpenPLC Editor para Debian 7 (Wheezy)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  fi

