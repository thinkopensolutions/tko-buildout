#!/bin/bash

###############################################################################
#
# Copyright (C) 2012 Thinkopen Solutions, Lda. All Rights Reserved
# http://www.tkobr.com
# carlos.almeida@tkobr.com
#
# This script installs base modules, and performs the bootstrap plus buildout
#
###############################################################################

REP_DIR="tkobr-buildout"
BUILDOUT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILDOUT_FILE="buildout.cfg"
LOCK_FILE=${BUILDOUT_DIR%/*}/.tkobr_setup_lock

if [ $PWD == $BUILDOUT_DIR ]; then
    echo "ATTENTION: This script should be executed outside the buildout repository directory."
    echo "           You must move one directory up and run ./buildout/setup.py"
    exit
fi

if [ ! -e $LOCK_FILE ]; then
    echo "###############################################################################"
    echo "This script will do:"
    echo " 1- Install system wide development libraries;"
    echo " 2- Create symbolic links to buildout recipes *.cfg inside $REP_DIR;"
    echo "    For future recipes in buildout diretory you must create those symlinks"
    echo "    your self by doing: $> ln -s $REP_DIR/recipe.cfg"
    echo " 3- Bootstrap the buildout with: python bootstrap.py"
    echo " 4- Run the buildout with: bin/buildout"
    echo " 5- Start odoo..."
    echo
    echo "On a day-by-day basis you change the recipe and buildout, with:"
    echo " - $> bin/buildout"
    echo " - $> bin/start_odoo80"
    echo
    echo "ATTENTION: Make sure you have permissions to clone the repositories"
    echo "           the buildout will fail later on trying to clone them!!"
    echo -n "CTRL+C to cancel..."
    read
fi
touch $LOCK_FILE

# Ask user for the data into $BUILDOUT_FILE file
if [ ! -e $BUILDOUT_FILE ]; then
    buildout_file="$(cd $REP_DIR; ls -1d *.cfg | tr '\n' ' ')"
    echo -n "Select base buildout file to extend from list [${buildout_file::-1}]: "
    read answer
    if [[ ! "$answer" == "" ]]; then
        buildout_file=$answer
    fi
    
    buildout_part=$(cat $REP_DIR/$buildout_file | grep parts | cut -d ' ' -f 3)
    echo -n "Select a part to extend [$buildout_part]: "
    read answer
    if [[ ! "$answer" == "" ]]; then
        buildout_part=$answer
    fi
    
    buildout_db_host="localhost"
    echo -n "Insert database host [$buildout_db_host]: "
    read answer
    if [[ ! "$answer" == "" ]]; then
        buildout_db_host=$answer
    fi
    
    buildout_db_port="5432"
    echo -n "Insert database port [$buildout_db_port]: "
    read answer
    if [[ ! "$answer" == "" ]]; then
        buildout_db_port=$answer
    fi
    
    echo -n "Insert database user [$buildout_part]: "
    read buildout_db_user
    if [[ "$buildout_db_user" == "" ]]; then
        buildout_db_user="$buildout_part"
    fi
    
    echo -n "Insert database password [$buildout_part]: "
    read buildout_db_password
    if [[ "$buildout_db_password" == "" ]]; then
        buildout_db_password="$buildout_part"
    fi
    
    echo -n "Insert Odoo admin password [admin]: "
    read buildout_admin_passwd
    if [[ "$buildout_admin_passwd" == "" ]]; then
        buildout_admin_passwd="admin"
    fi
    
    echo "[buildout]
extends = $buildout_file

[$buildout_part]
;############################################################################
; Security-related options
; disable the ability to return the list of databases
options.list_db = True
options.dbfilter = ^%d$
;############################################################################
; Multiprocessing options
; Specify the number of workers, 0 disable prefork mode.
options.workers = 2
;############################################################################
; Advanced options – Advanced options
; Maximum number of threads processing concurrently cron jobs (default 2)
options.max_cron_threads = 1
;############################################################################
; Database related options
; specify the database user name
options.db_user = $buildout_db_user
; specify the database password
options.db_password = $buildout_db_password
; specify the database host
options.db_host = $buildout_db_host
; specify the database port
options.db_port = $buildout_db_port
;############################################################################
; Server startup config - Common options
; Admin password for creating, restoring and backing up databases
options.admin_passwd = $buildout_admin_passwd" > $BUILDOUT_FILE
fi

#echo "###############################################################################"
#echo "## START BUILDING..."
#echo "###############################################################################"
# Keep this in setup for future reference
# Don't run anymore so user can decide default language    
#echo
# Setting locale
#sudo locale-gen pt_BR.UTF-8
#sudo dpkg-reconfigure locales
#sudo update-locale LANG=pt_BR.UTF-8 LANGUAGE
#echo

# Install Linux base packages
if [[ -e $BUILDOUT_DIR/requirements.txt ]]; then
    requirements=$(cat $BUILDOUT_DIR/requirements.txt | grep -v "#")
    to_install=""
    for pkg in $requirements; do
        if [[ $(dpkg -s $pkg | grep "Status: install ok installed" | wc -l) -lt 1 ]]; then
            to_install="$to_install $pkg"
        fi
    done
    if [[ $to_install != "" ]]; then
        echo
        echo "###############################################################################"
        echo "# Installing system dev libraries..."
        echo "###############################################################################"
        echo "# Updating..."
        sudo apt-get update
        echo "# Installing $to_install packages..."
        sudo apt-get install $to_install
    else
        echo
        echo "###############################################################################"
        echo "# All requirements already installed..."
        echo "###############################################################################"
    fi
fi

if [ ! -e /usr/bin/node ]; then
    echo
    echo "###############################################################################"
    echo "# Installing Node.js..."
    echo "###############################################################################"
    curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
    sudo apt-get -y install nodejs
    sudo ln -sf /usr/bin/nodejs /usr/bin/node
    sudo npm install -f -g less less-plugin-clean-css
else
    echo
    echo "###############################################################################"
    echo "# Node.js installed..."
    echo "###############################################################################"
fi

if [ ! -e /usr/bin/wkhtmltopdf.sh ]; then
    echo
    echo "###############################################################################"
    echo "# Installing Wkhtmltopdf..."
    echo "###############################################################################"
    . /etc/lsb-release
    if [ $(uname -i) == "x86_64" ]; then
        wget http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-$DISTRIB_CODENAME-amd64.deb -O /tmp/wkhtmltox-0.12.1_linux-$DISTRIB_CODENAME-amd64.deb
        sudo dpkg -i /tmp/wkhtmltox-0.12.1_linux-$DISTRIB_CODENAME-amd64.deb
    else
            wget http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-$DISTRIB_CODENAME-i386.deb -O /tmp/wkhtmltox-0.12.1_linux-$DISTRIB_CODENAME-i386.deb
            sudo dpkg -i /tmp/wkhtmltox-0.12.1_linux-$DISTRIB_CODENAME-i386.deb
    fi
    echo 'xvfb-run --server-args="-screen 0, 1024x768x24" /usr/bin/wkhtmltopdf $*' > wkhtmltopdf.sh
    chmod 755 wkhtmltopdf.sh
    sudo mv wkhtmltopdf.sh /usr/bin/wkhtmltopdf.sh
else
    echo
    echo "###############################################################################"
    echo "# Wkhtmltopdf already installed..."
    echo "###############################################################################"
fi

if [[ ! -e /usr/share/GeoIP/GeoLiteCity.dat ]]; then
    echo
    echo "###############################################################################"
    echo "# Installing GeoIP..."
    echo "###############################################################################"
    old_pwd=$PWD
    sudo mkdir -p /usr/share/GeoIP
    cd /usr/share/GeoIP
    sudo wget -N http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
    sudo gunzip GeoLiteCity.dat.gz
    cd $old_pwd
else
    echo
    echo "###############################################################################"
    echo "# GeoIP already installed..."
    echo "###############################################################################"
fi

echo
echo "###############################################################################"
echo "# Installing/Reinstalling bootstrap.py..."
echo "###############################################################################"
echo
#url=http://downloads.buildout.org/1/bootstrap.py
#url=https://raw.github.com/buildout/buildout/master/bootstrap/bootstrap.py
url=http://downloads.buildout.org/2/bootstrap.py
#url=https://bootstrap.pypa.io/bootstrap-buildout.py
wget $url -O bootstrap.py
for f in $(ls ./$REP_DIR/*.cfg); do
    ln -sf $f
done

# Buildout and run
python bootstrap.py --buildout-version 2.5.2 --setuptools-version 27.3.0 -c $BUILDOUT_FILE || exit
#python bootstrap.py -c $BUILDOUT_FILE || exit

echo "###############################################################################"
echo "ATTENTION: On a day-by-day base you just run the bin/buildout script."
echo "bin/buildout"

bin/buildout -c $BUILDOUT_FILE
