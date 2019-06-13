# https://ethereum.stackexchange.com/questions/12830/how-to-get-private-key-from-account-address-and-password
from web3.auto import w3
private_key=""

with open("./scdeployer/keystore/UTC--2019-04-16T09-33-43.168599000Z--f71195df0eb8438dd9eaf839d3abb47859f2175f") as keyfile:
    encrypted_key = keyfile.read()
    private_key = w3.eth.account.decrypt(encrypted_key, 'testCh@in')

#import binascii
#binascii.b2a_hex(private_key)
#print(type(private_key)
print(private_key.hex())