FROM base

ENV bootnodeID=""
ENV bootnodeIP=""
ENV scdeployerkey=""
ENV address=""

RUN echo "alias attach='geth attach ipc://home/euser/.ethereum/devchain/geth.ipc'" >> ~/.bashrc; source ~/.bashrc

# With rpc:
CMD exec geth --datadir="/home/euser/.ethereum/devchain" --networkid=$networkID --nat extip:`hostname -i` --identity=`hostname` -nodekeyhex $scdeployerkey --bootnodes "enode://$bootnodeID@$bootnodeIP:30301" --rpc --shh --rpcaddr=0.0.0.0 --rpcport=8540 --port=30303 --rpcapi "eth,web3,net,admin,debug,db,shh" --rpccorsdomain "*" --maxpeers=10 --password /home/euser/eth-config/password --unlock $address
#--allow-insecure-unlock

EXPOSE 8080 8540-8547 30303 30303/udp