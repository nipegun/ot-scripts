#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para crear un laboratorio de ciberseguridad industrial de una planta química en Proxmox
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/EntornosVulnerables/GRFICSv2/ImportarEnProxmox.sh | bash
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/EntornosVulnerables/GRFICSv2/importarEnProxmox.sh | bash -s Almacenamiento
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/EntornosVulnerables/GRFICSv2/ImportarEnProxmox.sh | nano -
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
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del entorno vulnerable GRFICSv2 para Proxmox 9...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Proxmox 9 todavía no preparados. Prueba ejecutarlo en otra versión de Proxmox.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del entorno vulnerable GRFICSv2 para Proxmox 8...${cFinColor}"
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
          1 "Crear los puentes"                              off
          2 "  Crear la máquina virtual pfSense"             off
          3 "    Importar el .vmdk de la MV pfSense"         off
          4 "  Crear la máquina virtual 3DChemicalPlant"     off
          5 "    Importar el .vmdk de la MV 3DChemicalPlant" off
          6 "  Crear la máquina virtual PLC..."              off
          7 "    Importar el .vmdk de la MV PLC..."          off
          8 "  Crear la máquina virtual WorkStation"         off
          9 "    Importar el .vmdk de la MV WorkStation"     off
         10 "  Crear la máquina virtual HMIScadaBR"          off
         11 "    Importar el .vmdk de la MV HMIScadaBR"      off
         12 "  Crear la máquina virtual Kali"                off
         13 "    Importar el .vmdk de la MV Kali"            off
         14 "Agrupar las máquinas virtuales"                 on
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
              echo "  Creando la máquina virtual GRFICSv2-pfSense..."
              echo ""
              qm create 4000 \
                --name GRFICSv2-pfSense \
                --machine q35 \
                #--bios ovmf \
                --numa 0 \
                --sockets 1 \
                --cpu x86-64-v2-AES \
                --cores 2 \
                --memory 2048 \
                --balloon 0 \
                --net0 virtio,bridge=vmbr0,firewall=1 \
                --net1 e1000=00:aa:aa:aa:03:00,bridge=vmbr300,firewall=1 \
                --net2 e1000=00:aa:aa:aa:04:00,bridge=vmbr400,firewall=1 \
                --boot order=sata0 \
                --scsihw virtio-scsi-single \
                --ostype l26 \
                --agent 1

            ;;

            3)

              echo ""
              echo "    Importando el .vmdk para la MV GRFICSv2-pfSense..."
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
              curl -L http://hacks4geeks.com/_/descargas/MVs/Discos/Packs/GRFICSv2/grficsv2-pfSense.vmdk -o /tmp/grficsv2-pfsense.vmdk
              qm importdisk 4000 /tmp/grficsv2-pfsense.vmdk "$vAlmacenamiento" && rm -f /tmp/grficsv2-pfsense.vmdk
              vRutaAlDisco=$(qm config 4000 | grep unused | cut -d' ' -f2)
              qm set 4000 --sata0 $vRutaAlDisco

            ;;

            4)

              echo ""
              echo "  Creando la máquina virtual GRFICSv2-3DChemicalPlant..."
              echo ""
              qm create 4001 \
                --name GRFICSv2-3DChemicalPlant \
                --machine q35 \
                #--bios ovmf \
                --numa 0 \
                --sockets 1 \
                --cpu x86-64-v2-AES \
                --cores 4 \
                --memory 4096 \
                --balloon 0 \
                --vga virtio,memory=512 \
                --net0 virtio=00:aa:aa:aa:04:01,bridge=vmbr400,firewall=1 \
                --boot order=sata0 \
                --scsihw virtio-scsi-single \
                --sata0 none,media=cdrom \
                --ostype l26 \
                --agent 1

            ;;

            5)

              echo ""
              echo "    Importando el .vmdk para la MV GRFICSv2-3DChemicalPlant..."
              echo ""
              # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}      El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  apt-get -y update && apt-get -y install curl
                  echo ""
                fi
              curl -L http://hacks4geeks.com/_/descargas/MVs/Discos/Packs/GRFICSv2/grficsv2-3DChemicalPlant.vmdk -o /tmp/grficsv2-3dchemicalplant.vmdk
              qm importdisk 4001 /tmp/grficsv2-3dchemicalplant.vmdk "$vAlmacenamiento" && rm -f /tmp/grficsv2-3dchemicalplant.vmdk
              vRutaAlDisco=$(qm config 4001 | grep unused | cut -d' ' -f2)
              qm set 4001 --virtio0 $vRutaAlDisco
              qm set 4001 --boot order='sata0;virtio0'

            ;;

            6)

              echo ""
              echo "  Creando la máquina virtual GRFICSv2-PLC..."
              echo ""
              qm create 4002 \
                --name GRFICSv2-PLC \
                --machine q35 \
                #--bios ovmf \
                --numa 0 \
                --sockets 1 \
                --cpu x86-64-v2-AES \
                --cores 4 \
                --memory 4096 \
                --balloon 0 \
                --vga virtio,memory=512 \
                --net0 virtio=00:aa:aa:aa:04:02,bridge=vmbr400,firewall=1 \
                --boot order=sata0 \
                --scsihw virtio-scsi-single \
                --sata0 none,media=cdrom \
                --ostype l26 \
                --agent 1

            ;;

            7)

              echo ""
              echo "    Importando el .vmdk para la MV GRFICSv2-PLC..."
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
              curl -L http://hacks4geeks.com/_/descargas/MVs/Discos/Packs/GRFICSv2/grficsv2-plc.vmdk -o /tmp/grficsv2-plc.vmdk
              qm importdisk 4002 /tmp/grficsv2-plc.vmdk "$vAlmacenamiento" && rm -f /tmp/grficsv2-plc.vmdk
              vRutaAlDisco=$(qm config 4002 | grep unused | cut -d' ' -f2)
              qm set 4002 --virtio0 $vRutaAlDisco
              qm set 4002 --boot order='sata0;virtio0'

            ;;

            8)

              echo ""
              echo "  Creando la máquina virtual GRFICSv2-WorkStation..."
              echo ""
              qm create 4003 \
                --name GRFICSv2-WorkStation \
                --machine q35 \
                #--bios ovmf \
                --numa 0 \
                --sockets 1 \
                --cpu x86-64-v2-AES \
                --cores 4 \
                --memory 4096 \
                --balloon 0 \
                --vga virtio,memory=512 \
                --net0 virtio=00:aa:aa:aa:04:03,bridge=vmbr400,firewall=1 \
                --boot order=sata0 \
                --scsihw virtio-scsi-single \
                --sata0 none,media=cdrom \
                --ostype win11 \
                --agent 1

            ;;

            9)

              echo ""
              echo "    Importando el .vmdk para la MV GRFICSv2-Workstation..."
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
              curl -L http://hacks4geeks.com/_/descargas/MVs/Discos/Packs/GRFICSv2/grficsv2-workstation.vmdk -o /tmp/grficsv2-workstation.vmdk
              qm importdisk 4003 /tmp/grficsv2-workstation.vmdk "$vAlmacenamiento" && rm -f /tmp/grficsv2-workstation.vmdk
              vRutaAlDisco=$(qm config 4003 | grep unused | cut -d' ' -f2)
              qm set 4003 --virtio0 $vRutaAlDisco
              qm set 4003 --boot order='sata0;virtio0'

            ;;

           10)

              echo ""
              echo "  Creando la máquina virtual GRFICSv2-HMIScadaBR..."
              echo ""
              qm create 3008 \
                --name GRFICSv2-HMIScadaBR \
                --machine q35 \
                #--bios ovmf \
                --numa 0 \
                --sockets 1 \
                --cpu x86-64-v2-AES \
                --cores 4 \
                --memory 4096 \
                --balloon 0 \
                --vga virtio,memory=512 \
                --net0 virtio=00:aa:aa:aa:03:08,bridge=vmbr300,firewall=1 \
                --boot order=sata0 \
                --scsihw virtio-scsi-single \
                --sata0 none,media=cdrom \
                --ostype win11 \
                --agent 1

            ;;

           11)

              echo ""
              echo "    Importando el .vmdk para la MV GRFICSv2-HMIScadaBR..."
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
              curl -L http://hacks4geeks.com/_/descargas/MVs/Discos/Packs/GRFICSv2/grficsv2-hmiscadabr.vmdk -o /tmp/grficsv2-hmiscadabr.vmdk
              qm importdisk 3008 /tmp/grficsv2-hmiscadabr.vmdk "$vAlmacenamiento" && rm -f /tmp/grficsv2-hmiscadabr.vmdk
              vRutaAlDisco=$(qm config 3008 | grep unused | cut -d' ' -f2)
              qm set 3008 --virtio0 $vRutaAlDisco
              qm set 3008 --boot order='sata0;virtio0'

            ;;

           12)

              echo ""
              echo "  Creando la máquina virtual GRFICSv2-Kali..."
              echo ""
              qm create 3009 \
                --name grficsv2-Kali \
                --machine q35 \
                #--bios ovmf \
                --numa 0 \
                --sockets 1 \
                --cpu x86-64-v2-AES \
                --cores 4 \
                --memory 4096 \
                --balloon 0 \
                --vga virtio,memory=512 \
                --net0 virtio=00:aa:aa:aa:03:09,bridge=vmbr300,firewall=1 \
                --boot order=sata0 \
                --scsihw virtio-scsi-single \
                --sata0 none,media=cdrom \
                --ostype l26 \
                --agent 1

            ;;

           13)

              echo ""
              echo "    Importando el .vmdk para la MV GRFICSv2-Kali..."
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
              curl -L http://hacks4geeks.com/_/descargas/MVs/Discos/Packs/GRFICSv2/grficsv2-kali.vmdk -o /tmp/grficsv2-kali.vmdk
              qm importdisk 3009 /tmp/grficsv2-kali.vmdk "$vAlmacenamiento" && rm -f /tmp/grficsv2-kali.vmdk
              vRutaAlDisco=$(qm config 3009 | grep unused | cut -d' ' -f2)
              qm set 3009 --virtio0 $vRutaAlDisco
              qm set 3009 --boot order='sata0;virtio0'

            ;;

           14)

              echo ""
              echo "  Agrupando las máquinas virtuales..."
              echo ""
              qm set 3008 --tags GRFICSv2 2> /dev/null
              qm set 3009 --tags GRFICSv2 2> /dev/null
              qm set 4000 --tags GRFICSv2 2> /dev/null
              qm set 4001 --tags GRFICSv2 2> /dev/null
              qm set 4002 --tags GRFICSv2 2> /dev/null
              qm set 4003 --tags GRFICSv2 2> /dev/null

            ;;

        esac

    done

  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del entorno vulnerable GRFICSv2 para Proxmox 7...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Proxmox 7 todavía no preparados. Prueba ejecutarlo en otra versión de Proxmox.${cFinColor}"
    echo ""

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del entorno vulnerable GRFICSv2 para Proxmox 6...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Proxmox 6 todavía no preparados. Prueba ejecutarlo en otra versión de Proxmox.${cFinColor}"
    echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del entorno vulnerable GRFICSv2 para Proxmox 5...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Proxmox 5 todavía no preparados. Prueba ejecutarlo en otra versión de Proxmox.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del entorno vulnerable GRFICSv2 para Proxmox 4...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Proxmox 4 todavía no preparados. Prueba ejecutarlo en otra versión de Proxmox.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de importación del entorno vulnerable GRFICSv2 para Proxmox 3...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Proxmox 3 todavía no preparados. Prueba ejecutarlo en otra versión de Proxmox.${cFinColor}"
    echo ""

  fi
