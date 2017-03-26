#! /bin/bash

# variables
files="./.files/"
dir_tmp="/tmp/install"
login=$1

## fake install ?
fake=0

## colors
ESC="\033["
C_RED=$ESC"0;31m"
C_YELLOW=$ESC"0;33m"
C_BWHITE=$ESC"1;37m"
C_RST=$ESC"0m"


function usage
{
    echo
    echo "Usage: $0 <prénom.nom@epitech.eu>"
    echo
}

function line
{
    cols=$(tput cols)
    char=$1
    color=$2

    if [ test "$color" != "" ]; then
	echo -ne $color
    fi

    for i in $(eval echo "{1..$cols}"); do
	echo -n $char
    done
    echo

    if [ test "$color" != "" ]; then
	echo -ne $C_RST
    fi
}

function script_header
{

    color=$2
    if test "$color" = ""; then
	color=$C_RED
    fi

    echo -ne $color
    line "-"
    echo "##> "$1
    line "-"
    echo -ne $C_RST
}

function handle_error
{
    result=$1
    if [ test $result -eq 0 ]; then
	return
    else
	line "#" $C_RED
	line "#" $C_YELLOW
	echo -en $C_RED"[Erreur]"$C_RST" lors de l'installation, voulez-vous arrêter le script ? [O/n]"
	read stop_script
	case $stop_script in
	    [nN])
		return
		;;
	    *)
		exit 1
		;;
	esac
    fi
}

function get_os_type
{
    which pacman &> /dev/null && os="archlinux"
    which apt-get &> /dev/null && os="debian"
    which dnf &> /dev/null && os="fedora"
    which yum &> /dev/null && os="old_fedora"
    which emerge &> /dev/null && os="gentoo"
    which zypper &> /dev/null && os="opensuse"
    which eopkg &> /dev/null && os="solus"
}

function script_init
{
    os="void"
    get_os_type
    
    if [ test "$os" = "void" ]; then
	line "#" $C_YELLOW
	script_header "VOTRE DISTRIBUTION N'EST PAS SUPPORTÉE."
	line "#" $C_YELLOW
	exit 42
    fi
    rm -rf $dir_tmp
    mkdir $dir_tmp
}

function sys_upgrade
{
    if [ test $fake -eq 1 ]; then
	echo "Upgrade system"
	return
    fi
    case "$os" in
	archlinux)
	    sudo pacman -Syu
	    ;;
	debian)
	    sudo apt-get update; sudo apt-get upgrade
	    ;;
	fedora)
	    sudo dnf update
	    ;;
	old_fedora)
	    sudo yum update --security
	    ;;
	gentoo)
	    sudo emerge -u world
	    ;;
	opensuse)
	    sudo zypper update
	    ;;
	solus)
	    sudo eopkg upgrade
	    ;;
    esac
    handle_error $?
}

function sys_install
{
    package_name=$1
    function get_cmd_install
    {
	case "$os" in
	    archlinux)
		echo "pacman -S"
		;;
	    debian)
		echo "apt-get install"
		;;
	    fedora)
		echo "dnf install"
		;;
	    old_fedora)
		echo "yum install"
		;;
	    gentoo)
		echo "emerge"
		;;
	    opensuse)
		echo "zypper install"
		;;
	    solus)
		echo "eopkg it"
		;;
	esac
    }
    
    if [ test -z "$cmd_install" ]; then
	cmd_install=$(get_cmd_install)
    fi
    
    if [ test $fake -eq 1 ]; then
	echo "Installing" $package_name "(command:" $cmd_install $package_name ")"
	return
    fi
    sudo $cmd_install $package_name
    handle_error $?
}

function script_install
{
    if [test $fake -eq 1 ]; then
	echo "Installing" $1 "(script_install)"
	return
    fi
    sudo cp $files/$1 /usr/bin/$1
    handle_error $?
    sudo chmod 755 /usr/bin/$1
    handle_error $?
}

function setup_emacs
{
    if [ test $fake -eq 1 ]; then
	echo "Setting up Emacs"
	return
    fi
    emacs_tmp=$dir_tmp/.emacs.d
    
    cp -r $files/.emacs.d $dir_tmp
    
    sed 's/(getenv "USER")/"'$login'"/g' $emacs_tmp/epitech/std_comment.el > $emacs_tmp/epitech/std_comment.el.tmp
    mv $emacs_tmp/epitech/std_comment.el.tmp $emacs_tmp/epitech/std_comment.el
    
    cp $files/.emacs /home/$USER/
    chmod +rw /home/$USER/.emacs
    
    cp -r $emacs_tmp /home/$USER/
    chmod +rw /home/$USER/.emacs.d
    chmod +rw /home/$USER/.emacs.d/*
}

if [ test $UID -eq 0 ]; then
    echo ">> Veuillez ne pas lancer ce script en tant que super utilisateur <<"
    usage
    exit 1
fi
if [ test -z "$login" ]; then
    usage
    exit 1
fi

# INSTALLATION
script_init

script_header "INSTALLATION DE BLIH"
script_install blih

script_header "MISE À JOUR DES PAQUETS"
sys_upgrade

script_header "INSTALLATION DE PYTHON"
sys_install python3

script_header "CHOISISSEZ VOTRE EDITEUR FAVORI PARMI LA SELECTION"
echo "1) EMACS"
echo "2) VIM"
echo
read -p "Veuillez entrer le chiffre correspondant [1/2]" editor
case "$editor" in
    [1]*)
	script_header "INSTALLATION DE EMACS ET DU SYSTÈME DE HEADERS EPITECH"
	sys_install emacs
	setup_emacs
	;;
    [2]*)
	script_header "INSTALLATION DE VIM"
	sys_install vim
	script_header "INSTALLATION DU SYSTÈME DE HEADERS EPITECH"
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	echo "Plug 'LeBarbu/vim-epitech'" >> /home/$USER/.vimrc
	;;
esac

script_header "INSTALLATION DE GCC"
sys_install gcc

script_header "INSTALLATION DE BUILD-ESSENTIAL POUR LA COMPILATION"
if [[ "$os" -eq "solus" ]]; then
    echo "sudo eopkg it -c system.devel"
elif [[ "$os" -ne "solus" ]]; then
    sys_install build-essential
fi

script_header "INSTALLATION DE VALGRIND"
sys_install valgrind

script_header "INSTALLATION DE OCAML"
sys_install ocaml

script_header "INSTALLATION DE LA LIBNCURSES"
if [[ "$os" -eq "solus" ]]; then
    sys_install ncurses-devel
elif [[ "$os" -ne "solus" ]]; then
    sys_install libncurses5
fi

script_header "INSTALLATION DE CURL"
sys_install curl

script_header "INSTALLATION DE GIT, GENERATION DE LA CLE SSH ET UPLOAD SUR LE SERVEUR EPITECH"

script_header "GIT" $C_YELLOW
sys_install git

script_header "CLE SSH, LEAVE EVERYTHING AS DEFAULT" $C_YELLOW
ssh-keygen
handle_error $?

script_header "BLIH SSH UPLOAD" $C_YELLOW
echo "mot de passe UNIX (bocal, pour blih)"
blih -u "$1" sshkey upload /home/$USER/.ssh/id_rsa.pub
handle_error $?


script_header "CHOISISSEZ VOTRE SHELL FAVORI PARMI LA SELECTION"
echo "1 ~> FISH"
echo "2 ~> ZSH"
read -p "Veuillez entrer le chiffre correspondant [1/2]" shell
case "$shell" in
    [1]*)
	script_header "INSTALLATION ET CONFIGURATION DE FISH"
	script_header "FISH" $C_YELLOW
	sys_install fish
	sudo chsh $USER -s /usr/bin/fish
	echo "alias blih='blih -u $1'"
	echo "funcsave blih"
	echo "alias ne='emacs -nw'"
	echo "funcsave ne"
	echo "alias ns_auth='ns_auth -u $1'"
	echo "funcsave ns_auth"
	handle_error $?
	;;
    [2]*)
	script_header "INSTALLATION ET CONFIGURATION DE ZSH ET OH-MY-ZSH"
	script_header "ZSH" $C_YELLOW
	sys_install zsh
	script_header "OH-MY-ZSH" $C_YELLOW
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	if [[ "$os" -ne "solus" ]]; then
	    sudo chsh $USER -s /usr/bin/zsh
	elif [[ "$os" -eq "solus" ]]; then
	    sudo chsh $USER -s /bin/zsh
	fi
	handle_error $?
	echo "alias blih='blih -u $1'" >> /home/$USER/.zshrc
	echo "alias ne='emacs -nw'" >> /home/$USER/.zshrc
	echo "alias ns_auth='ns_auth -u $1'" >> /home/$USER/.zshrc
	;;
esac


script_header "INSTALLATION DU MAN DE GOOGLE"
sudo cp $files/google.1 /usr/share/man/man1/google.1
handle_error $?

script_header "VEUILLEZ CHOISIR VOTRE TERMINAL FAVORI"
echo "1 ~> TERMINATOR"
echo "2 ~> RXVT-UNICODE"
read -p "Veuillez entrer le chiffre correspondant [1/2]" term
case "$term" in
    [1]*)
	script_header "INSTALLATION DE TERMINATOR" $C_YELLOW
	sys_install terminator
	handle_error $?
	;;
    [2]*)
	script_header "INSTALLATION D'URXVT" $C_YELLOW
	sys_install rxvt-unicode
	handle_error $?
	;;
esac

script_header "INSTALLATION DES OUTILS COMPLEMENTAIRES"
sys_install tree
sys_install filezilla

script_header "CHANGEMENT DES DROITS (-) SUR POWEROFF ET REBOOT"
sudo chmod +s /sbin/poweroff
handle_error $?
sudo chmod +s /sbin/reboot
handle_error $?

script_header "DESIREZ-VOUS INSTALLER MAKEFILE-GEN ?"
read -p "Installer un générateur de Makefile ? [O/n]" yn
case $yn in
    [nN]*)
	echo "FINALISATION DE L'INSTALLATION"
	;;
    [yYoO]*)
	sys_install ruby; git clone https://github.com/kayofeld/makefile-gen.git; cd makefile-gen; sudo ./install.sh; cd ../
	;;
esac


script_header "SUPPRESSION DES FICHIERS D'INSTALLATION"
rm -rvf ../installation

script_header "VOTRE OS EST PRÊT. ENJOY LES -42 <3" $C_BWHITE

sudo -k
