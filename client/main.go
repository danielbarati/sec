package main

import (
	"fmt"
	"log"
	"runtime"

	"github.com/sec/client/utils"
)

func main() {
	sNodeID := 0
	rNodeID := 1

	sender := utils.NewWhisperSender(sNodeID)

	receiver := utils.NewWhisperReceiver(rNodeID, sender.SymKey)

	go func() {
		for {
			select {
			case err := <-receiver.Subscription.Err():
				log.Fatal(err)
			case message := <-receiver.MessageListener:
				fmt.Println("Incoming message: " + string(message.Payload))
				//os.Exit(0)
			}
		}
	}()

	msgHash := sender.SendMessage([]byte("Hello"))
	fmt.Println(msgHash)

	runtime.Goexit() // wait for goroutines to finish */

}
