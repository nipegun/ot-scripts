#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para descargar e importar el entorno virtual GRFICSv2 para VirtualBox en Debian distros basadas en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/EntornosVulnerables/GRFICSv2/ImportarEnVirtualBoxDeDebianYDerivados.sh | bash
#
# Ejecución remota como root:
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/EntornosVulnerables/GRFICSv2/ImportarEnVirtualBoxDeDebianYDerivados.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/EntornosVulnerables/GRFICSv2/ImportarEnVirtualBoxDeDebianYDerivados.sh | nano -
# ----------

#
#  Referencia: https://github.com/Fortiphyd/GRFICSv2
#

vURLBaseVMDKs='http://hacks4geeks.com/_/descargas/MVs/Discos/Packs/GRFICSv2'

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

    # Definir fecha de ejecución del script
      cFechaDeEjec=$(date +a%Ym%md%d@%T)

    # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}    El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update
        sudo apt-get -y install dialog
        echo ""
      fi

    # Crear el menú
      menu=(dialog --checklist "Marca las tareas que quieras ejecutar:" 22 60 16)
        opciones=(
          1 "Instalar VirtualBox"         off
          2 "Importar máquinas virtuales" on
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Lanzando el script de instalación de VirtualBox..."
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
              curl -sL https://raw.githubusercontent.com/nipegun/d-scripts/refs/heads/master/SoftInst/ParaGUI/VirtualBox-Instalar.sh | sudo bash

            ;;

            2)

              echo ""
              echo "  Creando entorno vulnerable en VirtualBox..."
              echo ""

              # Definir fecha de ejecución del script
                cFechaDeEjec=$(date +a%Ym%md%d@%T)

              # Crear el menú
                # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}   El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update
                    sudo apt-get -y install dialog
                    echo ""
                  fi
                menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 70 16)
                  opciones=(

                     1 "  Crear máquina virtual de pfSense"                      on
                     2 "    Descargar e importar VHD para la MV pfSense"         off
                     3 "  Crear máquina virtual de 3DChemicalPlant"              on
                     4 "    Descargar e importar VHD para la MV 3DChemicalPlant" off
                     5 "  Crear máquina virtual de PLC"                          on
                     6 "    Descargar e importar VHD para la MV PLC"             off
                     7 "  Crear máquina virtual de WorkStation"                  on
                     8 "    Descargar e importar VHD para la MV WorkStation"     off
                     9 "  Crear máquina virtual de HMIScadaBR"                   on
                    10 "    Descargar e importar VHD para la MV HMIScadaBR"      off
                    11 "  Crear máquina virtual de Kali"                         on
                    12 "    Descargar e importar VHD para la MV Kali"            off
                    13 "    Agrupar máquinas virtuales"                          on
                    14 "    Iniciar las máquinas virtuales en orden"             off

                  )
                choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

                for choice in $choices
                  do
                    case $choice in

                      1)

                          echo ""
                          echo "    Importando máquina virtual de pfSense..."
                          echo ""
                          VBoxManage createvm --name "GRFICSv2-pfSense" --ostype "Linux_64" --register
                          # Procesador
                            VBoxManage modifyvm "GRFICSv2-pfSense" --cpus 2
                          # RAM
                            VBoxManage modifyvm "GRFICSv2-pfSense" --memory 2048
                          # Gráfica
                            VBoxManage modifyvm "GRFICSv2-pfSense" --graphicscontroller vmsvga --vram 128 --accelerate3d on
                          # Audio
                            VBoxManage modifyvm "GRFICSv2-pfSense" --audio-driver none
                          # Red
                            VBoxManage modifyvm "GRFICSv2-pfSense" --nictype1 82540EM
                              VBoxManage modifyvm "GRFICSv2-pfSense" --nic1 intnet --intnet1 "RedIntOper"
                            # Poner en modo promiscuo
                              VBoxManage modifyvm "GRFICSv2-pfSense" --nicpromisc1 allow-all
                            VBoxManage modifyvm "GRFICSv2-pfSense" --nictype2 82540EM
                              VBoxManage modifyvm "GRFICSv2-pfSense" --nic2 intnet --intnet2 "RedIntInd"
                            # Poner en modo promiscuo
                              VBoxManage modifyvm "GRFICSv2-pfSense" --nicpromisc2 allow-all

                          # Almacenamiento
                            # Controlador
                              VBoxManage storagectl "GRFICSv2-pfSense" --name "SATA Controller" --add sata --controller IntelAhci --portcount 1
                            # CD
                              VBoxManage storageattach "GRFICSv2-pfSense" --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium emptydrive

                      ;;

                      2)

                         echo ""
                         echo "    Descargando e importando el disco duro virtual para la MV pfSense..."
                         echo ""

                         # Definir el espacio libre necesario
                           vGBsLibresNecesarios=2
                           vEspacioNecesario=$(($vGBsLibresNecesarios * 1024 * 1024)) # Convertir a kilobytes (1GB = 1048576KB)

                         # Obtener el espacio libre de la partición en la que está montada la /tmp
                           # Verificar si /tmp está montada en la RAM o sobre la partición raíz
                             vDondeMontadoTmp=$(mount | grep '/tmp')
                             if [[ "$vDondeMontadoTmp" == tmpfs\ on\ /tmp\ type\ tmpfs* ]]; then
                               vEspacioLibre=$(df /tmp | grep '/tmp' | tail -1 | sed -E 's/\s+/ /g' | cut -d ' ' -f 4)
                             elif [[ -z "$salida" ]]; then
                               vEspacioLibre=$(df /tmp | tail -1 | sed -E 's/\s+/ /g' | cut -d ' ' -f 4)
                             else
                               vEspacioLibre=0
                             fi
                           vGBsLibres=$(echo "scale=2; $vEspacioLibre/1024/1024" | bc)

                         # Comprobar si hay espacio libre disponible
                           if [ "$vEspacioLibre" -ge "$vEspacioNecesario" ]; then
                             # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
                               if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
                                 echo ""
                                 echo -e "${cColorRojo}    El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
                                 echo ""
                                 sudo apt-get -y update
                                 sudo apt-get -y install curl
                                 echo ""
                               fi
                             curl -L "$vURLBaseVMDKs"/GRFICSv2-pfSense.vmdk.xz -o /tmp/GRFICSv2-pfSense.vmdk.xz
                             # Descomprimir
                               echo ""
                               echo "      Descomprimiendo..."
                               echo ""
                               # Comprobar si el paquete xz-utils está instalado. Si no lo está, instalarlo.
                                 if [[ $(dpkg-query -s xz-utils 2>/dev/null | grep installed) == "" ]]; then
                                   echo ""
                                   echo -e "${cColorRojo}    El paquete xz-utils no está instalado. Iniciando su instalación...${cFinColor}"
                                   echo ""
                                   sudo apt-get -y update
                                   sudo apt-get -y install xz-utils
                                   echo ""
                                 fi
                             cd /tmp
                             xz -vfdk /tmp/GRFICSv2-pfSense.vmdk.xz
                             # Borrar el archivo comprimido
                               rm -f  /tmp/GRFICSv2-pfSense.vmdk.xz
                          # Obtener nombre de la carpeta de la máquina virtual
                            vCarpeta=$(VBoxManage showvminfo GRFICSv2-pfSense --machinereadable | grep '^CfgFile=' | cut -d'"' -f2 | sed 's|/[^/]*$||')
                          # Mover el disco
                            mv -f /tmp/GRFICSv2-pfSense.vmdk "$vCarpeta"/
                          # Agregarlo a la máquina
                            VBoxManage storageattach "GRFICSv2-pfSense" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "$vCarpeta"/GRFICSv2-pfSense.vmdk
                           else
                             echo ""
                             echo -e "${cColorRojo}    No hay suficiente espacio libre en la carpeta /tmp para descargar y descomprimir el disco virtual.${cFinColor}"
                             echo ""
                             echo -e "${cColorRojo}      Hacen falta $vGBsLibresNecesarios GB y hay sólo $vGBsLibres GB.${cFinColor}"
                             echo ""
                           fi

                      ;;

                      3)

                          echo ""
                          echo "    Importando máquina virtual de 3DChemicalPlant..."
                          echo ""
                          VBoxManage createvm --name "GRFICSv2-3DChemicalPlant" --ostype "Ubuntu_64" --register
                          # Procesador
                            VBoxManage modifyvm "GRFICSv2-3DChemicalPlant" --cpus 2
                          # RAM
                            VBoxManage modifyvm "GRFICSv2-3DChemicalPlant" --memory 2048
                          # Gráfica
                            VBoxManage modifyvm "GRFICSv2-3DChemicalPlant" --graphicscontroller vmsvga --vram 128 --accelerate3d on
                          # Audio
                            VBoxManage modifyvm "GRFICSv2-3DChemicalPlant" --audio-driver none
                          # Red
                            VBoxManage modifyvm "GRFICSv2-3DChemicalPlant" --nictype1 virtio
                              VBoxManage modifyvm "GRFICSv2-3DChemicalPlant" --nic1 intnet --intnet1 "RedIntInd"
                            # Poner en modo promiscuo
                              VBoxManage modifyvm "GRFICSv2-3DChemicalPlant" --nicpromisc1 allow-all

                          # Almacenamiento
                            # Controlador
                              VBoxManage storagectl "GRFICSv2-3DChemicalPlant" --name "SATA Controller" --add sata --controller IntelAhci --portcount 1
                            # CD
                              VBoxManage storageattach "GRFICSv2-3DChemicalPlant" --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
                            # Controladora de disco duro
                              VBoxManage storagectl "GRFICSv2-3DChemicalPlant" --name "VirtIO" --add "VirtIO" --bootable on --portcount 1

                      ;;

                      4)

                         echo ""
                         echo "    Descargando e importando el disco duro virtual para la MV 3DChemicalPlant..."
                         echo ""

                         # Definir el espacio libre necesario
                           vGBsLibresNecesarios=4
                           vEspacioNecesario=$(($vGBsLibresNecesarios * 1024 * 1024)) # Convertir a kilobytes (1GB = 1048576KB)

                         # Obtener el espacio libre de la partición en la que está montada la /tmp
                           # Verificar si /tmp está montada en la RAM o sobre la partición raíz
                             vDondeMontadoTmp=$(mount | grep '/tmp')
                             if [[ "$vDondeMontadoTmp" == tmpfs\ on\ /tmp\ type\ tmpfs* ]]; then
                               vEspacioLibre=$(df /tmp | grep '/tmp' | tail -1 | sed -E 's/\s+/ /g' | cut -d ' ' -f 4)
                             elif [[ -z "$salida" ]]; then
                               vEspacioLibre=$(df /tmp | tail -1 | sed -E 's/\s+/ /g' | cut -d ' ' -f 4)
                             else
                               vEspacioLibre=0
                             fi
                           vGBsLibres=$(echo "scale=2; $vEspacioLibre/1024/1024" | bc)

                         # Comprobar si hay espacio libre disponible
                           if [ "$vEspacioLibre" -ge "$vEspacioNecesario" ]; then
                             # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
                               if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
                                 echo ""
                                 echo -e "${cColorRojo}    El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
                                 echo ""
                                 sudo apt-get -y update
                                 sudo apt-get -y install curl
                                 echo ""
                               fi
                             curl -L "$vURLBaseVMDKs"/GRFICSv2-3DChemicalPlant.vmdk.xz -o /tmp/GRFICSv2-3DChemicalPlant.vmdk.xz
                             # Descomprimir
                               echo ""
                               echo "      Descomprimiendo..."
                               echo ""
                               # Comprobar si el paquete xz-utils está instalado. Si no lo está, instalarlo.
                                 if [[ $(dpkg-query -s xz-utils 2>/dev/null | grep installed) == "" ]]; then
                                   echo ""
                                   echo -e "${cColorRojo}    El paquete xz-utils no está instalado. Iniciando su instalación...${cFinColor}"
                                   echo ""
                                   sudo apt-get -y update
                                   sudo apt-get -y install xz-utils
                                   echo ""
                                 fi
                             cd /tmp
                             xz -vfdk /tmp/GRFICSv2-3DChemicalPlant.vmdk.xz
                             # Borrar el archivo comprimido
                               rm -f  /tmp/GRFICSv2-3DChemicalPlant.vmdk.xz
                          # Obtener nombre de la carpeta de la máquina virtual
                            vCarpeta=$(VBoxManage showvminfo GRFICSv2-3DChemicalPlant --machinereadable | grep '^CfgFile=' | cut -d'"' -f2 | sed 's|/[^/]*$||')
                          # Mover el disco
                            mv -f /tmp/GRFICSv2-3DChemicalPlant.vmdk "$vCarpeta"/
                          # Agregarlo a la máquina
                            VBoxManage storageattach "GRFICSv2-3DChemicalPlant" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "$vCarpeta"/GRFICSv2-3DChemicalPlant.vmdk
                           else
                             echo ""
                             echo -e "${cColorRojo}    No hay suficiente espacio libre en la carpeta /tmp para descargar y descomprimir el disco virtual.${cFinColor}"
                             echo ""
                             echo -e "${cColorRojo}      Hacen falta $vGBsLibresNecesarios GB y hay sólo $vGBsLibres GB.${cFinColor}"
                             echo ""
                           fi

                      ;;

                      5)

                          echo ""
                          echo "    Importando máquina virtual de PLC..."
                          echo ""
                          VBoxManage createvm --name "GRFICSv2-PLC" --ostype "Ubuntu" --register
                          # Procesador
                            VBoxManage modifyvm "GRFICSv2-PLC" --cpus 2
                          # RAM
                            VBoxManage modifyvm "GRFICSv2-PLC" --memory 2048
                          # Gráfica
                            VBoxManage modifyvm "GRFICSv2-PLC" --graphicscontroller vmsvga --vram 128 --accelerate3d on
                          # Audio
                            VBoxManage modifyvm "GRFICSv2-PLC" --audio-driver none
                          # Red
                            VBoxManage modifyvm "GRFICSv2-PLC" --nictype1 virtio
                              VBoxManage modifyvm "GRFICSv2-PLC" --nic1 intnet --intnet1 "RedIntInd"
                            # Poner en modo promiscuo
                              VBoxManage modifyvm "GRFICSv2-PLC" --nicpromisc1 allow-all

                          # Almacenamiento
                            # Controlador
                              VBoxManage storagectl "GRFICSv2-PLC" --name "SATA Controller" --add sata --controller IntelAhci --portcount 1
                            # CD
                              VBoxManage storageattach "GRFICSv2-PLC" --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
                            # Controladora de disco duro
                              VBoxManage storagectl "GRFICSv2-PLC" --name "VirtIO" --add "VirtIO" --bootable on --portcount 1

                      ;;

                      6)

                         echo ""
                         echo "    Descargando e importando el disco duro virtual para la MV PLC..."
                         echo ""

                         # Definir el espacio libre necesario
                           vGBsLibresNecesarios=4
                           vEspacioNecesario=$(($vGBsLibresNecesarios * 1024 * 1024)) # Convertir a kilobytes (1GB = 1048576KB)

                         # Obtener el espacio libre de la partición en la que está montada la /tmp
                           # Verificar si /tmp está montada en la RAM o sobre la partición raíz
                             vDondeMontadoTmp=$(mount | grep '/tmp')
                             if [[ "$vDondeMontadoTmp" == tmpfs\ on\ /tmp\ type\ tmpfs* ]]; then
                               vEspacioLibre=$(df /tmp | grep '/tmp' | tail -1 | sed -E 's/\s+/ /g' | cut -d ' ' -f 4)
                             elif [[ -z "$salida" ]]; then
                               vEspacioLibre=$(df /tmp | tail -1 | sed -E 's/\s+/ /g' | cut -d ' ' -f 4)
                             else
                               vEspacioLibre=0
                             fi
                           vGBsLibres=$(echo "scale=2; $vEspacioLibre/1024/1024" | bc)

                         # Comprobar si hay espacio libre disponible
                           if [ "$vEspacioLibre" -ge "$vEspacioNecesario" ]; then
                             # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
                               if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
                                 echo ""
                                 echo -e "${cColorRojo}    El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
                                 echo ""
                                 sudo apt-get -y update
                                 sudo apt-get -y install curl
                                 echo ""
                               fi
                             curl -L "$vURLBaseVMDKs"/GRFICSv2-PLC.vmdk.xz -o /tmp/GRFICSv2-PLC.vmdk.xz
                             # Descomprimir
                               echo ""
                               echo "      Descomprimiendo..."
                               echo ""
                               # Comprobar si el paquete xz-utils está instalado. Si no lo está, instalarlo.
                                 if [[ $(dpkg-query -s xz-utils 2>/dev/null | grep installed) == "" ]]; then
                                   echo ""
                                   echo -e "${cColorRojo}    El paquete xz-utils no está instalado. Iniciando su instalación...${cFinColor}"
                                   echo ""
                                   sudo apt-get -y update
                                   sudo apt-get -y install xz-utils
                                   echo ""
                                 fi
                             cd /tmp
                             xz -vfdk /tmp/GRFICSv2-PLC.vmdk.xz
                             # Borrar el archivo comprimido
                               rm -f  /tmp/GRFICSv2-PLC.vmdk.xz
                          # Obtener nombre de la carpeta de la máquina virtual
                            vCarpeta=$(VBoxManage showvminfo GRFICSv2-PLC --machinereadable | grep '^CfgFile=' | cut -d'"' -f2 | sed 's|/[^/]*$||')
                          # Mover el disco
                            mv -f /tmp/GRFICSv2-PLC.vmdk "$vCarpeta"/
                          # Agregarlo a la máquina
                            VBoxManage storageattach "GRFICSv2-PLC" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "$vCarpeta"/GRFICSv2-PLC.vmdk
                           else
                             echo ""
                             echo -e "${cColorRojo}    No hay suficiente espacio libre en la carpeta /tmp para descargar y descomprimir el disco virtual.${cFinColor}"
                             echo ""
                             echo -e "${cColorRojo}      Hacen falta $vGBsLibresNecesarios GB y hay sólo $vGBsLibres GB.${cFinColor}"
                             echo ""
                           fi

                      ;;

                      7)

                          echo ""
                          echo "    Importando máquina virtual de WorkStation..."
                          echo ""
                          VBoxManage createvm --name "GRFICSv2-WorkStation" --ostype "Ubuntu_64" --register
                          # Procesador
                            VBoxManage modifyvm "GRFICSv2-WorkStation" --cpus 2
                          # RAM
                            VBoxManage modifyvm "GRFICSv2-WorkStation" --memory 2048
                          # Gráfica
                            VBoxManage modifyvm "GRFICSv2-WorkStation" --graphicscontroller vmsvga --vram 128 --accelerate3d on
                          # Audio
                            VBoxManage modifyvm "GRFICSv2-WorkStation" --audio-driver none
                          # Red
                            VBoxManage modifyvm "GRFICSv2-WorkStation" --nictype1 virtio
                              VBoxManage modifyvm "GRFICSv2-WorkStation" --nic1 intnet --intnet1 "RedIntInd"
                            # Poner en modo promiscuo
                              VBoxManage modifyvm "GRFICSv2-WorkStation" --nicpromisc1 allow-all
                            # Poner la dirección mac correcta para que pille IP
                              VBoxManage modifyvm "GRFICSv2-WorkStation" --macaddress1 080027383548

                          # Almacenamiento
                            # Controlador
                              VBoxManage storagectl "GRFICSv2-WorkStation" --name "SATA Controller" --add sata --controller IntelAhci --portcount 1
                            # CD
                              VBoxManage storageattach "GRFICSv2-WorkStation" --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
                            # Controladora de disco duro
                              VBoxManage storagectl "GRFICSv2-WorkStation" --name "VirtIO" --add "VirtIO" --bootable on --portcount 1

                      ;;

                      8)

                         echo ""
                         echo "    Descargando e importando el disco duro virtual para la MV WorkStation..."
                         echo ""

                         # Definir el espacio libre necesario
                           vGBsLibresNecesarios=10
                           vEspacioNecesario=$(($vGBsLibresNecesarios * 1024 * 1024)) # Convertir a kilobytes (1GB = 1048576KB)

                         # Obtener el espacio libre de la partición en la que está montada la /tmp
                           # Verificar si /tmp está montada en la RAM o sobre la partición raíz
                             vDondeMontadoTmp=$(mount | grep '/tmp')
                             if [[ "$vDondeMontadoTmp" == tmpfs\ on\ /tmp\ type\ tmpfs* ]]; then
                               vEspacioLibre=$(df /tmp | grep '/tmp' | tail -1 | sed -E 's/\s+/ /g' | cut -d ' ' -f 4)
                             elif [[ -z "$salida" ]]; then
                               vEspacioLibre=$(df /tmp | tail -1 | sed -E 's/\s+/ /g' | cut -d ' ' -f 4)
                             else
                               vEspacioLibre=0
                             fi
                           vGBsLibres=$(echo "scale=2; $vEspacioLibre/1024/1024" | bc)

                         # Comprobar si hay espacio libre disponible
                           if [ "$vEspacioLibre" -ge "$vEspacioNecesario" ]; then
                             # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
                               if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
                                 echo ""
                                 echo -e "${cColorRojo}    El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
                                 echo ""
                                 sudo apt-get -y update
                                 sudo apt-get -y install curl
                                 echo ""
                               fi
                             curl -L "$vURLBaseVMDKs"/GRFICSv2-WorkStation.vmdk.xz -o /tmp/GRFICSv2-WorkStation.vmdk.xz
                             # Descomprimir
                               echo ""
                               echo "      Descomprimiendo..."
                               echo ""
                               # Comprobar si el paquete xz-utils está instalado. Si no lo está, instalarlo.
                                 if [[ $(dpkg-query -s xz-utils 2>/dev/null | grep installed) == "" ]]; then
                                   echo ""
                                   echo -e "${cColorRojo}    El paquete xz-utils no está instalado. Iniciando su instalación...${cFinColor}"
                                   echo ""
                                   sudo apt-get -y update
                                   sudo apt-get -y install xz-utils
                                   echo ""
                                 fi
                             cd /tmp
                             xz -vfdk /tmp/GRFICSv2-WorkStation.vmdk.xz
                             # Borrar el archivo comprimido
                               rm -f  /tmp/GRFICSv2-WorkStation.vmdk.xz
                          # Obtener nombre de la carpeta de la máquina virtual
                            vCarpeta=$(VBoxManage showvminfo GRFICSv2-WorkStation --machinereadable | grep '^CfgFile=' | cut -d'"' -f2 | sed 's|/[^/]*$||')
                          # Mover el disco
                            mv -f /tmp/GRFICSv2-WorkStation.vmdk "$vCarpeta"/
                          # Agregarlo a la máquina
                            VBoxManage storageattach "GRFICSv2-WorkStation" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "$vCarpeta"/GRFICSv2-WorkStation.vmdk
                           else
                             echo ""
                             echo -e "${cColorRojo}    No hay suficiente espacio libre en la carpeta /tmp para descargar y descomprimir el disco virtual.${cFinColor}"
                             echo ""
                             echo -e "${cColorRojo}      Hacen falta $vGBsLibresNecesarios GB y hay sólo $vGBsLibres GB.${cFinColor}"
                             echo ""
                           fi

                      ;;

                      9)

                          echo ""
                          echo "    Importando máquina virtual de HMIScadaBR..."
                          echo ""
                          VBoxManage createvm --name "GRFICSv2-HMIScadaBR" --ostype "Ubuntu_64" --register
                          # Procesador
                            VBoxManage modifyvm "GRFICSv2-HMIScadaBR" --cpus 2
                          # RAM
                            VBoxManage modifyvm "GRFICSv2-HMIScadaBR" --memory 2048
                          # Gráfica
                            VBoxManage modifyvm "GRFICSv2-HMIScadaBR" --graphicscontroller vmsvga --vram 128 --accelerate3d on
                          # Audio
                            VBoxManage modifyvm "GRFICSv2-HMIScadaBR" --audio-driver none
                          # Red
                            VBoxManage modifyvm "GRFICSv2-HMIScadaBR" --nictype1 virtio
                              VBoxManage modifyvm "GRFICSv2-HMIScadaBR" --nic1 intnet --intnet1 "RedIntOper"
                            # Poner en modo promiscuo
                              VBoxManage modifyvm "GRFICSv2-HMIScadaBR" --nicpromisc1 allow-all

                          # Almacenamiento
                            # Controlador
                              VBoxManage storagectl "GRFICSv2-HMIScadaBR" --name "SATA Controller" --add sata --controller IntelAhci --portcount 1
                            # CD
                              VBoxManage storageattach "GRFICSv2-HMIScadaBR" --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
                            # Controladora de disco duro
                              VBoxManage storagectl "GRFICSv2-HMIScadaBR" --name "VirtIO" --add "VirtIO" --bootable on --portcount 1

                      ;;

                     10)

                         echo ""
                         echo "    Descargando e importando el disco duro virtual para la MV HMIScadaBR..."
                         echo ""

                         # Definir el espacio libre necesario
                           vGBsLibresNecesarios=3
                           vEspacioNecesario=$(($vGBsLibresNecesarios * 1024 * 1024)) # Convertir a kilobytes (1GB = 1048576KB)

                         # Obtener el espacio libre de la partición en la que está montada la /tmp
                           # Verificar si /tmp está montada en la RAM o sobre la partición raíz
                             vDondeMontadoTmp=$(mount | grep '/tmp')
                             if [[ "$vDondeMontadoTmp" == tmpfs\ on\ /tmp\ type\ tmpfs* ]]; then
                               vEspacioLibre=$(df /tmp | grep '/tmp' | tail -1 | sed -E 's/\s+/ /g' | cut -d ' ' -f 4)
                             elif [[ -z "$salida" ]]; then
                               vEspacioLibre=$(df /tmp | tail -1 | sed -E 's/\s+/ /g' | cut -d ' ' -f 4)
                             else
                               vEspacioLibre=0
                             fi
                           vGBsLibres=$(echo "scale=2; $vEspacioLibre/1024/1024" | bc)

                         # Comprobar si hay espacio libre disponible
                           if [ "$vEspacioLibre" -ge "$vEspacioNecesario" ]; then
                             # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
                               if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
                                 echo ""
                                 echo -e "${cColorRojo}    El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
                                 echo ""
                                 sudo apt-get -y update
                                 sudo apt-get -y install curl
                                 echo ""
                               fi
                             curl -L "$vURLBaseVMDKs"/GRFICSv2-HMIScadaBR.vmdk.xz -o /tmp/GRFICSv2-HMIScadaBR.vmdk.xz
                             # Descomprimir
                               echo ""
                               echo "      Descomprimiendo..."
                               echo ""
                               # Comprobar si el paquete xz-utils está instalado. Si no lo está, instalarlo.
                                 if [[ $(dpkg-query -s xz-utils 2>/dev/null | grep installed) == "" ]]; then
                                   echo ""
                                   echo -e "${cColorRojo}    El paquete xz-utils no está instalado. Iniciando su instalación...${cFinColor}"
                                   echo ""
                                   sudo apt-get -y update
                                   sudo apt-get -y install xz-utils
                                   echo ""
                                 fi
                             cd /tmp
                             xz -vfdk /tmp/GRFICSv2-HMIScadaBR.vmdk.xz
                             # Borrar el archivo comprimido
                               rm -f  /tmp/GRFICSv2-HMIScadaBR.vmdk.xz
                          # Obtener nombre de la carpeta de la máquina virtual
                            vCarpeta=$(VBoxManage showvminfo GRFICSv2-HMIScadaBR --machinereadable | grep '^CfgFile=' | cut -d'"' -f2 | sed 's|/[^/]*$||')
                          # Mover el disco
                            mv -f /tmp/GRFICSv2-HMIScadaBR.vmdk "$vCarpeta"/
                          # Agregarlo a la máquina
                            VBoxManage storageattach "GRFICSv2-HMIScadaBR" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "$vCarpeta"/GRFICSv2-HMIScadaBR.vmdk
                           else
                             echo ""
                             echo -e "${cColorRojo}    No hay suficiente espacio libre en la carpeta /tmp para descargar y descomprimir el disco virtual.${cFinColor}"
                             echo ""
                             echo -e "${cColorRojo}      Hacen falta $vGBsLibresNecesarios GB y hay sólo $vGBsLibres GB.${cFinColor}"
                             echo ""
                           fi

                      ;;

                     11)

                          echo ""
                          echo "    Importando máquina virtual de Kali..."
                          echo ""
                          VBoxManage createvm --name "GRFICSv2-Kali" --ostype "Debian_64" --register
                          # Procesador
                            VBoxManage modifyvm "GRFICSv2-Kali" --cpus 2
                          # RAM
                            VBoxManage modifyvm "GRFICSv2-Kali" --memory 4096
                          # Gráfica
                            VBoxManage modifyvm "GRFICSv2-Kali" --graphicscontroller vmsvga --vram 128 --accelerate3d on
                          # Audio
                            VBoxManage modifyvm "GRFICSv2-Kali" --audio-driver none
                          # Red
                            VBoxManage modifyvm "GRFICSv2-Kali" --nictype1 virtio
                              VBoxManage modifyvm "GRFICSv2-Kali" --nic1 intnet --intnet1 "RedIntOper"
                            # Poner en modo promiscuo
                              VBoxManage modifyvm "GRFICSv2-Kali" --nicpromisc1 allow-all

                          # Almacenamiento
                            # Controlador
                              VBoxManage storagectl "GRFICSv2-Kali" --name "SATA Controller" --add sata --controller IntelAhci --portcount 1
                            # CD
                              VBoxManage storageattach "GRFICSv2-Kali" --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
                            # Controladora de disco duro
                              VBoxManage storagectl "GRFICSv2-Kali" --name "VirtIO" --add "VirtIO" --bootable on --portcount 1

                      ;;

                     12)

                         echo ""
                         echo "    Descargando e importando el disco duro virtual para la MV Kali..."
                         echo ""

                         # Definir el espacio libre necesario
                           vGBsLibresNecesarios=2
                           vEspacioNecesario=$(($vGBsLibresNecesarios * 1024 * 1024)) # Convertir a kilobytes (1GB = 1048576KB)

                         # Obtener el espacio libre de la partición en la que está montada la /tmp
                           # Verificar si /tmp está montada en la RAM o sobre la partición raíz
                             vDondeMontadoTmp=$(mount | grep '/tmp')
                             if [[ "$vDondeMontadoTmp" == tmpfs\ on\ /tmp\ type\ tmpfs* ]]; then
                               vEspacioLibre=$(df /tmp | grep '/tmp' | tail -1 | sed -E 's/\s+/ /g' | cut -d ' ' -f 4)
                             elif [[ -z "$salida" ]]; then
                               vEspacioLibre=$(df /tmp | tail -1 | sed -E 's/\s+/ /g' | cut -d ' ' -f 4)
                             else
                               vEspacioLibre=0
                             fi
                           vGBsLibres=$(echo "scale=2; $vEspacioLibre/1024/1024" | bc)

                         # Comprobar si hay espacio libre disponible
                           if [ "$vEspacioLibre" -ge "$vEspacioNecesario" ]; then
                             # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
                               if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
                                 echo ""
                                 echo -e "${cColorRojo}    El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
                                 echo ""
                                 sudo apt-get -y update
                                 sudo apt-get -y install curl
                                 echo ""
                               fi
                             curl -L "$vURLBaseVMDKs"/GRFICSv2-Kali.vmdk.xz -o /tmp/GRFICSv2-Kali.vmdk.xz
                             # Descomprimir
                               echo ""
                               echo "      Descomprimiendo..."
                               echo ""
                               # Comprobar si el paquete xz-utils está instalado. Si no lo está, instalarlo.
                                 if [[ $(dpkg-query -s xz-utils 2>/dev/null | grep installed) == "" ]]; then
                                   echo ""
                                   echo -e "${cColorRojo}    El paquete xz-utils no está instalado. Iniciando su instalación...${cFinColor}"
                                   echo ""
                                   sudo apt-get -y update
                                   sudo apt-get -y install xz-utils
                                   echo ""
                                 fi
                             cd /tmp
                             xz -vfdk /tmp/GRFICSv2-Kali.vmdk.xz
                             # Borrar el archivo comprimido
                               rm -f  /tmp/GRFICSv2-Kali.vmdk.xz
                          # Obtener nombre de la carpeta de la máquina virtual
                            vCarpeta=$(VBoxManage showvminfo GRFICSv2-Kali --machinereadable | grep '^CfgFile=' | cut -d'"' -f2 | sed 's|/[^/]*$||')
                          # Mover el disco
                            mv -f /tmp/GRFICSv2-Kali.vmdk "$vCarpeta"/
                          # Agregarlo a la máquina
                            VBoxManage storageattach "GRFICSv2-Kali" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "$vCarpeta"/GRFICSv2-Kali.vmdk
                           else
                             echo ""
                             echo -e "${cColorRojo}    No hay suficiente espacio libre en la carpeta /tmp para descargar y descomprimir el disco virtual.${cFinColor}"
                             echo ""
                             echo -e "${cColorRojo}      Hacen falta $vGBsLibresNecesarios GB y hay sólo $vGBsLibres GB.${cFinColor}"
                             echo ""
                           fi

                      ;;

                     13)

                        echo ""
                        echo "  Agrupando máquinas virtuales..."
                        echo ""

                        VBoxManage modifyvm "GRFICSv2-pfSense"         --groups "/GRFICSv2" 2> /dev/null
                        VBoxManage modifyvm "GRFICSv2-3DChemicalPlant" --groups "/GRFICSv2" 2> /dev/null
                        VBoxManage modifyvm "GRFICSv2-PLC"             --groups "/GRFICSv2" 2> /dev/null
                        VBoxManage modifyvm "GRFICSv2-WorkStation"     --groups "/GRFICSv2" 2> /dev/null
                        VBoxManage modifyvm "GRFICSv2-HMIScadaBR"      --groups "/GRFICSv2" 2> /dev/null
                        VBoxManage modifyvm "GRFICSv2-Kali"            --groups "/GRFICSv2" 2> /dev/null

                      ;;

                     14)

                        echo ""
                        echo "  Iniciando máquinas virtuales en el orden correcto..."
                        echo ""
                        VBoxManage startvm "GRFICSv2-pfSense"
                        sleep 15
                        VBoxManage startvm "GRFICSv2-3DChemicalPlant"
                        sleep 15
                        VBoxManage startvm "GRFICSv2-PLC"
                        sleep 15
                        VBoxManage startvm "GRFICSv2-WorkStation"
                        sleep 15
                        VBoxManage startvm "GRFICSv2-HMIScadaBR"
                        sleep 15
                        VBoxManage startvm "GRFICSv2-Kali"

                      ;;

                  esac

              done

            ;;

        esac

    done
