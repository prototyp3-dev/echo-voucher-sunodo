# Echo Voucher

```
Cartesi Rollups version: 1.0.x
```

The echo-voucher DApp works as an echo dapp, but instead it echoes assets back to the owner emitting vouchers, and also tries to emit vouchers when it receives a json object.

It is a customized DApp written in Python, which originally resembles the one provided by the sample [Echo Python DApp](https://github.com/cartesi/rollups-examples/tree/main/echo-python).

The documentation below reflects the original application code, and should also be used as a basis for documenting any DApp created with this mechanism.

## Requirements

Please refer to the [rollups-examples requirements](https://github.com/cartesi/rollups-examples/tree/main/README.md#requirements).

This project works with [sunodo](https://docs.sunodo.io/), so run it you should first install sunodo.

```shell
npm install -g @sunodo/cli
```

## Building

Build with:

```shell
sunodo build
```

## Running

Run with:

```shell
sunodo run
```

## Interact with the Application

To emit a generic voucher, send a json input with the following format

```json
{
    "destination": "0xabcd...1234",
    "payload": "0xabcd...1234"
}
```

Where destination is the destination contract and payload is the low level solidity call. You can the formatted json of the voucher the using inspect call. E.g. a mint from erc721 (instead of signature, you could provide the abi):

```shell
curl -s http://localhost:8080/inspect/$(echo '{"address":"'$ERC721_ADDRESS'","signature":"mint(address,string)","functionName":"mint","parameters":["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266","test"]}' | jq -sRr @uri) | jq '.reports[0].payload' | xxd -p -r
```

To make the dapp emit the voucher you could:

Interacting with the application (define the missing variables)

You can either use [sundo cli](https://docs.sunodo.io/guide/running/sending-inputs). Some variables:

```shell
MNEMONIC=
CHAIN_ID=31337
RPC=http://127.0.0.1:8545
DAPP_ADDRESS=0x70ac08179605AF2D9e75782b8DEcDD3c22aA4D0C

ERC721_ADDRESS=

ERC20_ADDRESS=
```

The sunodo send commands:

```shell
sunodo send dapp-address --chain-id=$CHAIN_ID --rpc-url=$RPC \
    --mnemonic-index=0 --mnemonic-passphrase="$MNEMONIC" \
    --dapp=$DAPP_ADDRESS

sunodo send ether --chain-id=$CHAIN_ID --rpc-url=$RPC \
    --mnemonic-index=0 --mnemonic-passphrase="$MNEMONIC" \
    --dapp=$DAPP_ADDRESS --amount=2.7

sunodo send erc20 --chain-id=$CHAIN_ID --rpc-url=$RPC \
    --mnemonic-index=0 --mnemonic-passphrase="$MNEMONIC" \
    --dapp=$DAPP_ADDRESS --token=$ERC20_ADDRESS --amount=7.2

sunodo send erc721 --chain-id=$CHAIN_ID --rpc-url=$RPC \
    --mnemonic-index=0 --mnemonic-passphrase="$MNEMONIC" \
    --dapp=$DAPP_ADDRESS --token=$ERC721_ADDRESS --tokenId=1

sunodo send generic --chain-id=$CHAIN_ID --rpc-url=$RPC \
    --mnemonic-index=0 --mnemonic-passphrase=$MNEMONIC \
    --dapp=$DAPP_ADDRESS --input=$(xxd -c10000 -p <<< '{"destination": "'$ERC721_ADDRESS'", "payload": "0xd0def521000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000047465737400000000000000000000000000000000000000000000000000000000"}')
```

Hint: to make the dapp emit any voucher could use the inspect then call the generic send:

```shell
voucher=$(curl -s http://localhost:8080/inspect/$(echo '{"address":"'$ERC721_ADDRESS'","signature":"mint(address,string)","functionName":"mint","parameters":["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266","test"]}' | jq -sRr @uri) | jq '.reports[0].payload' )

sunodo send generic --chain-id=$CHAIN_ID --rpc-url=$RPC \
    --mnemonic-index=0 --mnemonic-passphrase=$MNEMONIC \
    --dapp=$DAPP_ADDRESS --input=$voucher
```

Or you can use [foundry's cast](https://book.getfoundry.sh/reference/cast/). Some variables:

```shell
PRIVATE_KEY=

SIGNER_ADDRESS=

DAPP_ADDRESS=0x70ac08179605AF2D9e75782b8DEcDD3c22aA4D0C
INPUT_BOX_ADDRESS=0x59b22D57D4f067708AB0c00552767405926dc768
DAPP_RELAY_ADDRESS=0xF5DE34d6BbC0446E2a45719E718efEbaaE179daE
ETHER_PORTAL_ADDRESS=0xFfdbe43d4c855BF7e0f105c400A50857f53AB044
ERC20_PORTAL_ADDRESS=0x9C21AEb2093C32DDbC53eEF24B873BDCd1aDa1DB
ERC721_PORTAL_ADDRESS=0x237F8DD094C0e47f4236f12b4Fa01d6Dae89fb87

ERC721_ADDRESS=
ERC20_ADDRESS=

```

And cast commands:

```shell
cast send $DAPP_RELAY_ADDRESS \
    "relayDAppAddress(address)" $DAPP_ADDRESS \
    --rpc-url http://localhost:8545 --from $SIGNER_ADDRESS --private-key $PRIVATE_KEY


cast send $ETHER_PORTAL_ADDRESS \
    "depositEther(address,bytes)" $DAPP_ADDRESS 0x --value 1000000000000000000 \
    --rpc-url http://localhost:8545 --from $SIGNER_ADDRESS --private-key $PRIVATE_KEY


cast send $ERC20_ADDRESS \
    "increaseAllowance(address,uint256)" $ERC20_PORTAL_ADDRESS 1000000000000000000 \
    --rpc-url http://localhost:8545 --from $SIGNER_ADDRESS --private-key $PRIVATE_KEY

cast send $ERC20_PORTAL_ADDRESS \
    "depositERC20Tokens(address,address,uint256,bytes)" $ERC20_ADDRESS $DAPP_ADDRESS 1000000000000000000 0x  \
    --rpc-url http://localhost:8545 --from $SIGNER_ADDRESS --private-key $PRIVATE_KEY


cast send $ERC721_ADDRESS \
    "approve(address,uint256)" $ERC721_PORTAL_ADDRESS 1 \
    --rpc-url http://localhost:8545 --from $SIGNER_ADDRESS --private-key $PRIVATE_KEY

cast send $ERC721_PORTAL_ADDRESS \
    "depositERC721Token(address,address,uint256,bytes,bytes)" $ERC721_ADDRESS $DAPP_ADDRESS 1 0x 0x \
    --rpc-url http://localhost:8545 --from $SIGNER_ADDRESS --private-key $PRIVATE_KEY


cast send $INPUT_BOX_ADDRESS \
    "addInput(address,bytes)" $DAPP_ADDRESS $(xxd -c10000 -p <<< '{"destination": "'$ERC721_ADDRESS'", "payload": "0xd0def521000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000047465737400000000000000000000000000000000000000000000000000000000"}') \
    --rpc-url http://localhost:8545 --from $SIGNER_ADDRESS --private-key $PRIVATE_KEY

```

