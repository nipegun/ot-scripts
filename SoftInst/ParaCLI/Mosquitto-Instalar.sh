#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar Mosquitto en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ParaCLI/Mosquitto-Instalar.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ParaCLI/Mosquitto-Instalar.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/SoftInst/ParaCLI/Mosquitto-Instalar.sh | nano -
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
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Mosquitto para Debian 13 (x)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Mosquitto para Debian 12 (Bookworm)...${cFinColor}"
    echo ""

    # Crear el menú
      # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          sudo apt-get -y update
          sudo apt-get -y install dialog
          echo ""
        fi
      #menu=(dialog --timeout 5 --checklist "Marca las opciones que quieras instalar:" 22 96 16)
      menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
        opciones=(
          1 "Instalación básica"                                     on
          2 "  Permitir escuchar desde todas las direcciones de red" off
          3 "  Permitir el envío de mensajes a usuarios anónimos"    off
          4 "  Activar los logs completos"                           off
          5 "Opción 5"                                               off
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
      #clear

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Ejecutando instalación básica..."
              echo ""

              # Actualizar la lista de paquetes de los repos
                echo ""
                echo "    Actualizando la lista de paquetes disponibles en los repositorios..."
                echo ""
                sudo apt-get -y update

              # Instalar los paquetes
                echo ""
                echo "    Instalando los paquetes mosquitto y mosquitto clients"
                echo "" 
                sudo apt-get -y install mosquitto
                sudo apt-get -y install mosquitto-clients

              # Habilitar e iniciar el servicio
                echo ""
                echo "    Habilitando e iniciando el servicio..."
                echo ""
                sudo systemctl enable mosquitto --now

              # Mostrar estado del servicio
                echo ""
                echo "    Mostrando el estado del servicio..."
                echo ""
                sudo systemctl status mosquitto --no-pager

              # Notificar fin de ejecución del script
                echo ""
                echo "    Script de instalación de mosquitto, finalizado."
                echo ""
                echo "      Para suscribirse a un tema, ejecuta en una terminal:"
                echo '        mosquitto_sub -h localhost -t "prueba/tema"'
                echo "      Publicar un mensaje: En otra terminal, ejecuta:"
                echo '        mosquitto_pub -h localhost -t "prueba/tema" -m "Hola, MQTT"'
                echo ""
                echo "      Para ver los logs en tiempo real:"
                echo ""
                echo "        sudo tail -f /var/log/mosquitto/mosquitto.log"
                echo ""

            ;;

            2)

              echo ""
              echo "  Permitiendo escuchar desde todas las direcciones de red..."
              echo ""
              echo -e "bind_address 0.0.0.0" | sudo tee /etc/mosquitto/conf.d/AllowAllNet.conf

              # Habilitar e iniciar el servicio
                echo ""
                echo "    Reiniciando el servicio..."
                echo ""
                sudo systemctl restart mosquitto

            ;;

            3)

              echo ""
              echo "  Activando envíos de mensajes anónimos..."
              echo ""
              echo -e "allow_anonymous true" | sudo tee /etc/mosquitto/conf.d/AllowAnonymous.conf

              # Habilitar e iniciar el servicio
                echo ""
                echo "    Reiniciando el servicio..."
                echo ""
                sudo systemctl restart mosquitto

            ;;

            4)

              echo ""
              echo "  Activando los logs completos..."
              echo ""
              echo -e "log_type all" | sudo tee /etc/mosquitto/conf.d/AllowCompleteLogs.conf

              # Habilitar e iniciar el servicio
                echo ""
                echo "    Reiniciando el servicio..."
                echo ""
                sudo systemctl restart mosquitto

            ;;

            5)

              echo ""
              echo "  Opción 5..."
              echo ""

            ;;

        esac

    done

  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Mosquitto para Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 11 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Mosquitto para Debian 10 (Buster)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Mosquitto para Debian 9 (Stretch)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Mosquitto para Debian 8 (Jessie)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Mosquitto para Debian 7 (Wheezy)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  fi
