FROM base

ENV bootnodeID=""
ENV bootnodeIP=""
ENV minerkey=""
ENV address=""

RUN echo "alias attach='geth attach ipc://home/euser/.ethereum/devchain/geth.ipc'" >> ~/.bashrc; source ~/.bashrc

# With rpc:
#CMD exec geth --datadir="/home/euser/.ethereum/devchain" --networkid=$networkID --nat extip:`hostname -i` --identity=`hostname` -nodekeyhex $minerkey --bootnodes "enode://$bootnodeID@$bootnodeIP:30301" --rpc --shh --rpcaddr=0.0.0.0 --rpcport=8545 --port=30303 --rpcapi "eth,web3,net,admin,debug,db,shh" --rpccorsdomain "*" --maxpeers=10 --password /home/euser/eth-config/password --unlock $address --etherbase "0x4bccda700fd05bfcf553fdaafcaaaee5e772a27e" --mine --minerthreads=1 
# With ws:
CMD exec geth --datadir="/home/euser/.ethereum/devchain" --networkid=$networkID --nat extip:`hostname -i` --identity=`hostname` -nodekeyhex $minerkey --bootnodes "enode://$bootnodeID@$bootnodeIP:30301" --ws --shh --wsaddr=0.0.0.0 --wsport=8545 --port=30303 --wsapi "eth,web3,net,admin,debug,db,shh" --wsorigins="*" --rpccorsdomain "*" --maxpeers=10 --password /home/euser/eth-config/password --unlock $address --etherbase "0x4bccda700fd05bfcf553fdaafcaaaee5e772a27e" --mine --minerthreads=1 
#--allow-insecure-unlock

EXPOSE 8080 8545-8550 30303 30303/udp