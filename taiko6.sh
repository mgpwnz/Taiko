#!/bin/bash
link=http://taiko-a6-prover.zkpool.io:9876
while true
do
# Menu
PS3='Select an action: '
options=("Download the components" "Create the configuration" "Run Taiko" "Update Taiko" "logs"  "Uninstall" "Exit")
select opt in "${options[@]}"
               do
                   case $opt in                          

"Download the components")
# Clone repository
git clone https://github.com/taikoxyz/simple-taiko-node.git
break
;;
"Create the configuration")
cd $HOME/simple-taiko-node/
rm .env 
cp .env.sample .env 
# ADD PRIVATE KEY
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi
if [ ! $MMP ]; then
		read -p "Enter Metamask Private Key : " MMP
		echo 'export MMP='${MMP} >> $HOME/.bash_profile
        fi
 . $HOME/.bash_profile
#PROPOSER CONFIG 
sed -i -e "s%L1_PROPOSER_PRIVATE_KEY=.*%L1_PROPOSER_PRIVATE_KEY=${MMP}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%PROVER_ENDPOINTS=.*%PROVER_ENDPOINTS=$link%g" $HOME/simple-taiko-node/.env
sed -i -e "s%BLOCK_PROPOSAL_FEE=.*%BLOCK_PROPOSAL_FEE=30%g" $HOME/simple-taiko-node/.env
sed -i -e "s%PROVER_ENDPOINTS=.*%PROVER_ENDPOINTS=http://taiko-a6-prover.zkpool.io:9876%g" $HOME/simple-taiko-node/.env
#RPC config
read -r -p "Holesky is local node? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
sed -i -e "s%L1_ENDPOINT_HTTP=.*%L1_ENDPOINT_HTTP=http://127.0.0.1:8545%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L1_ENDPOINT_WS=.*%L1_ENDPOINT_WS=ws://`wget -qO- eth0.me`:8546%g" $HOME/simple-taiko-node/.env
sed -i -e "s%PORT_GRAFANA=3001%PORT_GRAFANA=3002%g" $HOME/simple-taiko-node/.env

            ;;
    *)
        read -p "Enter ip ADDRESS: " HL
        sed -i -e "s%L1_ENDPOINT_HTTP=.*%L1_ENDPOINT_HTTP=http://$HL:8545%g" $HOME/simple-taiko-node/.env
        sed -i -e "s%L1_ENDPOINT_WS=.*%L1_ENDPOINT_WS=ws://$HL:8546%g" $HOME/simple-taiko-node/.env
        sed -i -e "s%PORT_GRAFANA=3001%PORT_GRAFANA=3002%g" $HOME/simple-taiko-node/.env
        break
        ;;
esac

break
;;
"Run Taiko")
read -r -p "Run node? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
cd $HOME/simple-taiko-node/
docker compose up -d 
docker compose logs -f
            ;;
    *)
        cd $HOME/simple-taiko-node/
        docker compose up -d 
        docker compose logs -f
        break
        ;;
esac
break
;;

"Update Taiko")
cd $HOME/simple-taiko-node/
git pull
sleep 2
rm .env 
cp .env.sample .env 
#PROPOSER CONFIG 
sed -i -e "s%L1_PROPOSER_PRIVATE_KEY=.*%L1_PROPOSER_PRIVATE_KEY=${MMP}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%PROVER_ENDPOINTS=.*%PROVER_ENDPOINTS=$link%g" $HOME/simple-taiko-node/.env
sed -i -e "s%BLOCK_PROPOSAL_FEE=.*%BLOCK_PROPOSAL_FEE=30%g" $HOME/simple-taiko-node/.env
sed -i -e "s%PROVER_ENDPOINTS=.*%PROVER_ENDPOINTS=http://taiko-a6-prover.zkpool.io:9876%g" $HOME/simple-taiko-node/.env
read -r -p "Holesky is local node? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
sed -i -e "s%L1_ENDPOINT_HTTP=.*%L1_ENDPOINT_HTTP=http://127.0.0.1:8545%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L1_ENDPOINT_WS=.*%L1_ENDPOINT_WS=ws://`wget -qO- eth0.me`:8546%g" $HOME/simple-taiko-node/.env
sed -i -e "s%PORT_GRAFANA=3001%PORT_GRAFANA=3002%g" $HOME/simple-taiko-node/.env
            ;;
    *)
        read -p "Enter ip ADDRESS: " HL
        sed -i -e "s%L1_ENDPOINT_HTTP=.*%L1_ENDPOINT_HTTP=http://$HL:8545%g" $HOME/simple-taiko-node/.env
        sed -i -e "s%L1_ENDPOINT_WS=.*%L1_ENDPOINT_WS=ws://$HL:8546%g" $HOME/simple-taiko-node/.env
        sed -i -e "s%PORT_GRAFANA=3001%PORT_GRAFANA=3002%g" $HOME/simple-taiko-node/.env
        break
        ;;
esac
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