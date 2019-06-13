package utils

import (
	"context"
	"fmt"
	"log"

	"github.com/ethereum/go-ethereum"

	"github.com/ethereum/go-ethereum/whisper/shhclient"
	"github.com/ethereum/go-ethereum/whisper/whisperv6"
)

// WhisperSender manages the communication through the Whisper protocol
type WhisperSender struct {
	SymKey   []byte
	symKeyID string
	client   *shhclient.Client
}

// NewWhisperSender initializes a new server.
func NewWhisperSender(nodeID int) *WhisperSender {
	nodes := GetNodes("./nodeinfo.json")
	client, err := shhclient.Dial("ws://" + IP + ":" + nodes[nodeID].WsPort)
	if err != nil {
		log.Fatal("Shh dialing error.", err)
	}
	symKeyID, err := client.GenerateSymmetricKeyFromPassword(context.Background(), nodes[nodeID].Password)
	if err != nil {
		log.Fatal("SymKey generating error.", err)
	}
	symKey, err := client.GetSymmetricKey(context.Background(), symKeyID)
	if err != nil {
		log.Fatal("SymKey obtaining error.", err)
	}

	return &WhisperSender{
		SymKey:   symKey,
		symKeyID: symKeyID,
		client:   client,
	}
}

// SendMessage ...
func (w *WhisperSender) SendMessage([]byte) (messageHash string) {
	bytes := make([]byte, whisperv6.TopicLength)
	bytes[0], bytes[1], bytes[2], bytes[3] = 0x0, 0x1, 0x2, 0x3 //TODO: change to be "Proof of Storage"
	topic := whisperv6.BytesToTopic(bytes)

	message := whisperv6.NewMessage{
		Payload:   []byte("Hello"),
		SymKeyID:  w.symKeyID,
		TTL:       60,
		Topic:     topic,
		PowTime:   2,
		PowTarget: 2.5,
	}
	messageHash, err := w.client.Post(context.Background(), message)
	if err != nil {
		log.Fatal("Message sending error.", err)
	}
	return messageHash
}

// WhisperReceiver ...
type WhisperReceiver struct {
	MessageListener chan *whisperv6.Message
	Subscription    ethereum.Subscription
}

// NewWhisperReceiver ...
func NewWhisperReceiver(nodeID int, symKey []byte) *WhisperReceiver {
	nodes := GetNodes("./nodeinfo.json")
	client, err := shhclient.Dial("ws://" + IP + ":" + nodes[nodeID].WsPort)
	if err != nil {
		log.Fatal("Shh dialing error.", err)
	}

	symKeyID, err := client.AddSymmetricKey(context.Background(), symKey)
	if err != nil {
		log.Fatal("Symkey adding error.", err)
	}

	bytes := make([]byte, whisperv6.TopicLength)
	bytes[0], bytes[1], bytes[2], bytes[3] = 0x0, 0x1, 0x2, 0x3 //TODO: change to be "Proof of Storage"
	topic := whisperv6.BytesToTopic(bytes)
	topics := make([]whisperv6.TopicType, 4)
	topics = append(topics, topic)

	messageListener := make(chan *whisperv6.Message)
	criteria := whisperv6.Criteria{
		SymKeyID: symKeyID,
		Topics:   topics,
	}
	sub, err := client.SubscribeMessages(context.Background(), criteria, messageListener)
	if err != nil {
		log.Fatal(err)
	}

	go func() {
		for {
			select {
			case err := <-sub.Err():
				log.Fatal(err)
			case message := <-messageListener:
				fmt.Printf(string(message.Payload)) // "Hello"
				//os.Exit(0)
			}
		}
	}()

	return &WhisperReceiver{
		MessageListener: messageListener,
		Subscription:    sub,
	}
}
