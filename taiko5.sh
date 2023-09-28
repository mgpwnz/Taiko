#!/bin/bash
link=https://taiko-a5-prover.zkpool.io,http://taiko-a5-prover-simple.zkpool.io
while true
do

# Menu

PS3='Select an action: '
options=("Docker" "Download the components" "Create the configuration" "Run Taiko" "Update Taiko" "logs" "Enable proposer" "Uninstall" "Exit")
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
cp .env.sample .env 
break
;;
"Create the configuration")
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi
if [ ! $AHTTPS ]; then
		read -p "Enter ALCHEMY(Infura) HTTPS : " AHTTPS
		echo 'export AHTTPS='${AHTTPS} >> $HOME/.bash_profile
	fi
if [ ! $WSS ]; then
		read -p "Enter ALCHEMY(Infura) WSS : " WSS
		echo 'export WSS='${WSS} >> $HOME/.bash_profile
	fi
sed -i -e "s%L1_ENDPOINT_HTTP=.*%L1_ENDPOINT_HTTP=${AHTTPS}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L1_ENDPOINT_WS=.*%L1_ENDPOINT_WS=${WSS}%g" $HOME/simple-taiko-node/.env
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
sed -i -e "s%L1_PROPOSER_PRIVATE_KEY=.*%L1_PROPOSER_PRIVATE_KEY=${MMP}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L2_SUGGESTED_FEE_RECIPIENT=.*%L2_SUGGESTED_FEE_RECIPIENT=${MMA}%g" $HOME/simple-taiko-node/.env
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
sleep 5
rm .env 
cp .env.sample .env 
sed -i -e "s%L1_ENDPOINT_HTTP=.*%L1_ENDPOINT_HTTP=${AHTTPS}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L1_ENDPOINT_WS=.*%L1_ENDPOINT_WS=${WSS}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L1_PROPOSER_PRIVATE_KEY=.*%L1_PROPOSER_PRIVATE_KEY=${MMP}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%L2_SUGGESTED_FEE_RECIPIENT=.*%L2_SUGGESTED_FEE_RECIPIENT=${MMA}%g" $HOME/simple-taiko-node/.env
sed -i -e "s%PORT_GRAFANA=3001%PORT_GRAFANA=3002%g" $HOME/simple-taiko-node/.env
sleep 2
#proposer 
read -r -p "Run proposer? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
    sed -i -e "s%ENABLE_PROPOSER=false%ENABLE_PROPOSER=true%g" $HOME/simple-taiko-node/.env
    sed -i -e "s%PROVER_ENDPOINTS=.*%PROVER_ENDPOINTS=$link%g" $HOME/simple-taiko-node/.env
    sed -i -e "s%BLOCK_PROPOSAL_FEE=.*%BLOCK_PROPOSAL_FEE=10%g" $HOME/simple-taiko-node/.env
    sed -i -e "s%MIN_ACCEPTABLE_PROOF_FEE=.*%MIN_ACCEPTABLE_PROOF_FEE=10%g" $HOME/simple-taiko-node/.env
    sed -i -e "s%PROVE_UNASSIGNED_BLOCKS=false%PROVE_UNASSIGNED_BLOCKS=true%g" $HOME/simple-taiko-node/.env
    sed -i -e "s%ENABLE_PROVER=false%ENABLE_PROVER=true%g" $HOME/simple-taiko-node/.env
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
"Enable proposer")
sed -i -e "s%ENABLE_PROPOSER=false%ENABLE_PROPOSER=true%g" $HOME/simple-taiko-node/.env
sed -i -e "s%PROVER_ENDPOINTS=.*%PROVER_ENDPOINTS=$link%g" $HOME/simple-taiko-node/.env
sed -i -e "s%BLOCK_PROPOSAL_FEE=.*%BLOCK_PROPOSAL_FEE=10%g" $HOME/simple-taiko-node/.env
sed -i -e "s%MIN_ACCEPTABLE_PROOF_FEE=.*%MIN_ACCEPTABLE_PROOF_FEE=10%g" $HOME/simple-taiko-node/.env
sed -i -e "s%PROVE_UNASSIGNED_BLOCKS=false%PROVE_UNASSIGNED_BLOCKS=true%g" $HOME/simple-taiko-node/.env
sed -i -e "s%ENABLE_PROVER=false%ENABLE_PROVER=true%g" $HOME/simple-taiko-node/.env
cd $HOME/simple-taiko-node && docker compose down
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