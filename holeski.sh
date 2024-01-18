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
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/VS/main/docker.sh)
# Перевірити, чи користувач вже існує
if id "holesky" &>/dev/null; then
    echo "Користувач holesky вже існує."
else
    # Створити нового користувача
    sudo adduser --gecos "" holesky
    sudo usermod -aG sudo holesky
fi
# Змінити користувача та виконати команди під новим користувачем
sudo -u holesky -H bash <<'EOF'
    
    # Клонувати репозиторій в директорію користувача
    sudo git clone https://github.com/eth-educators/eth-docker

    # Змінити робочий каталог на eth-docker
    cd $HOME/eth-docker
    
    #Докер
    ./ethd install
    
    # Шлях до .env файлу
    env_file="$HOME/eth-docker/.env"
    
    # Викликаємо ./ethd config для створення .env
        ./ethd config
        
        # Редагуємо .env файл
        sed -i -e "s%COMPOSE_FILE=.*%COMPOSE_FILE=lighthouse-cl-only.yml:geth.yml:grafana.yml:grafana-shared.yml:mev-boost.yml:el-shared.yml%g" "$env_file"
        sed -i -e "s%ARCHIVE_NODE=.*%ARCHIVE_NODE=true%g" "$env_file"

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
sudo -u holesky -H bash <<'EOF'
# Змінити робочий каталог на eth-docker
    cd $HOME/eth-docker

EOF
}
# Actions
sudo apt install wget -y &>/dev/null
cd
$function