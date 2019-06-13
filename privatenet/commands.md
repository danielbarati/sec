## Build the images

### Build base image
docker build -t base base


### Build the bootstrap and node images
docker-compose -f docker-compose.yml build


## Bootnode setup
In one terminal configure and run the bootstrap node:
docker-compose run --rm bootstrap 


## Run a node
In another terminal run other node using the same genesis block:
Will not port forward: docker-compose run --rm node
docker-compose run --rm -p 8545:8545 node

## Attach
geth attach ipc://home/euser/.ethereum/devchain/geth.ipc
## Attach from host machine
geth attach http://3.82.214.242:8540

## Transactions
web3.personal.unlockAccount(web3.personal.listAccounts[0],"testCh@in", 15000)
eth.getBalance(web3.personal.listAccounts[0])
eth.sendTransaction({from: "0x8090726167de701826cf63fdb560bda7ae652be4", to: "0x2828a8f260baa874625b3b794ed6509225f48b40", value: web3.toWei(1, "ether")})
eth.pendingTransactions



## Access RPC with host OS
curl -X POST 127.0.0.1:8545 --data '{"jsonrpc":"2.0","method":"shh_version","params":[],"id":1}' -H "Content-Type: application/json"

## Errors:
'authentication needed: password or unlock'
https://ethereum.stackexchange.com/questions/19122/authentication-needed-password-or-unlock-error-when-trying-to-call-smart-cont
https://medium.com/@julien.maffre/what-is-an-ethereum-keystore-file-86c8c5917b97

web3.personal.newAccount()
If you get [] then do web3.personal.newAccount()
if not:
web3.personal.unlockAccount(web3.personal.listAccounts[0],"<password>", 15000)


## Fix problem with discovery:
In one node: admin.nodeInfo.enode => paste result into other node with admin.addPeer()





# Helpful: geth console commands
admin.nodeInfo.enode
net.listening
net.peerCount
admin.peers
eth.coinbase
eth.getBalance(eth.coinbase)
personal
eth.accounts
miner.setEtherbase(web3.eth.accounts[0])
miner.setEtherbase(“0xae13d41d66af28380c7af6d825ab557eb271ffff”)
miner.start()
miner.stop()
miner.hashrate
eth.getBlock(0)
eth.getBlock(“latest”)
eth.blockNumber 
web3.eth.getBlock(BLOCK_NUMBER).hash
eth.syncing
debug.verbosity(6) // highest logging level, 3 is default
