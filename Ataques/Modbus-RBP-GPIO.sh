#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para atacar mediante Modbus el GPIO de la Rasberry Pi desde Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO.sh | bash -s IPDestino
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO.sh | sed 's-sudo--g' | bash -s IPDestino
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO.sh | nano -
# ----------

# Definir fecha de ejecución del script
  cFechaDeEjec=$(date +a%Ym%md%d@%T)

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
  menu=(dialog --checklist "Que entrada quieres mantener encendida?:" 22 96 16)
    opciones=(
      1 "%IX0.0" off
      2 "%IX0.1" off
      3 "%IX0.2" off
      4 "%IX0.3" off
      5 "%IX0.4" off
      6 "%IX0.5" off
      7 "%IX0.6" off
      8 "%IX0.7" off
      9 "%IX1.0" off
     10 "%IX1.1" off
     11 "%IX1.2" off
     12 "%IX1.3" off
     13 "%IX1.4" off
     14 "%IX1.5" off
    )
  choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
  #clear
  for choice in $choices
    do
      case $choice in

        1)

          echo ""
          echo "  Manteniendo encendida la dirección %IX0.0..."
          echo ""

        ;;

        2)

          echo ""
          echo "  Manteniendo encendida la dirección %IX0.1..."
          echo ""

        ;;

        3)

          echo ""
          echo "  Manteniendo encendida la dirección %IX0.2..."
          echo ""

        ;;

        4)

          echo ""
          echo "  Manteniendo encendida la dirección %IX0.3..."
          echo ""

        ;;

        5)

          echo ""
          echo "  Manteniendo encendida la dirección %IX0.4..."
          echo ""

        ;;

        6)

          echo ""
          echo "  Manteniendo encendida la dirección %IX0.5..."
          echo ""

        ;;

        7)

          echo ""
          echo "  Manteniendo encendida la dirección %IX0.6..."
          echo ""

        ;;

        8)

          echo ""
          echo "  Manteniendo encendida la dirección %IX0.7..."
          echo ""

        ;;

        9)

          echo ""
          echo "  Manteniendo encendida la dirección %IX1.0..."
          echo ""

        ;;

       10)

          echo ""
          echo "  Manteniendo encendida la dirección %IX1.1..."
          echo ""

        ;;

       11)

          echo ""
          echo "  Manteniendo encendida la dirección %IX1.2..."
          echo ""

        ;;

       12)

          echo ""
          echo "  Manteniendo encendida la dirección %IX1.3..."
          echo ""

        ;;

       13)

          echo ""
          echo "  Manteniendo encendida la dirección %IX1.4..."
          echo ""

        ;;

       14)

          echo ""
          echo "  Manteniendo encendida la dirección %IX1.5..."
          echo ""

        ;;

    esac

done
