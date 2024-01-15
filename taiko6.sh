#!/bin/bash
while true
do

# Menu

PS3='Select an action: '
options=("Holesky" "Download the components" "Create the configuration" "Update Taiko" "logs"  "Uninstall" "Exit")
select opt in "${options[@]}"
               do
                   case $opt in                          

"Holesky")
#Holesky
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/Taiko/main/holeski.sh)
echo Перевір чи синхронізувалася твоя нода http://`wget -qO- eth0.me`:3000/d/Dashboard/home-staking-dashboard?orgId=1&refresh=10s
break
;;

"Download the components")
# Clone repository
git clone https://github.com/taikoxyz/simple-taiko-node.git
cd simple-taiko-node
cp .env.sample .env 
break
;;
"Create the configuration")
sed -i -e "s%L1_ENDPOINT_HTTP=.*%L1_ENDPOINT_HTTP=http://127.0.0.1:8545%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L1_ENDPOINT_WS=.*%L1_ENDPOINT_WS=ws://127.0.0.1:8546%g" $HOME/simple-taiko-node/.env
sed -i -e "s%PORT_GRAFANA=3001%PORT_GRAFANA=3002%g" $HOME/simple-taiko-node/.env
break
;;
"Run Taiko")
cd $HOME/simple-taiko-node/
docker compose up -d 
docker compose logs -f
break
;;

"Update Taiko")
cd $HOME/simple-taiko-node/
git pull
sleep 2
rm .env 
cp .env.sample .env 
sed -i -e "s%L1_ENDPOINT_HTTP=.*%L1_ENDPOINT_HTTP=http://127.0.0.1:8545%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L1_ENDPOINT_WS=.*%L1_ENDPOINT_WS=ws://127.0.0.1:8546%g" $HOME/simple-taiko-node/.env
sed -i -e "s%PORT_GRAFANA=3001%PORT_GRAFANA=3002%g" $HOME/simple-taiko-node/.envv
sleep 2
#proposer 
read -r -p "Run proposer? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
    sed -i -e "s%ENABLE_PROPOSER=false%ENABLE_PROPOSER=true%g" $HOME/simple-taiko-node/.env
    sed -i -e "s%PROVER_ENDPOINTS=.*%PROVER_ENDPOINTS=$link%g" $HOME/simple-taiko-node/.env
    sed -i -e "s%BLOCK_PROPOSAL_FEE=.*%BLOCK_PROPOSAL_FEE=100%g" $HOME/simple-taiko-node/.env
    sed -i -e "s%PROVE_UNASSIGNED_BLOCKS=false%PROVE_UNASSIGNED_BLOCKS=true%g" $HOME/simple-taiko-node/.env
            ;;
    *)
        echo Running
        break
        ;;
esac
#docker stop
cd $HOME/simple-taiko-node && docker compose down
#docker start
docker compose up -d
docker compose logs -f
break
;;

"logs")
docker compose -f $HOME/simple-taiko-node/docker-compose.yml logs -f --tail 250
break
;;

"Uninstall")
if [ ! -d "$HOME/simple-taiko-node" ]; then
    break
fi
read -r -p "Wipe all DATA? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
cd $HOME/simple-taiko-node && docker compose down -v
rm  .env
cd
rm -rf simple-taiko-node
        ;;
    *)
    cd $HOME/simple-taiko-node && docker compose down 
    echo Taiko containers remove!
        break
        ;;
esac
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done