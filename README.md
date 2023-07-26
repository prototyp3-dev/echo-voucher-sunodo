# Echo Voucher

```
Cartesi Rollups version: 0.9.x
```

The echo-voucher DApp works as an echo dapp, but instead it echoes assets back to the owner emitting vouchers, and also tries to emit vouchers when it receives a json object.

It is a customized DApp written in Python, which originally resembles the one provided by the sample [Echo Python DApp](https://github.com/cartesi/rollups-examples/tree/main/echo-python).
Contrary to that example, this DApp does not use shared resources from the `rollups-examples` main directory, and as such the commands for building, running and deploying it are slightly different.

The documentation below reflects the original application code, and should also be used as a basis for documenting any DApp created with this mechanism.

## Requirements

Please refer to the [rollups-examples requirements](https://github.com/cartesi/rollups-examples/tree/main/README.md#requirements).

This project works with [sunodo](https://github.com/sunodo/sunodo), so run it you should first install sunodo.

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

Interacting with the application (define the missing variables)

```shell
PRIVATE_KEY=

SIGNER_ADDRESS=

DAPP_ADDRESS=0x142105FC8dA71191b3a13C738Ba0cF4BC33325e2
INPUT_BOX_ADDRESS=0x5a723220579C0DCb8C9253E6b4c62e572E379945
DAPP_RELAY_ADDRESS=0x8Bbc0e6daB541DF0A9f0bDdA5D41B3B08B081d55
ETHER_PORTAL_ADDRESS=0xA89A3216F46F66486C9B794C1e28d3c44D59591e
ERC20_PORTAL_ADDRESS=0x4340ac4FcdFC5eF8d34930C96BBac2Af1301DF40
ERC721_PORTAL_ADDRESS=0x4CA354590EB934E6094Be762b38dE75d1Dd605a9


cast send $DAPP_RELAY_ADDRESS \
    "relayDAppAddress(address)" $DAPP_ADDRESS \
    --rpc-url http://localhost:8545 --from $SIGNER_ADDRESS --private-key $PRIVATE_KEY


cast send $ETHER_PORTAL_ADDRESS \
    "depositEther(address,bytes)" $DAPP_ADDRESS 0x --value 1000000000000000000 \
    --rpc-url http://localhost:8545 --from $SIGNER_ADDRESS --private-key $PRIVATE_KEY


ERC20_ADDRESS=

cast send $ERC20_ADDRESS \
    "increaseAllowance(address,uint256)" $ERC20_PORTAL_ADDRESS 1000000000000000000 \
    --rpc-url http://localhost:8545 --from $SIGNER_ADDRESS --private-key $PRIVATE_KEY

cast send $ERC20_PORTAL_ADDRESS \
    "depositERC20Tokens(address,address,uint256,bytes)" $ERC20_ADDRESS $DAPP_ADDRESS 1000000000000000000 0x  \
    --rpc-url http://localhost:8545 --from $SIGNER_ADDRESS --private-key $PRIVATE_KEY


ERC721_ADDRESS=

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
