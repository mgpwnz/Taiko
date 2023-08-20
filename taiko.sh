#!/bin/bash
while true
do

# Menu

PS3='Select an action: '
options=("Docker" "Download the components" "Create the configuration manually" "Sepolia RPC" "Run Taiko 2" "Run Taiko 3" "Update Taiko 2 Sepolia" "Update Taiko 3 Sepolia" "Uninstall" "Exit")
select opt in "${options[@]}"
               do
                   case $opt in                          

"Docker")
#docker
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/VS/main/docker.sh)

break
;;

"Download the components")
# Clone repository
git clone https://github.com/taikoxyz/simple-taiko-node.git
cd simple-taiko-node
cp .env.sample .env && cp .env.sample.l3 .env.l3
sed -i -e "s%PORT_GRAFANA=3001%PORT_GRAFANA=3003%g" $HOME/simple-taiko-node/.env
break
;;
"Sepolia RPC")
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi
if [ ! $HTTPS ]; then
		read -p "Enter HTTPS for example 10.1.1.1:8545 : " HTTPS
		echo 'export HTTPS='${HTTPS} >> $HOME/.bash_profile
	fi
if [ ! $WS ]; then
		read -p "Enter WS for example 10.1.1.1:8546 : " WS
		echo 'export WS='${WS} >> $HOME/.bash_profile
	fi
sed -i -e "s%L1_ENDPOINT_HTTP=.*%L1_ENDPOINT_HTTP=${HTTPS}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L1_ENDPOINT_WS=.*%L1_ENDPOINT_WS=ws://${WS}%g" $HOME/simple-taiko-node/.env

read -r -p "Run proposer? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        if [ ! $MMA ]; then
		read -p "Enter Metamask address : " MMA
		echo 'export MMA='${MMA} >> $HOME/.bash_profile
        fi
if [ ! $MMP ]; then
		read -p "Enter Metamask Private Key : " MMP
		echo 'export MMP='${MMP} >> $HOME/.bash_profile
        fi
 . $HOME/.bash_profile
sleep 1
sed -i -e "s%ENABLE_PROPOSER=false%ENABLE_PROPOSER=true%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L1_PROPOSER_PRIVATE_KEY=.*%L1_PROPOSER_PRIVATE_KEY=${MMP}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L2_SUGGESTED_FEE_RECIPIENT=.*%L2_SUGGESTED_FEE_RECIPIENT=${MMA}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L2_ENDPOINT_HTTP=.*%L2_ENDPOINT_HTTP=http://127.0.0.1:8547%g" $HOME/simple-taiko-node/.env.l3
sed -i -e "s%L2_ENDPOINT_WS=.*%L2_ENDPOINT_WS=ws://`wget -qO- eth0.me`:8548%g" $HOME/simple-taiko-node/.env.l3
sed -i -e "s%ENABLE_PROPOSER=false%ENABLE_PROPOSER=true%g" $HOME/simple-taiko-node/.env.l3
sed -i -e "s%L2_PROPOSER_PRIVATE_KEY=.*%L2_PROPOSER_PRIVATE_KEY=${MMP}%g" $HOME/simple-taiko-node/.env.l3
sed -i -e "s%L3_SUGGESTED_FEE_RECIPIENT=.*%L3_SUGGESTED_FEE_RECIPIENT=${MMA}%g" $HOME/simple-taiko-node/.env.l3
        ;;
    *)
        echo "Config created"
        break
        ;;
esac

break
;;
"Create the configuration manually")
echo "TAIKO 2"
sleep 3
nano $HOME/simple-taiko-node/.env
echo "TAIKO 3"
sleep 3
nano $HOME/simple-taiko-node/.env.l3
break
;;
"Run Taiko 2")
cd $HOME/simple-taiko-node/
docker compose up -d 
docker compose logs -f

break
;;

"Run Taiko 3")
cd $HOME/simple-taiko-node/
docker compose -f ./docker-compose.l3.yml --env-file .env.l3 up -d 
docker compose -f ./docker-compose.l3.yml --env-file .env.l3 logs -f

break
;;

"Update Taiko 2 Sepolia")
cd $HOME/simple-taiko-node/
git pull
sleep 5
rm .env 
cp .env.sample .env && cp .env.sample.l3 .env.l3
sed -i -e "s%L1_ENDPOINT_HTTP=.*%L1_ENDPOINT_HTTP=http://${HTTPS}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L1_ENDPOINT_WS=.*%L1_ENDPOINT_WS=ws://${WS}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%PORT_GRAFANA=3001%PORT_GRAFANA=3003%g" $HOME/simple-taiko-node/.env

read -r -p "Run proposer? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
sed -i -e "s%ENABLE_PROPOSER=true%ENABLE_PROPOSER=true%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L1_PROPOSER_PRIVATE_KEY=.*%L1_PROPOSER_PRIVATE_KEY=${MMP}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L2_SUGGESTED_FEE_RECIPIENT=.*%L2_SUGGESTED_FEE_RECIPIENT=${MMA}%g" $HOME/simple-taiko-node/.env
        ;;
    *)
        echo Running
        break
        ;;
esac
sleep 2
#docker stop
cd $HOME/simple-taiko-node && docker compose down
#docker start
docker compose up -d
docker compose logs -f

break
;;
"Update Taiko 3 Sepolia")
cd $HOME/simple-taiko-node/
git pull
sleep 5
rm  .env.l3
cp .env.sample.l3 .env.l3
sed -i -e "s%L1_ENDPOINT_HTTP=.*%L1_ENDPOINT_HTTP=http://127.0.0.1:8547%g" $HOME/simple-taiko-node/.env.l3
sed -i -e "s%L1_ENDPOINT_WS=.*%L1_ENDPOINT_WS=ws://`wget -qO- eth0.me`:8548%g" $HOME/simple-taiko-node/.env.l3
read -r -p "Run proposer? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
sed -i -e "s%ENABLE_PROPOSER=true%ENABLE_PROPOSER=true%g" $HOME/simple-taiko-node/.env.l3
sed -i -e "s%L2_PROPOSER_PRIVATE_KEY=.*%L2_PROPOSER_PRIVATE_KEY=${MMP}%g" $HOME/simple-taiko-node/.env.l3
sed -i -e "s%L3_SUGGESTED_FEE_RECIPIENT=.*%L3_SUGGESTED_FEE_RECIPIENT=${MMA}%g" $HOME/simple-taiko-node/.env.l3
        ;;
    *)
    echo Running
        break
        ;;
esac
sleep 2
#docker stop
cd $HOME/simple-taiko-node && docker compose -f ./docker-compose.l3.yml --env-file .env.l3 down
#docker start
docker compose -f ./docker-compose.l3.yml --env-file .env.l3 up -d
docker compose -f ./docker-compose.l3.yml --env-file .env.l3 logs -f

break
;;

"Uninstall")
cd $HOME/simple-taiko-node && docker compose -f ./docker-compose.l3.yml --env-file .env.l3 down -v
rm  .env.l3
sleep 2
cd $HOME/simple-taiko-node && docker compose down -v
rm  .env
cd
rm -rf simple-taiko-node

break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
