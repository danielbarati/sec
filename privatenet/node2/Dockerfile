FROM base

ENV bootnodeID=""
ENV bootnodeIP=""
ENV node2key=""
ENV address=""

RUN echo "alias attach='geth attach ipc://home/euser/.ethereum/devchain/geth.ipc'" >> ~/.bashrc; source ~/.bashrc

#CMD exec geth --datadir="/home/euser/.ethereum/devchain" --networkid=$networkID --nat extip:`hostname -i` --bootnodes "enode://$bootnodeID@$bootnodeIP:30301" --rpc  --rpcaddr="0.0.0.0" --shh --rpcapi "eth,web3,net,admin,debug,db,shh" --rpccorsdomain "*" --maxpeers=3

# With rpc:
#CMD exec geth --datadir="/home/euser/.ethereum/devchain" --networkid=$networkID --nat extip:`hostname -i` --identity=`hostname` -nodekeyhex $node2key --bootnodes "enode://$bootnodeID@$bootnodeIP:30301" --rpc --shh --rpcaddr=0.0.0.0 --rpcport=8545 --port=30303 --rpcapi "eth,web3,net,admin,debug,db,shh" --rpccorsdomain "*" --maxpeers=10 --password /home/euser/eth-config/password --unlock $address
# With ws:
#CMD exec geth --datadir="/home/euser/.ethereum/devchain" --networkid=$networkID --nat extip:`hostname -i` --identity=`hostname` -nodekeyhex $node2key --bootnodes "enode://$bootnodeID@$bootnodeIP:30301" --ws --shh --wsaddr=0.0.0.0 --wsport=8545 --port=30303 --wsapi "eth,web3,net,admin,debug,db,shh" --wsorigins="*" --rpccorsdomain "*" --maxpeers=10 --password /home/euser/eth-config/password --unlock $address
# With rpc and ws:
CMD exec geth --datadir="/home/euser/.ethereum/devchain" \
--networkid=$networkID --nat extip:`hostname -i` --identity=`hostname` -nodekeyhex $node2key \
--bootnodes "enode://$bootnodeID@$bootnodeIP:30301" --port=30303 \ 
--rpc --rpcaddr=0.0.0.0 --rpcport=8545 --rpcapi "eth,web3,net,admin,debug,db" --rpccorsdomain "*" \
--ws --shh --wsaddr=0.0.0.0 --wsport=9545 --wsapi "shh" --wsorigins="*" \
--maxpeers=10 --password /home/euser/eth-config/password --unlock $address
#--allow-insecure-unlock

EXPOSE 8080 8545-8546 9545 30303 30303/udp