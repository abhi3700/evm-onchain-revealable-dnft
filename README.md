## SC Solidity Foundry Boilerplate

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```sh
$ forge build
```

### Test

```sh
$ forge test
```

---

To view gas-usage in table format:

```sh
$ forge test --gas-report
```

#### Fork testing

On Sepolia testnet:

```sh
$ forge test --mp test/sepolia/SPNFTTest.t.sol --fork-url $SEPOLIA_RPC_URL
```

### Format

```sh
$ forge fmt
```

### Contract size

```sh
$ forge build --sizes
```

> also need to add `--via-ir` flag to `forge build` command, if `stack too deep`.

### Gas Snapshots

```sh
$ forge snapshot
```

### Anvil

```sh
$ anvil
```

### Deploy

```sh
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

---

Deploy to Anvil:

```sh
$ forge script script/Counter.s.sol:CounterScript --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```

For this script to work, you need to have a `MNEMONIC` environment variable set to a valid
[BIP39 mnemonic](https://iancoleman.io/bip39/).

For instructions on how to deploy to a testnet or mainnet, check out the
[Solidity Scripting](https://book.getfoundry.sh/tutorials/solidity-scripting.html) tutorial.

### Deploy & Verify

Deploy to Goerli and verify on Etherscan:

Set the `.env` as per the [`.env.example`](./.env.example) file.

```sh
$ source .env
$ forge script script/Counter.s.sol:CounterScript --rpc-url $GOERLI_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY --broadcast --verify -vvvvv
```

> With logs enabled using `-vvvvv`, you can see the transaction hash and the etherscan link.

### Flatten

```sh
$ forge flatten src/Counter.sol -o flatten/src/CounterFlattened.sol
```

### Cast

```sh
$ cast <subcommand>
```

### Help

```sh
$ forge --help
$ anvil --help
$ cast --help
```
