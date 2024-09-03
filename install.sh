#!/bin/bash
set -o errexit -o nounset

echo ""
echo "Welcome to Nano-HackHat-OLED Installer made by Karm78"
echo ""
sleep 1
echo "This is a fork for minihacking tools from the original NanoHatOLED Installer made by friendlyarm "
echo ""
sleep1
echo "This script is for educational purposes only. I'm not responsible for what you do with it, so be careful when using it."
echo ""
sleep1
# Checking Linux distribution
echo "Before start ,i strongly recommend you to use Debian to increase compatibility."
echo ""
distribution=$(lsb_release -is)
version=$(lsb_release -rs)

if [ "$distribution" == "Debian" ]; then
    echo "You are using Debian, version $version. That's good."
    echo ""
else
    echo "Your system is not Debian. Distribution detected: $distribution, version $version."
    echo "You can freely download the correct version of Debian (Minimal/IOT) at: https://www.armbian.com/nanopi-neo/"
    echo ""

    while true; do
        read -p "Do you want to continue anyway? [y/n] " response

        if [ "$response" = "n" ]; then
            echo "Please restart the script on Debian."
            exit 0
        elif [ "$response" = "y" ]; then
            echo "Continuing..."
            break
        else
            echo "Invalid answer. Please enter 'y' or 'n'."
        fi
    done
fi
echo "If you need to abort the installation, press Ctrl+C. Else let's go in 15 sec!"
echo ""
time=0
echo -n "---"

while [ $time -lt 15 ]; do
    echo -ne "---"
    time=$((time + 1))
    sleep 1
done
echo "Requirements:"
echo "1) Must be connected to the internet"
echo "2) This script must be run as root user"
echo ""
echo "Steps:"
echo "Installs package dependencies:"
echo "  - python3       interactive high-level object-oriented language, python3 version"
#echo "  - python3-dev   header files and a static library for Python3"
echo "  - BakeBit       an open source platform for connecting BakeBit Sensors to the Pi"
echo ""
sleep 3

echo ""
echo "Checking Internet Connectivity..."
echo "================================="
wget -q --tries=2 --timeout=100 http://www.google.com -O /dev/null
if [ $? -eq 0 ];then
    echo "Connected"
else
    echo "Unable to Connect, try again !!!"
    exit 0
fi

echo ""
echo "Checking User ID..."
echo "==================="
if [ $(id -u) -eq 0 ]; then
    echo "$(whoami)"
else
    echo "Please run this script as root, try 'sudo bash install.sh' or ."
    exit 1
fi

echo ""
echo "Checking for Updates..."
echo "======================="
sudo apt-get update --yes

echo ""
echo "Installing Dependencies"
echo "======================="
#sudo apt-get install gcc python3 python3-dev -y
sudo apt-get install gcc python3 -y
echo "Dependencies installed"

if [ ! -f /usr/bin/python3 ]; then
    echo "/usr/bin/python3 not found, exiting."
    exit 1
fi

PY3_INTERP=`readlink /usr/bin/python3`
RET=$?
if [ $? -ne 0 ]; then
    echo "No executable python3, exiting."
    exit 1
fi
REAL_PATH=$(realpath $(dirname $0))
#sed -i '/^#define.*DEBUG.*$/s/1/0/' "${REAL_PATH}/Source/daemonize.h"
sed -i "/^#define.*PYTHON3_INTERP.*$/s/\".*\"/\"${PY3_INTERP}\"/" "${REAL_PATH}/Source/daemonize.h"

echo ""
echo "Compiling with GCC ..."
echo "======================="
gcc Source/daemonize.c Source/main.c -lrt -lpthread -o NanoHatOLED
echo "Compiled NanoHatOLED"

if [ ! -f /usr/local/bin/oled-start ]; then
    cat >/usr/local/bin/oled-start <<EOL
#!/bin/sh
EOL
    echo "cd $PWD" >> /usr/local/bin/oled-start
    echo "./NanoHatOLED" >> /usr/local/bin/oled-start
    sed -i -e '$i \/usr/local/bin/oled-start\n' /etc/rc.local
    chmod 755 /usr/local/bin/oled-start
fi
echo "Make NanoHatOLED autostart."

if [ ! -f BakeBit/install.sh ]; then
    git submodule init
    git submodule update --remote
fi

cd BakeBit/

# Add a prompt for the user to choose between install.sh and install-compact.sh based on the system version

echo "Please choose an option corresponding to your system version from the information below:"
echo ""
lsb_release -a
echo ""
echo "for reminder : 
Armbian Stretch based on Debian 9 
Armbian Buster based on Debian 10.
Armbian Bullseye based on Debian 11
Armbian Jammy Jellyfish base on Ubuntu 22.04 
Debian 12 is Bookworm
echo ""
echo "I strongly recommend using Debian 12 to increase compatibility."
echo ""
read -p "Enter your choice (1 or 2): " choice
echo ""

case $choice in
    1)
        echo "Your system is version 9."
        sudo bash install.sh
        ;;
    2)
        echo "Your system is version 10 or higher."
        sudo bash install-compact.sh
        ;;
    *)
        echo "Invalid choice."
        ;;
esac



