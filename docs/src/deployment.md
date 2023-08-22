## Deployment

Just run this command to deploy the contracts to the network.

> Additionally, operator has to also add consumer to VRF coordinator contract.

```sh
❯ forge script script/SPNFT.s.sol:SPNFTScript --fork-url $SEPOLIA_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY --broadcast --verify
[⠢] Compiling...
[⠑] Compiling 21 files with 0.8.18
[⠃] Solc 0.8.18 finished in 49.22s
Compiler run successful!
Script ran successfully.

== Logs ==
  ERC20 token deployed at:  0x172A6cc82559ad433de768AEC313AFD26D1944d2
  SPNFT contract deployed at:  0x16F5deC50B35544215Fd1d7670A0a3cEaBD5aF43
  RSPNFT contract deployed at:  0x4d1260E2c32be7b66544b991530D3F74CDcEbc83
  The SPNFT's balance:  10000000000000000000000
  The SPNFT's balance:  10000000000000000000000

## Setting up (1) EVMs.

==========================

Chain 11155111

Estimated gas price: 10.22541403 gwei

Estimated total gas used for script: 10748250

Estimated amount required: 0.1099053063479475 ETH

==========================

###
Finding wallets for all the necessary addresses...
##
Sending transactions [0 - 3].
⠚ [00:00:02] [#######################################################################################################] 4/4 txes (0.0s)
Transactions saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/broadcast/SPNFT.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/cache/SPNFT.s.sol/11155111/run-latest.json

##
Waiting for receipts.
⠒ [00:00:14] [###################################################################################################] 4/4 receipts (0.0s)
##### sepolia
✅  [Success]Hash: 0xf02a85e4d1a55d0e7d7eb77e56f962ccdc25c46e1acc0e90e0429ef0ca7901d8
Contract Address: 0x172A6cc82559ad433de768AEC313AFD26D1944d2
Block: 4136795
Paid: 0.00749310441222431 ETH (881854 gas * 8.496989765 gwei)


##### sepolia
✅  [Success]Hash: 0x0c1498a8f7b15491efeca741307ab90848d5f6ef5829df0a4096ddad5a0be2b2
Contract Address: 0x16F5deC50B35544215Fd1d7670A0a3cEaBD5aF43
Block: 4136795
Paid: 0.061807298981374595 ETH (7274023 gas * 8.496989765 gwei)


##### sepolia
✅  [Success]Hash: 0x6f90b0c2e41c3a66045e5cb2035dac8fd4b884c4068304e5c3b98a41c198f524
Block: 4136795
Paid: 0.000435870083975205 ETH (51297 gas * 8.496989765 gwei)


##### sepolia
✅  [Success]Hash: 0x1e43bda1c63f8c7b2e746f6afd6d81c6e0642a96f28954632f6e2ed0bed71321
Block: 4136795
Paid: 0.000435870083975205 ETH (51297 gas * 8.496989765 gwei)


Transactions saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/broadcast/SPNFT.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/cache/SPNFT.s.sol/11155111/run-latest.json



==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
Total Paid: 0.070172143561549315 ETH (8258471 gas * avg 8.496989765 gwei)
##
Start verification for (3) contracts
Start verifying contract `0x172a6cc82559ad433de768aec313afd26d1944d2` deployed on sepolia

Submitting verification for [src/SPToken.sol:SPToken] "0x172A6cc82559ad433de768AEC313AFD26D1944d2".

Submitting verification for [src/SPToken.sol:SPToken] "0x172A6cc82559ad433de768AEC313AFD26D1944d2".

Submitting verification for [src/SPToken.sol:SPToken] "0x172A6cc82559ad433de768AEC313AFD26D1944d2".

Submitting verification for [src/SPToken.sol:SPToken] "0x172A6cc82559ad433de768AEC313AFD26D1944d2".

Submitting verification for [src/SPToken.sol:SPToken] "0x172A6cc82559ad433de768AEC313AFD26D1944d2".
Submitted contract for verification:
        Response: `OK`
        GUID: `7zj3lsne8nwf6qn97syhupbgsieg3pvfzkkimxugnhxdvrwtxy`
        URL:
        https://sepolia.etherscan.io/address/0x172a6cc82559ad433de768aec313afd26d1944d2
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
Start verifying contract `0x16f5dec50b35544215fd1d7670a0a3ceabd5af43` deployed on sepolia

Submitting verification for [src/SPNFT.sol:SPNFT] "0x16F5deC50B35544215Fd1d7670A0a3cEaBD5aF43".
Submitted contract for verification:
        Response: `OK`
        GUID: `8rckciqubtmxbjsgfkf6n9yiudsxm2pcivgvuf82ijmtugvcce`
        URL:
        https://sepolia.etherscan.io/address/0x16f5dec50b35544215fd1d7670a0a3ceabd5af43
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
Start verifying contract `0x4d1260e2c32be7b66544b991530d3f74cdcebc83` deployed on sepolia

Submitting verification for [src/RevealedSPNFT.sol:RevealedSPNFT] "0x4d1260E2c32be7b66544b991530D3F74CDcEbc83".
Submitted contract for verification:
        Response: `OK`
        GUID: `3qzgskxb47bne4ibgsjzcmkwjmsuswr2hmas7vqvhdndvnlv11`
        URL:
        https://sepolia.etherscan.io/address/0x4d1260e2c32be7b66544b991530d3f74cdcebc83
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (3) contracts were verified!

Transactions saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/broadcast/SPNFT.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/cache/SPNFT.s.sol/11155111/run-latest.json
```
