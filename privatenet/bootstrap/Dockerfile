FROM base

# Default bootstrap node ip
ENV bootnodeIP="127.0.0.1"

# Setup bootstrap node
ENV bootkeyhex=""
ENV address=""
#entrypoint?
RUN echo "alias attach='geth attach ipc://home/euser/.ethereum/devchain/geth.ipc'" >> ~/.bashrc; source ~/.bashrc

# CMD exec bootnode -nodekeyhex $keyhex
CMD exec geth --datadir="/home/euser/.ethereum/devchain" --networkid=$networkID --nat extip:$bootnodeIP --identity=`hostname` -nodekeyhex $bootkeyhex --port=30301  --maxpeers=10 --password /home/euser/eth-config/password --unlock $address
#--allow-insecure-unlock

EXPOSE 30301/udp 30303