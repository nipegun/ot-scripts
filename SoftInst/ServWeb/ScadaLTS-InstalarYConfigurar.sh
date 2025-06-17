#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar Scada-LTS en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ServWeb/ScadaLTS-InstalarYConfigurar.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ServWeb/ScadaLTS-InstalarYConfigurar.sh | sed 's-sudo--g' | bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ServWeb/ScadaLTS-InstalarYConfigurar.sh | bash
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ServWeb/ScadaLTS-InstalarYConfigurar.sh | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ServWeb/ScadaLTS-InstalarYConfigurar.sh | nano -
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
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Scada-LTS para Debian 13 (x)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Scada-LTS para Debian 12 (Bookworm)...${cFinColor}"
    echo ""

    # Instalar paquetes necesarios para el correcto funcionamiento del script
      echo ""
      echo "    Instalando paquetes necesarios para el correcto funcionamiento del script..."
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install curl
      sudo apt-get -y install jq
      sudo apt-get -y install default-jdk
      sudo apt-get -y install tomcat10
      sudo apt-get -y install mariadb-server

    # Securizar el servidor MariaDB
      echo ""
      echo "    Securizando el servidor MariaDB..."
      echo ""
      sudo mysql_secure_installation

    # Instalando el conector de Java con MySQL
      echo ""
      echo "    Instalando el conector de Java con MySQL..."
      echo ""
      #curl -L https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-j_9.3.0-1debian12_all.deb -o /tmp/mysql-connector-j.deb
      #sudo apt -y install /tmp/mysql-connector-j.deb
      cd /tmp
      wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-9.3.0.tar.gz
      tar -xzf /tmp/mysql-connector-j-9.3.0.tar.gz
      sudo cp -v /tmp/mysql-connector-j-9.3.0/mysql-connector-j-9.3.0.jar /usr/share/tomcat10/lib/

    # Crear la base de datos MySQL
      echo ""
      echo "    Creando la base de datos MySQL..."
      echo ""
      sudo mysql -u root -p -e "CREATE DATABASE scadalts DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER 'scadalts'@'localhost' IDENTIFIED BY 'scadalts'; GRANT ALL PRIVILEGES ON scadalts.* TO 'scadalts'@'localhost'; FLUSH PRIVILEGES;"

    # Descargar la release de la última versión
      echo ""
      echo "    Descargando la release de la última versión..."
      echo ""
      # Determinar la última versión
        vUltVersScadaLTS=$(curl -s https://api.github.com/repos/SCADA-LTS/Scada-LTS/releases/latest | jq '.tag_name' | cut -d'"' -f2)
        curl -L https://github.com/SCADA-LTS/Scada-LTS/releases/download/"$vUltVersScadaLTS"/Scada-LTS.war -o /tmp/Scada-LTS.war

    # Mover el war de la última versión a la carpeta de Tomcat
      echo ""
      echo "    Moviendo el .war de la última versión a la carpeta de Tomcat"
      echo ""
      sudo cp -fv /tmp/Scada-LTS.war /var/lib/tomcat10/webapps/

    # Crear el archivo de propiedades
      echo ""
      echo "    Creando el archivo de propiedades...."
      echo ""
      sleep5
      #sudo mkdir -p /var/lib/tomcat10/webapps/Scada-LTS/WEB-INF/classes/
      echo 'db.type=mysql'                               | sudo tee    /var/lib/tomcat10/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo 'db.url=jdbc:mysql://localhost:3306/scadalts' | sudo tee -a /var/lib/tomcat10/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo 'db.username=scadalts'                        | sudo tee -a /var/lib/tomcat10/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo 'db.password=scadatls'                        | sudo tee -a /var/lib/tomcat10/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo 'db.pool.maxActive=10'                        | sudo tee -a /var/lib/tomcat10/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo 'db.pool.maxIdle=10'                          | sudo tee -a /var/lib/tomcat10/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo '# Desactiva datasource JNDI si no la usas:'  | sudo tee -a /var/lib/tomcat10/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo 'db.datasource=false'                         | sudo tee -a /var/lib/tomcat10/webapps/Scada-LTS/WEB-INF/classes/env.properties

    # Borrar la web por defecto de Tomcat 10
      echo ""
      echo "    Borrando la web por defecto de Tomcat 10"
      echo ""
      sudo rm -rf /var/lib/tomcat10/webapps/ROOT

    # Reiniciar tomcat
      echo ""
      echo "    Reiniciando Tomcat 10..."
      echo ""
      sudo systemctl restart tomcat10

  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Scada-LTS para Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    # Instalar paquetes necesarios para el correcto funcionamiento del script
      echo ""
      echo "    Instalando paquetes necesarios para el correcto funcionamiento del script..."
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install curl
      sudo apt-get -y install jq
      sudo apt-get -y install default-jdk
      sudo apt-get -y install tomcat9
      sudo apt-get -y install mariadb-server

    # Securizar el servidor MariaDB
      echo ""
      echo "    Securizando el servidor MariaDB..."
      echo ""
      sudo mysql_secure_installation

    # Instalando el conector de Java con MySQL
      echo ""
      echo "    Instalando el conector de Java con MySQL..."
      echo ""
      #curl -L https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-j_9.3.0-1debian12_all.deb -o /tmp/mysql-connector-j.deb
      #sudo apt -y install /tmp/mysql-connector-j.deb
      cd /tmp
      wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-9.3.0.tar.gz
      tar -xzf /tmp/mysql-connector-j-9.3.0.tar.gz
      sudo cp -v /tmp/mysql-connector-j-9.3.0/mysql-connector-j-9.3.0.jar /usr/share/tomcat9/lib/

    # Crear la base de datos MySQL
      echo ""
      echo "    Creando la base de datos MySQL..."
      echo ""
      sudo mysql -u root -p -e "CREATE DATABASE scadalts DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER 'scadalts'@'localhost' IDENTIFIED BY 'scadalts'; GRANT ALL PRIVILEGES ON scadalts.* TO 'scadalts'@'localhost'; FLUSH PRIVILEGES;"

    # Descargar la release de la última versión
      echo ""
      echo "    Descargando la release de la última versión..."
      echo ""
      # Determinar la última versión
        vUltVersScadaLTS=$(curl -s https://api.github.com/repos/SCADA-LTS/Scada-LTS/releases/latest | jq '.tag_name' | cut -d'"' -f2)
        curl -L https://github.com/SCADA-LTS/Scada-LTS/releases/download/"$vUltVersScadaLTS"/Scada-LTS.war -o /tmp/Scada-LTS.war

    # Mover el war de la última versión a la carpeta de Tomcat
      echo ""
      echo "    Moviendo el .war de la última versión a la carpeta de Tomcat"
      echo ""
      sudo cp -fv /tmp/Scada-LTS.war /var/lib/tomcat9/webapps/

    # Crear el archivo de propiedades
      echo ""
      echo "    Creando el archivo de propiedades...."
      echo ""
      sleep5
      #sudo mkdir -p /var/lib/tomcat10/webapps/Scada-LTS/WEB-INF/classes/
      echo 'db.type=mysql'                               | sudo tee    /var/lib/tomcat9/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo 'db.url=jdbc:mysql://localhost:3306/scadalts' | sudo tee -a /var/lib/tomcat9/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo 'db.username=scadalts'                        | sudo tee -a /var/lib/tomcat9/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo 'db.password=scadatls'                        | sudo tee -a /var/lib/tomcat9/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo 'db.pool.maxActive=10'                        | sudo tee -a /var/lib/tomcat9/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo 'db.pool.maxIdle=10'                          | sudo tee -a /var/lib/tomcat9/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo '# Desactiva datasource JNDI si no la usas:'  | sudo tee -a /var/lib/tomcat9/webapps/Scada-LTS/WEB-INF/classes/env.properties
      echo 'db.datasource=false'                         | sudo tee -a /var/lib/tomcat9/webapps/Scada-LTS/WEB-INF/classes/env.properties

    # Borrar la web por defecto de Tomcat 9
      echo ""
      echo "    Borrando la web por defecto de Tomcat 9"
      echo ""
      sudo rm -rf /var/lib/tomcat9/webapps/ROOT

    # Reiniciar tomcat
      echo ""
      echo "    Reiniciando Tomcat 9..."
      echo ""
      sudo systemctl restart tomcat9

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Scada-LTS para Debian 10 (Buster)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Scada-LTS para Debian 9 (Stretch)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Scada-LTS para Debian 8 (Jessie)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Scada-LTS para Debian 7 (Wheezy)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  fi

