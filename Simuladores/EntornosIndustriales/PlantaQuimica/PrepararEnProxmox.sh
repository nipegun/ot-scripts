#!/bin/bash

#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para crear un laboratorio de ciberseguridad industrial de una planta química en Proxmox
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Simuladores/EntornosIndustriales/PlantaQuimica/PrepararEnProxmox.sh | bash
#
# Ejecución remota con parámetros:
#   curl sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Simuladores/EntornosIndustriales/PlantaQuimica/PrepararEnProxmox.sh | bash -s Almacenamiento
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Simuladores/EntornosIndustriales/PlantaQuimica/PrepararEnProxmox.sh | nano -
# ----------

# Definir el almacenamiento
vAlmacenamiento=${1:-'local-lvm'} # Si le paso un parámetro, el almacenamiento será el primer parámetro. Si no, será local-lvm.

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Notificar inicio de ejecución del script
  echo ""
  echo -e "${cColorAzulClaro}  Iniciando el script de creación de laboratorio de ciberseguridad para Promxox...${cFinColor}"
  echo ""

# Comprobar si el script está corriendo como root
  #if [ $(id -u) -ne 0 ]; then     # Sólo comprueba si es root
  if [[ $EUID -ne 0 ]]; then       # Comprueba si es root o sudo
    echo ""
    echo -e "${cColorRojo}    Este script está preparado para ejecutarse con privilegios de administrador (como root o con sudo).${cFinColor}"
    echo ""
    exit
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
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del pack de planta química para Proxmox 9...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Proxmox 9 todavía no preparados. Prueba ejecutarlo en otra versión de Proxmox.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del pack de planta química para Proxmox 8...${cFinColor}"
    echo ""

    # Crear el menú
      # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}    El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          apt-get -y update
          apt-get -y install dialog
          echo ""
        fi
      menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
        opciones=(
          1 "Crear los puentes"                      on
          2 "Crear la máquina virtual pfSense"       on
          3 "  Importar .vmdk de pfSense"            on
          4 "Crear la máquina virtual ChemicalPlant" on
          5 "  Importar .vmdk de ChemicalPlant"      on
          6 "Crear la máquina virtual PLC..."        off
          7 "  Importar .vmdk de PLC..."             off
          8 "Crear la máquina virtual ScadaBR"       off
          9 "  Importar .vmdk de ScadaBR"            off
         10 "Crear la máquina virtual WorkStation"   off
         11 "  Importar .vmdk de WorkStation"        off
         12 "x"                                      on
         13 "Agrupar las máquinas virtuales"         on
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
      #clear

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Creando los puentes..."
              echo ""
              # Crear el puente vmbr100
                ip link add name vmbr300 type bridge
                ip link set dev vmbr300 up
              # Crear el puente vmbr200
                ip link add name vmbr400 type bridge
                ip link set dev vmbr400 up

              echo ""
              echo "    Haciendo los puentes persistentes..."
              echo ""
              echo ""                                  >> /etc/network/interfaces
              echo "auto vmbr300"                      >> /etc/network/interfaces
              echo "iface vmbr300 inet manual"         >> /etc/network/interfaces
              echo "    bridge-ports none"             >> /etc/network/interfaces
              echo "    bridge-stp off"                >> /etc/network/interfaces
              echo "    bridge-fd 0"                   >> /etc/network/interfaces
              echo "# Switch para la DMZ de GRFICSv2"  >> /etc/network/interfaces
              echo ""                                  >> /etc/network/interfaces
              echo "auto vmbr400"                      >> /etc/network/interfaces
              echo "iface vmbr400 inet manual"         >> /etc/network/interfaces
              echo "    bridge-ports none"             >> /etc/network/interfaces
              echo "    bridge-stp off"                >> /etc/network/interfaces
              echo "    bridge-fd 0"                   >> /etc/network/interfaces
              echo "# Switch para la LAN del GRFICSv2" >> /etc/network/interfaces
              echo ""                                  >> /etc/network/interfaces

            ;;

            2)

              echo ""
              echo "  Creando la máquina virtual pfSense..."
              echo ""
              qm create 3000 \
                --name pfsense \
                --machine q35 \
                --bios ovmf \
                --numa 0 \
                --sockets 1 \
                --cpu x86-64-v2-AES \
                --cores 2 \
                --memory 2048 \
                --balloon 0 \
                --net0 virtio,bridge=vmbr0,firewall=1 \
                --net1 virtio=00:aa:aa:aa:03:00,bridge=vmbr300,firewall=1 \
                --net2 virtio=00:aa:aa:aa:04:00,bridge=vmbr400,firewall=1 \
                --boot order=sata0 \
                --scsihw virtio-scsi-single \
                --ostype l26 \
                --agent 1

            ;;

            3)

              echo ""
              echo "    Importando .vmdk de pfSense..."
              echo ""
              # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}      El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  apt-get -y update
                  apt-get -y install curl
                  echo ""
                fi
              curl -L http://hacks4geeks.com/_/descargas/MVs/Discos/Packs/PlantaQuimica/pfSense.vmdk -o /tmp/pfsense.vmdk
              qm importdisk 3000 /tmp/pfsense.vmdk "$vAlmacenamiento" && rm -f /tmp/pfsense.vmdk
              vRutaAlDisco=$(qm config 3000 | grep unused | cut -d' ' -f2)
              qm set 3000 --sata0 $vRutaAlDisco

            ;;

            4)

              echo ""
              echo "  Creando la máquina virtual Chemical Plant..."
              echo ""
              qm create 3002 \
                --name kali \
                --machine q35 \
                --numa 0 \
                --sockets 1 \
                --cpu x86-64-v2-AES \
                --cores 4 \
                --memory 4096 \
                --balloon 0 \
                --vga virtio,memory=512 \
                --net0 virtio=00:aa:aa:aa:30:02,bridge=vmbr300,firewall=1 \
                --boot order=sata0 \
                --scsihw virtio-scsi-single \
                --sata0 none,media=cdrom \
                --ostype l26 \
                --agent 1

            ;;

            5)

              echo ""
              echo "    Importando .vmdk de Kali..."
              echo ""
              # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}      El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  apt-get -y update && apt-get -y install curl
                  echo ""
                fi
              curl -L http://hacks4geeks.com/_/descargas/MVs/Discos/Packs/CyberSecLab/kali.vmdk -o /tmp/kali.vmdk
              qm importdisk 1002 /tmp/kali.vmdk "$vAlmacenamiento" && rm -f /tmp/kali.vmdk
              vRutaAlDisco=$(qm config 1002 | grep unused | cut -d' ' -f2)
              qm set 1002 --virtio0 $vRutaAlDisco
              qm set 1002 --boot order='sata0;virtio0'

            ;;

            6)

              echo ""
              echo "  Creando la máquina virtual de SIFT..."
              echo ""
              echo ""
              echo "    Creando la máquina virtual de sift..."
              echo ""
              qm create 1003 \
                --name sift \
                --machine q35 \
                --bios ovmf \
                --numa 0 \
                --sockets 1 \
                --cpu x86-64-v2-AES \
                --cores 4 \
                --memory 4096 \
                --balloon 0 \
                --vga virtio,memory=512 \
                --net0 virtio=00:aa:aa:aa:10:03,bridge=vmbr100,firewall=1 \
                --boot order=sata0 \
                --scsihw virtio-scsi-single \
                --sata0 none,media=cdrom \
                --ostype l26 \
                --agent 1

            ;;

            7)

              echo ""
              echo "    Importando .vmdk de Sift..."
              echo ""
              # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}      El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  apt-get -y update
                  apt-get -y install curl
                  echo ""
                fi
              curl -L http://hacks4geeks.com/_/descargas/MVs/Discos/Packs/CyberSecLab/sift.vmdk -o /tmp/sift.vmdk
              qm importdisk 1003 /tmp/sift.vmdk "$vAlmacenamiento" && rm -f /tmp/sift.vmdk
              vRutaAlDisco=$(qm config 1003 | grep unused | cut -d' ' -f2)
              qm set 1003 --virtio0 $vRutaAlDisco
              qm set 1003 --boot order='sata0;virtio0'

            ;;

            8)

              echo ""
              echo "  Creando la máquina virtual de Windows Server 22..."
              echo ""
              qm create 1004 \
                --name winserver22 \
                --machine q35 \
                --bios ovmf \
                --numa 0 \
                --sockets 1 \
                --cpu x86-64-v2-AES \
                --cores 4 \
                --memory 4096 \
                --balloon 0 \
                --vga virtio,memory=512 \
                --net0 virtio=00:aa:aa:aa:10:04,bridge=vmbr100,firewall=1 \
                --boot order=sata0 \
                --scsihw virtio-scsi-single \
                --sata0 none,media=cdrom \
                --ostype win11 \
                --agent 1

            ;;

            9)

              echo ""
              echo "    Importando .vmdk de Windows Server 22..."
              echo ""

            ;;

           10)

              echo ""
              echo "  Creando la máquina virtual de Windows 11 Pro..."
              echo ""
              qm create 1005 \
                --name win11pro \
                --machine q35 \
                --bios ovmf \
                --numa 0 \
                --sockets 1 \
                --cpu x86-64-v2-AES \
                --cores 4 \
                --memory 4096 \
                --balloon 0 \
                --vga virtio,memory=512 \
                --net0 virtio=00:aa:aa:aa:10:04,bridge=vmbr100,firewall=1 \
                --boot order=sata0 \
                --scsihw virtio-scsi-single \
                --sata0 none,media=cdrom \
                --ostype win11 \
                --agent 1

            ;;

           11)

              echo ""
              echo "    Importando .vmdk de Windows 11 Pro..."
              echo ""

            ;;

           12)

              echo ""
              echo "  Creando la máquina virtual de pruebas para el lab..."
              echo ""
              qm create 2002 \
                --name pruebas \
                --machine q35 \
                --bios ovmf \
                --numa 0 \
                --sockets 1 \
                --cpu x86-64-v2-AES \
                --cores 4 \
                --memory 4096 \
                --balloon 0 \
                --vga virtio,memory=512 \
                --net0 virtio=00:aa:aa:aa:20:02,bridge=vmbr200,firewall=1 \
                --boot order=sata0 \
                --scsihw virtio-scsi-single \
                --sata0 none,media=cdrom \
                --ostype l26 \
                --agent 1

            ;;

           13)

              echo ""
              echo "  Agrupando las máquinas virtuales..."
              echo ""
              qm set 1000 --tags CyberSecLab 2> /dev/null
              qm set 1002 --tags CyberSecLab 2> /dev/null
              qm set 1003 --tags CyberSecLab 2> /dev/null
              qm set 1004 --tags CyberSecLab 2> /dev/null
              qm set 1005 --tags CyberSecLab 2> /dev/null
              qm set 1006 --tags CyberSecLab 2> /dev/null
              qm set 2002 --tags CyberSecLab 2> /dev/null

            ;;

        esac

    done

  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del pack de planta química para Proxmox 7...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Proxmox 7 todavía no preparados. Prueba ejecutarlo en otra versión de Proxmox.${cFinColor}"
    echo ""

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del pack de planta química para Proxmox 6...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Proxmox 6 todavía no preparados. Prueba ejecutarlo en otra versión de Proxmox.${cFinColor}"
    echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del pack de planta química para Proxmox 5...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Proxmox 5 todavía no preparados. Prueba ejecutarlo en otra versión de Proxmox.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del pack de planta química para Proxmox 4...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Proxmox 4 todavía no preparados. Prueba ejecutarlo en otra versión de Proxmox.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del pack de planta química para Proxmox 3...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Proxmox 3 todavía no preparados. Prueba ejecutarlo en otra versión de Proxmox.${cFinColor}"
    echo ""

  fi
