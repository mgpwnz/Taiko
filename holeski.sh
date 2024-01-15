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
# Перевірити, чи користувач вже існує
if id "holesky" &>/dev/null; then
    echo "Користувач holesky вже існує."
else
    # Створити нового користувача
    sudo adduser --disabled-password --gecos "" holesky
    sudo usermod -aG sudo holesky
fi
# Змінити користувача
su -l holesky -c '

    #docker
    . <(wget -qO- https://raw.githubusercontent.com/mgpwnz/VS/main/docker.sh)
    
    # Переконатися, що Git встановлено
    sudo apt-get install -y git

    # Клонувати репозиторій в директорію користувача
    git clone https://github.com/eth-educators/eth-docker

    # Змінити робочий каталог на eth-docker
    cd $HOME/eth-docker

    # Запустити ./ethd config
    ./ethd config

    # Редагувати конфігураційні файли
    sed -i -e "s%COMPOSE_FILE=lighthouse-cl-only.yml:geth.yml.*%COMPOSE_FILE=lighthouse-cl-only.yml:geth.yml:el-shared.yml%g" $HOME/eth-docker/.env
    sed -i -e "s%ARCHIVE_NODE=.*%ARCHIVE_NODE=true%g" $HOME/eth-docker/.env

    # Запустити ./ethd up
    ./ethd up
    echo exit
    
'
}
uninstall() {
read -r -p "You really want to delete the node? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        sudo -u holesky -H sh -c '
            cd $HOME/eth-docker
            ./ethd terminate
            exit
        '
        sudo rm -rf /home/holesky/
        sudo userdel holesky
        ;;
    *)
        echo "Cancelled"
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