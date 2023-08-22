## Deployment

Just run this command to deploy the contracts to the network.

> Additionally, operator has to also add consumer to VRF coordinator contract.

```sh
❯ forge script script/SPNFT.s.sol:SPNFTScript --rpc-url $SEPOLIA_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY --broadcast --verify
[⠢] Compiling...
No files changed, compilation skipped
Script ran successfully.

== Logs ==
  SPToken (ERC20) token deployed at:  0x54b9BBC05B8C17605A8F4c2103c2110D40fC4633
  SPNFT contract deployed at:  0x656f451B8db56D8372175E954A500fA1ea9112f5
  RSPNFT contract deployed at:  0xfB9c87f79Be4dca6Fa81F12fDD1c711eef33884D
  The SPNFT's balance:  10000000000000000000000
  The SPNFT's balance:  10000000000000000000000

## Setting up (1) EVMs.

==========================

Chain 11155111

Estimated gas price: 13.261048226 gwei

Estimated total gas used for script: 10897817

Estimated amount required: 0.144516476795122642 ETH

==========================

###
Finding wallets for all the necessary addresses...
##
Sending transactions [0 - 3].
⠚ [00:00:00] [#######################################################################################################################] 4/4 txes (0.0s)
Transactions saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/broadcast/SPNFT.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/cache/SPNFT.s.sol/11155111/run-latest.json

##
Waiting for receipts.
⠒ [00:00:07] [###################################################################################################################] 4/4 receipts (0.0s)
##### sepolia
✅  [Success]Hash: 0x0dee1b147f01dca12ceb5a22d3ee27b44802fdaedcc4adbac944d09f970fe317
Contract Address: 0x54b9BBC05B8C17605A8F4c2103c2110D40fC4633
Block: 4138592
Paid: 0.008369102353151122 ETH (881854 gas * 9.490349143 gwei)


##### sepolia
✅  [Success]Hash: 0xdc57fa98356aaab0b040c314a3e84b95625131dcb5800f23b2acd68794a1d771
Contract Address: 0x656f451B8db56D8372175E954A500fA1ea9112f5
Block: 4138592
Paid: 0.070125366620920732 ETH (7389124 gas * 9.490349143 gwei)


##### sepolia
✅  [Success]Hash: 0x4d83ae6b4da78cdb0e7a170d1333d86bc0735bd92069b2eedb1e72a1b0b9be5a
Block: 4138592
Paid: 0.000486826439988471 ETH (51297 gas * 9.490349143 gwei)


##### sepolia
✅  [Success]Hash: 0x40d22afd74993c0ab0e62cca387d0841679e9f15851bc73720e7fd378be3b696
Block: 4138592
Paid: 0.000486826439988471 ETH (51297 gas * 9.490349143 gwei)


Transactions saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/broadcast/SPNFT.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/abhi3700/F/coding/github_repos/sp_coding_challenge/cache/SPNFT.s.sol/11155111/run-latest.json



==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
Total Paid: 0.079468121854048796 ETH (8373572 gas * avg 9.490349143 gwei)
##
Start verification for (3) contracts
Start verifying contract `0x54b9bbc05b8c17605a8f4c2103c2110d40fc4633` deployed on sepolia

Submitting verification for [src/SPToken.sol:SPToken] "0x54b9BBC05B8C17605A8F4c2103c2110D40fC4633".

Submitting verification for [src/SPToken.sol:SPToken] "0x54b9BBC05B8C17605A8F4c2103c2110D40fC4633".

Submitting verification for [src/SPToken.sol:SPToken] "0x54b9BBC05B8C17605A8F4c2103c2110D40fC4633".
Submitted contract for verification:
        Response: `OK`
        GUID: `6ttdw2puajlr2a4kvvaxusnq8lgyv3ex4yeb6fwnbvcntcjxit`
        URL:
        https://sepolia.etherscan.io/address/0x54b9bbc05b8c17605a8f4c2103c2110d40fc4633
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
Start verifying contract `0x656f451b8db56d8372175e954a500fa1ea9112f5` deployed on sepolia

Submitting verification for [src/SPNFT.sol:SPNFT] "0x656f451B8db56D8372175E954A500fA1ea9112f5".
Submitted contract for verification:
        Response: `OK`
        GUID: `ntruzd5d5akrz86nnwwtefrnwqg1nw2aptfky9yr6ubk2jxuie`
        URL:
        https://sepolia.etherscan.io/address/0x656f451b8db56d8372175e954a500fa1ea9112f5
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
Start verifying contract `0xfb9c87f79be4dca6fa81f12fdd1c711eef33884d` deployed on sepolia

Submitting verification for [src/RevealedSPNFT.sol:RevealedSPNFT] "0xfB9c87f79Be4dca6Fa81F12fDD1c711eef33884D".
Submitted contract for verification:
        Response: `OK`
        GUID: `pfbqp8ucyaw5f98b2xtkfexvnbe6mctmii7mzzeyhwbpu1dtcr`
        URL:
        https://sepolia.etherscan.io/address/0xfb9c87f79be4dca6fa81f12fdd1c711eef33884d
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
