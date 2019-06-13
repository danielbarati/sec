# Self-Emerging Challenges Contract
## Installation Requirements
- [Docker and Docker-Compose](https://www.docker.com/products/docker-desktop)
- [Truffle](https://www.trufflesuite.com/truffle) and [Ganache](https://www.trufflesuite.com/ganache)
- [Go](https://golang.org/dl/) - go version go1.12.4 darwin/amd64
- [Geth command line tool](https://github.com/ethereum/go-ethereum/wiki/Installing-Geth)
- [Geth](https://github.com/ethereum/go-ethereum) - commit used for this project: ```2cfe0bed9f0d96e3b0750cf3a6aa7f72894af53d```.


## SEC Smart Contract
The SEC smart contract is found in ```/Sec/contracts/SecContract.sol```. It can be deployed using on the alternatives in this list:
- [Truffle](https://www.trufflesuite.com/truffle) and [Ganache](https://www.trufflesuite.com/ganache) - needs installation. Use their respective documentation.
- [Remix](https://remix.ethereum.org/) - needs no installation. Deploy directly in the web IDE. Interaction with the smart contract can be made through the UI.
- the deployment code in ```/client/deployer/deployer.go```. To use this, change the IP constant in ```/client/utils/constants.go``` to the IP of a node that is connected to an Ethereum network. This option is intended to be used with a local, private Ethereum network. Interactions with the smart contract can be done using RPC calling (see ```/client/curl.txt```).


## Local, Private Ethereum Network Using Docker
A Docker-Compose configuration for running a local, private Ethereum network is given in ```/privatenet```. Install Docker and Docker-Compose. Run the following commands in the ```/privatenet``` directory:
- ```docker build -t base base```
- ```docker-compose -f docker-compose.yml build```
- ```docker-compose up```

Other handy commands can be found in ```/privatenet/commands.md```.

Following list presents the Ethereum nodes that are created in separate Docker containers:
- bootstrap
- node1
- node2
- node3
- scdeployer
- explorer (not an Ethereum node, but opens HTTP port through 8080 to provide a blockchain explorer UI)

It is possible to use the Geth CLI to connect to the Geth JavaScript console of an Ethereum node using: ```geth attach http://IP:PORT```. For instance, connect to node1 using ```geth attach http://127.0.0.1:8545```. A summary of the configuration info of all nodes is provided in ```/client/nodeinfo.json```.

New nodes can be added to the network by adding to the Docker-Compose configuration. Create key-store file using the Geth CLI: ```geth account new```. Follow the configuration scheme as given in ```/privatenet```.

An example application that utilizes the Whisper protocol module (```/client/utils/whisper.go```) for demonstrating P2P communication between nodes is given in ```/client/main.go```. To run this example, open a terminal and run ```go run main.go```. The code creates a sender (node1) and a receiver (node2). The sender transfers message *"Hello"* to the receiver. The receiver receives this message and outputs it to the terminal.


## Test Data for SEC contract
A series of test data for various setups paths is given in the following list.
- 1 path containing 1 peer: ```/testdata/1path1peer.txt```
- 1 path containing 2 peers: ```/testdata/1path2peer.txt```
- 1 path containing 3 peers: ```/testdata/1path3peer.txt```
- 2 paths, each containing 1 peer: ```/testdata/2path1peer.txt```
- 3 paths, each containing 1 peer: ```/testdata/3path1peer.txt```
- 3 paths, each containing 3 peer: ```/testdata/3path3peer.txt```

## Contact
Feel free to contact me here on Github if you have any questions.