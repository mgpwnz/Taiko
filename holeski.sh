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

# Змінити користувача і виконати команди під новим користувачем
sudo -u holesky -H bash <<'EOF'
    # Встановити Docker
    touch $HOME/.bash_profile
	cd $HOME
	if ! docker --version; then
		sudo apt update
		sudo apt upgrade -y
		sudo apt install curl apt-transport-https ca-certificates gnupg lsb-release -y
		. /etc/*-release
		wget -qO- "https://download.docker.com/linux/${DISTRIB_ID,,}/gpg" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
		echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
		sudo apt update
		sudo apt install docker-ce docker-ce-cli containerd.io -y
		docker_version=`apt-cache madison docker-ce | grep -oPm1 "(?<=docker-ce \| )([^_]+)(?= \| https)"`
		sudo apt install docker-ce="$docker_version" docker-ce-cli="$docker_version" containerd.io -y
	fi
	if ! docker compose version; then
		sudo apt update
		sudo apt upgrade -y
		sudo apt install wget jq -y
		local docker_compose_version=`wget -qO- https://api.github.com/repos/docker/compose/releases/latest | jq -r ".tag_name"`
		sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-`uname -s`-`uname -m`"
		sudo chmod +x /usr/bin/docker-compose
		. $HOME/.bash_profile
	fi

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
EOF
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