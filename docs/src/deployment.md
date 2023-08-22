---
title: Deployment
---

```sh
❯ forge script script/SPNFT.s.sol:SPNFTScript --fork-url $SEPOLIA_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY --broadcast --verify
[⠢] Compiling...
No files changed, compilation skipped
Script ran successfully.

== Logs ==
  ERC20 token deployed at:  0x199e8a373431bb894a4108BC5749A682Ee6D76Ab
  SPNFT contract deployed at:  0x8B2B82cb1Ae16F6b9Bd825078c0c31D3BeB8c45A
  RSPNFT contract deployed at:  0xF63A2898AbfB69f8A35E381793856E0e528DCFdF
  The SPNFT's balance:  10000000000000000000000
  The SPNFT's balance:  10000000000000000000000

## Setting up (1) EVMs.

==========================

Chain 11155111

Estimated gas price: 3.000398678 gwei

Estimated total gas used for script: 10671730

Estimated amount required: 0.03201944458397294 ETH

==========================

###
Finding wallets for all the necessary addresses...
##
Sending transactions [0 - 3].
⠚ [00:00:02] [############################################################################################################################################] 4/4 txes (0.0s)
Transactions saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/broadcast/SPNFT.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/cache/SPNFT.s.sol/11155111/run-latest.json

##
Waiting for receipts.
⠒ [00:00:20] [########################################################################################################################################] 4/4 receipts (0.0s)
##### sepolia
✅  [Success]Hash: 0x15dbe9895dabaa6f5593c8063c00cecba06e6744e97dc116b2f041ad12370889
Contract Address: 0x199e8a373431bb894a4108BC5749A682Ee6D76Ab
Block: 4134818
Paid: 0.002570040324742441 ETH (856633 gas * 3.000164977 gwei)


##### sepolia
✅  [Success]Hash: 0xe8cc5c1791793657a56e9d4f5b1ab5ba4d881c667c998c3f1e999a3f4309903a
Contract Address: 0x8B2B82cb1Ae16F6b9Bd825078c0c31D3BeB8c45A
Block: 4134818
Paid: 0.021722421500955593 ETH (7240409 gas * 3.000164977 gwei)


##### sepolia
✅  [Success]Hash: 0x94d3e96cef39c94878f468007318998e3aa3749df638d361238e6b196813dee4
Block: 4134818
Paid: 0.000153833459195675 ETH (51275 gas * 3.000164977 gwei)


##### sepolia
✅  [Success]Hash: 0xbf8318a80d3cf7bf310e1cc58725e7c5e3a3e59fc0c3ca4116a67a98668eb9da
Block: 4134818
Paid: 0.000153833459195675 ETH (51275 gas * 3.000164977 gwei)


Transactions saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/broadcast/SPNFT.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/cache/SPNFT.s.sol/11155111/run-latest.json



==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
Total Paid: 0.024600128744089384 ETH (8199592 gas * avg 3.000164977 gwei)

We haven't found any matching bytecode for the following contracts: [0x199e8a373431bb894a4108bc5749a682ee6d76ab, 0x8b2b82cb1ae16f6b9bd825078c0c31d3beb8c45a, 0xf63a2898abfb69f8a35e381793856e0e528dcfdf].

This may occur when resuming a verification, but the underlying source code or compiler version has changed.
##
Start verification for (0) contracts
All (0) contracts were verified!

Transactions saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/broadcast/SPNFT.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/cache/SPNFT.s.sol/11155111/run-latest.json
```
