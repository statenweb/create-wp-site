#!/bin/bash

DOT_FILE="$HOME/.wordpress-base"
SITE_REPO="git@github.com:roots/bedrock.git"
TRELLIS_REPO="git@github.com:roots/trellis.git"
MULTISITE_DOCUMENTATION_URL="https://roots.io/trellis/docs/multisite/"
TRELLIS_DOCUMENTATION_URL="https://roots.io/trellis/"
LANDRUSH_ISSUE_URL="https://github.com/mitchellh/vagrant/issues/4918"
R='\e[0;31m'
G='\e[0;32m'
LBBG='\e[104m'
N=$(tput sgr0)

function banner(){

    printf "\n\n"
    printf ${LBBG}
    printf "\n                                                                          "
    printf "\n  WordPress Site Creator Version 0.3                                      "
    printf "\n  ----------------------------------------------------------------------  \n"
    printf "  This script is meant to create a new WordPress project.                 "
    printf "\n  ----------------------------------------------------------------------  \n"
    printf "  Author: Mat Gargano (mat@statenweb.com)                          \n"
    printf "                                                                          \n"
    printf ${N}
}

function create_dot_file() {
    echo -n "Enter the root directory for your projects: ( $HOME/Sites )"
    read SITE_ROOT
    if [ ! $SITE_ROOT ] || [ $SITE_ROOT == "" ]; then
        SITE_ROOT="~/Sites"
    fi
    echo "ROOT_DIR=${SITE_ROOT}" > $DOT_FILE
    printf "${G}Config file created.${N}\n"
}

function check_dot_file() {
    if [ ! -f "$DOT_FILE" ]; then
        printf "${R}Config file not found. We are going to create one.${N}\n"
        create_dot_file
    fi
    source $DOT_FILE
}

function site_root_info(){
    printf "\n\n"
    printf "\n  Notice "
    printf "\n  ----------------------------------------------------------------------  \n"
    printf "  Please ensure that you have the following applications installed:\n"
    printf "    - Ansible (${G}https://ansible.io/${N})\n"
    printf "    - Vagrant (${G}http://vagrantup.com)${N}\n"
    printf "    - Virtualbox (${G}http://virtualbox.org)${N}\n"
    printf "    - Vagrant's BindFS Plugin (${G}vagrant plugin install vagrant plugin install vagrant-bindfs${N})\n"
    printf "    - Vagrant's Hostmanager Plugin (${G}vagrant plugin install vagrant-hostmanager${N})\n"
    printf "    - Vagrant's Landrush Plugin (for multisite) (${G}vagrant plugin install landrush${N})\n"
    printf "          note this plugin may need an older version of Vagrant, see $LANDRUSH_ISSUE_URL for more info ${N})\n"
    printf "\n\n"
    printf "  Site root is $ROOT_DIR, if you want to change this, either\n"
    printf "    - update ${G}$DOT_FILE${N} or \n"
    printf "    - delete ${G}$DOT_FILE${N} break out of this script and run it again to rebuild it.\n"
    printf "\n  ----------------------------------------------------------------------  \n"
    printf "                                                                          \n\n"

}

function site_local_domain(){


    printf "  ----------------------------------------------------------------------  \n"
    printf "  Select a local domain, this should be an entire TLD for example ${G}mysite.tst{N}\n"
    printf "    - If you are setting up a multisite, you are going to have to add this to your hosts file \n"
    printf "        pointing to the IP address you set in the ${G}Vagrantfile${N} \n"
    printf "    - If this is a single site install this will automatically be added to your hosts file\n"
    printf "\n  ----------------------------------------------------------------------  \n"
    printf "                                                                          \n\n"
    printf "Domain name (e.g. example.tst): "
    read DEV_DOMAIN

    if [ ! $SITE_DIRECTORY ] || [ $SITE_DIRECTORY == "" ]; then
        log "\n${R}Invalid domain, make sure to add a TLD${N}"
        site_local_domain
        return
    fi


}

function is_multisite(){
	echo -n "Is this a multisite? [y/n] ( n )"
    read IS_MULTISITE
    if [ ! $IS_MULTISITE ] || [ $IS_MULTISITE == "" ]; then
        IS_MULTISITE="n"
    fi
    if [ $IS_MULTISITE != "Y" ] && [ $IS_MULTISITE != "y" ] && [ $IS_MULTISITE != "N" ] && [ $IS_MULTISITE != "n" ] ; then
        log "Invalid response"
        is_multisite
    fi
    if [ $IS_MULTISITE == "Y" ] || [ $IS_MULTISITE == "y" ] ; then
        printf "\n  Notice "
        printf "\n  ----------------------------------------------------------------------  \n"
        printf "  Multisite requires some manual changes before running vagrant up\n"
        printf "  Please read ${G}$MULTISITE_DOCUMENTATION_URL${N} before continuing \n"
        printf "  Also, you may need to downgrade Vagrant to a version ~1.8.6 which works \n"
        printf "       with the landrush plugin, see $LANDRUSH_ISSUE_URL \n"
        printf "\n  ----------------------------------------------------------------------  \n"
        read -p "Press any key to confirm you read this message"
    fi
}

function get_and_create_site_directory() {
    echo -n "Enter the directory to store the new site (this will be created within $ROOT_DIR):"
    read SITE_DIRECTORY

    if [ ! $SITE_DIRECTORY ] || [ $SITE_DIRECTORY == "" ]; then
        log "\n${R}Invalid directory name${N}"
        get_and_create_site_directory
        return
    fi

    SITE_DIRECTORY=$ROOT_DIR/$SITE_DIRECTORY


    if [ -d "$SITE_DIRECTORY" ]; then
        log "\n${R}$SITE_DIRECTORY directory already exists, mumble mumble${N}"
        get_and_create_site_directory
        return
    fi
    log "creating $SITE_DIRECTORY"
    mkdir $SITE_DIRECTORY
}



function clone_trellis(){
	log "Cloning trellis in $SITE_DIRECTORY ..."
	cd $SITE_DIRECTORY
	git clone $TRELLIS_REPO trellis --depth=1
	rm -rf trellis/.git
}

function ansible_galaxy(){
    log "Ansible Galaxy installation"
    cd $SITE_DIRECTORY/trellis
    ansible-galaxy install -r requirements.yml
}

function clone_site(){
	log "Cloning bare site in $SITE_DIRECTORY ..."
	cd $SITE_DIRECTORY
	git clone $SITE_REPO site --depth=1
	rm -rf site/.git
}

function cd_site_dir(){
	cd $SITE_DIRECTORY
}

function log(){
	printf "$1\n\n"
}

function find_replace(){
    log "Finding and replacing ${G}example.tst${N} and ${G}example.com${N} with $DEV_DOMAIN"
    find $SITE_DIRECTORY/trellis/group_vars/development -type f | xargs sed -i '' "s/example.tst/$DEV_DOMAIN/g"
    find $SITE_DIRECTORY/trellis/group_vars/development -type f | xargs sed -i '' "s/example.com/$DEV_DOMAIN/g"
}

function completed_notice(){
    printf "\n\n"
    printf "\n  Complete! "
    printf "\n  ----------------------------------------------------------------------  \n"
    printf "  Next steps:\n"
    printf "    - change directory to ${G}$SITE_DIRECTORY/trellis${N}\n"
    printf "    - make any variable changes needed, especially the IP address in the generated Vagrantfile \n"
    printf "        be sure to also see Trellis documentation for more info at \n"
    printf "        ${G}$TRELLIS_DOCUMENTATION_URL${N} \n"
    printf "    - If this is a multisite install make the changes prescribed in ${G}$MULTISITE_DOCUMENTATION_URL${N}\n"
    printf "    - run ${G}vagrant up${N} from within ${G}$SITE_DIRECTORY/trellis${N} \n"
    printf "    - you may need to install additional software/plugins before the process can fully complete \n"
    printf "    - have fun! \n"
    printf "\n  ----------------------------------------------------------------------  \n"
    printf "                                                                          \n\n"
}


banner
check_dot_file
site_root_info
get_and_create_site_directory
site_local_domain
is_multisite
clone_trellis
clone_site
ansible_galaxy
find_replace
completed_notice
