#!/bin/bash
# Default variables
function="install"
# Options
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
        case "$1" in
        -in|--install)
            function="install"
            shift
            ;;
        -un|--uninstall)
            function="uninstall"
            shift
            ;;
	    -up|--update)
            function="update"
            shift
            ;;
        *|--)
		break
		;;
	esac
done
install() {
#create user

#docker
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/VS/main/docker.sh)
sudo adduser holesky -p $Pass -G sudo
su - holesky
#clone repo
git clone https://github.com/eth-educators/eth-docker
cd $HOME/eth-docker
./ethd config
#edit config
sed -i -e "s%COMPOSE_FILE=lighthouse-cl-only.yml:geth.yml.*%COMPOSE_FILE=lighthouse-cl-only.yml:geth.yml:el-shared.yml%g" $HOME/eth-docker/.env
sed -i -e "s%ARCHIVE_NODE=.*%ARCHIVE_NODE=true%g" $HOME/eth-docker/.env
#run
./ethd up
#exit
exit
}
uninstall() {
read -r -p "You really want to delete the node? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
    su - holesky
    cd $HOME/eth-docker
    ./ethd terminate
    exit
    sudo rm -rf /home/holesky/
    sudo userdel holesky
    ;;
    *)
        echo Сanceled
        return 0
        ;;
esac
}
update() {
echo Under development
}
# Actions
sudo apt install wget -y &>/dev/null
cd
$function