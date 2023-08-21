---
title: Deployment
---

```sh
❯ forge script script/SPNFT.s.sol:SPNFTScript --fork-url $SEPOLIA_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY --broadcast --verify                                                                                                               ⏎
[⠒] Compiling...
[⠘] Compiling 5 files with 0.8.18
[⠃] Solc 0.8.18 finished in 32.83s
Compiler run successful!
Script ran successfully.

== Logs ==
  ERC20 token deployed at:  0x0FF7850D1230e2B7A1aEc52CcBb5208A05cb429c
  SPNFT contract deployed at:  0x743a07e54C9501EaD5AA5296983431d8CBC9597c
  RSPNFT contract deployed at:  0xB022456330E4FF95519b5a6b6Cf70f303d1AB97C
  The SPNFT's balance:  10000000000000000000000
  The SPNFT's balance:  10000000000000000000000

## Setting up (1) EVMs.

==========================

Chain 11155111

Estimated gas price: 3.1929522 gwei

Estimated total gas used for script: 9859568

Estimated amount required: 0.0314811293366496 ETH

==========================

###
Finding wallets for all the necessary addresses...
##
Sending transactions [0 - 3].
⠚ [00:00:01] [####################################################################################################################################################################################################################] 4/4 txes (0.0s)
Transactions saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/broadcast/SPNFT.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/cache/SPNFT.s.sol/11155111/run-latest.json

##
Waiting for receipts.
⠒ [00:00:27] [################################################################################################################################################################################################################] 4/4 receipts (0.0s)
##### sepolia
✅  [Success]Hash: 0x83250dcab79f30c384d20e06d04ac63590e972d10cbe0c9b49f98f38c910ebe0
Contract Address: 0x0FF7850D1230e2B7A1aEc52CcBb5208A05cb429c
Block: 4133218
Paid: 0.002631754974105415 ETH (856633 gas * 3.072208255 gwei)


##### sepolia
✅  [Success]Hash: 0x0d8049d10f1b9607aae2a27577664ba8009ae2e63cc80f7d3432c569f224e6a8
Contract Address: 0x743a07e54C9501EaD5AA5296983431d8CBC9597c
Block: 4133218
Paid: 0.020323889562335255 ETH (6615401 gas * 3.072208255 gwei)


##### sepolia
✅  [Success]Hash: 0xd27e77b477b7f1e2e465e08a6bcf15a081b501646eb046c84a735fadb1a65d29
Block: 4133218
Paid: 0.000157527478275125 ETH (51275 gas * 3.072208255 gwei)


##### sepolia
✅  [Success]Hash: 0xdd3da7bbffa8c7b49467ceca2c4679c1e5aa77ee376fa96bda1f8b9dc9b25e18
Block: 4133218
Paid: 0.000157527478275125 ETH (51275 gas * 3.072208255 gwei)


Transactions saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/broadcast/SPNFT.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/cache/SPNFT.s.sol/11155111/run-latest.json



==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
Total Paid: 0.02327069949299092 ETH (7574584 gas * avg 3.072208255 gwei)

We haven't found any matching bytecode for the following contracts: [0x0ff7850d1230e2b7a1aec52ccbb5208a05cb429c].

This may occur when resuming a verification, but the underlying source code or compiler version has changed.
##
Start verification for (2) contracts
Start verifying contract `0x743a07e54c9501ead5aa5296983431d8cbc9597c` deployed on sepolia

Submitting verification for [src/SPNFT.sol:SPNFT] "0x743a07e54C9501EaD5AA5296983431d8CBC9597c".
Submitted contract for verification:
        Response: `OK`
        GUID: `mzctwcxvn45e8es9ihyqqi9uimew3uq9zbw7jmgnxzxdthxwhv`
        URL:
        https://sepolia.etherscan.io/address/0x743a07e54c9501ead5aa5296983431d8cbc9597c
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
Start verifying contract `0xb022456330e4ff95519b5a6b6cf70f303d1ab97c` deployed on sepolia

Contract [src/RevealedSPNFT.sol:RevealedSPNFT] "0xB022456330E4FF95519b5a6b6Cf70f303d1AB97C" is already verified. Skipping verification.
All (2) contracts were verified!

Transactions saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/broadcast/SPNFT.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/cache/SPNFT.s.sol/11155111/run-latest.json
```
