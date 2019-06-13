package utils

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
)

// Nodes contains the participating nodes in the network
type Nodes []Node

// Node contains the attributes of a node in the network
type Node struct {
	NodeName    string
	RpcPort     string
	WsPort      string
	PublicKey   string
	PrivateKey  string
	AccountAddr string
	Password    string
	RSAPrivateKey string
}

// GetNodes parses and returns the configuration of the nodes from a json file.
func GetNodes(jsonFile string) []Node {
	raw, err := ioutil.ReadFile(jsonFile)
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}

	var nodes Nodes
	err = json.Unmarshal(raw, &nodes)
	return nodes
}
