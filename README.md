## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```


### Deploy

```shell
export PRIVATE_KEY="xxx"密钥
export RPC_URL="https://arbitrum-sepolia.infura.io/v3/xxxx"（https://app.infura.io/login：注册以后，去申请api）

forge script script/deploy.s.sol:DeployScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

### verify

```shell
forge verify-contract <合约地址> src/SalukiToken.sol:SalukiToken --constructor-args $ABI_ARGS --chain arbitrum-sepolia --api-key <如果你是在以太坊网络上，那就去https://etherscan.io/浏览器上申请api，然后填入>
```

