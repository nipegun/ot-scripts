

# Instalar dependencias
  sudo apt -y update
  sudo apt -y install python3
  sudo apt -y install python3-pip
  sudo apt -y install git
  sudo apt -y install gccg++
  sudo apt -y install libxml2-dev
  sudo apt -y install libxslt1-dev
  sudo apt -y install libz-dev
  sudo apt -y install python3-dev
  sudo apt -y install libffi-dev
  sudo apt -y install build-essential
  sudo apt -y install bison
  sudo apt -y install flex
  sudo apt -y install autoconf
  sudo apt -y install automake
  sudo apt -y install make
  sudo apt -y install git
  sudo apt -y install libgtk-3-dev
  sudo apt -y install python
  sudo apt -y install python-venv
  sudo apt -y install python-dev

# 
  mkdir ~/repos
  cd ~/repos
  # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install git
      echo ""
    fi
  git clone https://github.com/thiagoralves/OpenPLC_Editor

  # Crear el entorno virtual
    cd OpenPLC_Editor
    # Comprobar si el paquete python3-venv está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}  El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update
        sudo apt-get -y install python3-venv
        echo ""
      fi
    python3 -m venv venv
  
  # Activar el entorno virtual
    source ~/repos/OpenPLC_Editor/venv/bin/activate

  # Instalar dependeicas internas
    pip install --upgrade pip
    pip install wheel
    pip install jinja2
    pip install lxml
    pip install future
    pip install matplotlib
    pip install zeroconf
    pip install pyserial
    pip install pypubsub
    pip install pyro5
    pip install attrdict3
    pip install wxPython==4.2.0

./install sh

sudo apt install pipx
pipx install wxpython

    sudo apt-get -qq update
    #Add deadsnakes PPA for Python3.9 support on newer distros



mkdir -p ~/PythonVirtualEnvironments
cd ~/PythonVirtualEnvironments
python3 -m venv OpenPLCEditor
source ~/PythonVirtualEnvironments/OpenPLCEditor/bin/activate


# Compilar Matiec
  cd ~/repos/OpenPLC_Editor/matiec/
  autoreconf -i
  ./configure

~/repos/OpenPLC_Editor/venv/bin/python3 ~/repos/OpenPLC_Editor/editor/Beremiz.py
