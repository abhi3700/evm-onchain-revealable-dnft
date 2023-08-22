## Interaction with Contract

Mint tokens to itself: `[0x0370D871f1D4B256E753120221F3Be87A40bd246, bytes32("nft 1"), bytes32("good nft")]`

```sh
$ cast send $SPNFT "mint(address,bytes32,bytes32)" 0x0370D871f1D4B256E753120221F3Be87A40bd246 0x226e667420312200000000000000000000000000000000000000000000000000 0x22676f6f64206e66742200000000000000000000000000000000000000000000 --rpc-url $SEPOLIA_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY
```

---

TODO:

## Resources

- [Online String to Bytes32 Solidity Converter](https://www.devoven.com/string-to-bytes32)
- [Online Bytes32 to String Solidity Converter](https://www.devoven.com/bytes32-to-string)
