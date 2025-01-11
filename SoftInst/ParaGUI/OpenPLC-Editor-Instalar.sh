

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

