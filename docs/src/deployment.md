---
title: Deployment
---

```sh
❯ forge script script/SPNFT.s.sol:SPNFTScript --fork-url $SEPOLIA_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY --broadcast --verify                      ⏎
[⠢] Compiling...
[⠊] Compiling 2 files with 0.8.18
[⠢] Solc 0.8.18 finished in 2.88s
Compiler run successful!
Script ran successfully.

== Logs ==
  ERC20 token deployed at:  0x3B2D448296b0E73f33ca98459EFD256C22656f4B
  SPNFT contract deployed at:  0x185104B1fF9494A4587fAAE6104c8b5333e21D0d
  RSPNFT contract deployed at:  0x6edDF6A2480d45A0E6C14D07e3273eB8eC0De012
  The SPNFT's balance:  10000000000000000000000
  The SPNFT's balance:  10000000000000000000000

## Setting up (1) EVMs.

==========================

Chain 11155111

Estimated gas price: 23.529531852 gwei

Estimated total gas used for script: 9760734

Estimated amount required: 0.229665501551899368 ETH

==========================

###
Finding wallets for all the necessary addresses...
##
Sending transactions [0 - 3].
⠚ [00:00:01] [#######################################################################################################################################################################################] 4/4 txes (0.0s)
Transactions saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/broadcast/SPNFT.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/cache/SPNFT.s.sol/11155111/run-latest.json

##
Waiting for receipts.
⠒ [00:00:13] [###################################################################################################################################################################################] 4/4 receipts (0.0s)
##### sepolia
✅  [Success]Hash: 0xe58709760cc8f2770096a33f30cb4b1595e9a707d9851435cc0dde0671994d93
Contract Address: 0x3B2D448296b0E73f33ca98459EFD256C22656f4B
Block: 4132341
Paid: 0.012808389022615739 ETH (856633 gas * 14.952014483 gwei)


##### sepolia
✅  [Success]Hash: 0x5def17238ca7f30c7254294737c120663d6d9b5f055a58c6b9689d2594988438
Contract Address: 0x185104B1fF9494A4587fAAE6104c8b5333e21D0d
Block: 4132341
Paid: 0.097776411053362601 ETH (6539347 gas * 14.952014483 gwei)


##### sepolia
✅  [Success]Hash: 0xb781a8633f55855fdb74bce1e04eb90adcbf7506a1139ef7e2820d1176b8227b
Block: 4132341
Paid: 0.000766664542615825 ETH (51275 gas * 14.952014483 gwei)


##### sepolia
✅  [Success]Hash: 0xd967095f71fe0a66cdc05a13d4b1bd2aa83ed25a5ef03f06c590a7384dc06f56
Block: 4132341
Paid: 0.000766664542615825 ETH (51275 gas * 14.952014483 gwei)


Transactions saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/broadcast/SPNFT.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/cache/SPNFT.s.sol/11155111/run-latest.json



==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
Total Paid: 0.11211812916120999 ETH (7498530 gas * avg 14.952014483 gwei)
##
Start verification for (3) contracts
Start verifying contract `0x3b2d448296b0e73f33ca98459efd256c22656f4b` deployed on sepolia

Submitting verification for [src/SPToken.sol:SPToken] "0x3B2D448296b0E73f33ca98459EFD256C22656f4B".

Submitting verification for [src/SPToken.sol:SPToken] "0x3B2D448296b0E73f33ca98459EFD256C22656f4B".

Submitting verification for [src/SPToken.sol:SPToken] "0x3B2D448296b0E73f33ca98459EFD256C22656f4B".
Submitted contract for verification:
        Response: `OK`
        GUID: `lxd5cy3hz8dj4yivzeyqb4mp7sd1htbdv6lkivgsficatbdk2w`
        URL:
        https://sepolia.etherscan.io/address/0x3b2d448296b0e73f33ca98459efd256c22656f4b
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
Start verifying contract `0x185104b1ff9494a4587faae6104c8b5333e21d0d` deployed on sepolia

Submitting verification for [src/SPNFT.sol:SPNFT] "0x185104B1fF9494A4587fAAE6104c8b5333e21D0d".
Submitted contract for verification:
        Response: `OK`
        GUID: `stuhxhceybm31xx1eymxcexxjsslwxeszk1hidz4jwx66difdt`
        URL:
        https://sepolia.etherscan.io/address/0x185104b1ff9494a4587faae6104c8b5333e21d0d
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
Start verifying contract `0x6eddf6a2480d45a0e6c14d07e3273eb8ec0de012` deployed on sepolia

Submitting verification for [src/RevealedSPNFT.sol:RevealedSPNFT] "0x6edDF6A2480d45A0E6C14D07e3273eB8eC0De012".
Submitted contract for verification:
        Response: `OK`
        GUID: `ney4knwnyepqitxu3fvfh2qieigss7ac8u9zuvbdmvfuetbv8c`
        URL:
        https://sepolia.etherscan.io/address/0x6eddf6a2480d45a0e6c14d07e3273eb8ec0de012
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
