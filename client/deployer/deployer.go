package main

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"github.com/datmas/client/utils"
	"log"
	"math/big"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"

	sed "github.com/datmas/client/sedcontract"
)

func main() {
	nodes := utils.GetNodes("./nodeinfo.json")

	client, err := ethclient.Dial("http://" + utils.IP + ":" + nodes[3].RpcPort) //scdeployer
	if err != nil {
		log.Fatal(err)
	}

	privateKey, err := crypto.HexToECDSA(nodes[3].PrivateKey) //scdeployer
	if err != nil {
		log.Fatal(err)
	}

	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("error casting public key to ECDSA")
	}

	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)
	nonce, err := client.PendingNonceAt(context.Background(), fromAddress)
	if err != nil {
		log.Fatal(err)
	}

	gasPrice, err := client.SuggestGasPrice(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	auth := bind.NewKeyedTransactor(privateKey)
	auth.Nonce = big.NewInt(int64(nonce))
	auth.Value = big.NewInt(0)                // in wei
	auth.GasLimit = uint64(8000000)            // in units
	auth.GasPrice = gasPrice

	address, tx, instance, err := sed.DeploySedcontract(auth, client)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Contract address: ", address.Hex())
	fmt.Println("Tx hash: ", tx.Hash().Hex())

	_ = instance
}
