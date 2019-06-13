# Commands
## Create new project 
truffle init

## Compile and deploy project
truffle compile
truffle migrate

## Run unit tests
truffle test

## Solium linter
solium -d contracts/ --fix-dry-run

## Compile to Go contract file (for interaction with SC)
solc --overwrite --abi ./contracts/SecContract.sol -o build && abigen --abi=./build/SecContract.abi --pkg=seccontract --out=../client/seccontract/SecContract.go

## Compile to Go contract file (for deploying SC)
solc --overwrite --abi ./contracts/SecContract.sol -o build
solc --overwrite --bin ./contracts/SecContract.sol -o build
abigen --bin=./build/SecContract.bin --abi=./build/SecContract.abi --pkg=seccontract --out=../client/seccontract/SecContract.go
