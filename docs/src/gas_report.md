## Gas Report

**`SPNFTTest` locally**:

```sh
❯ forge test --mc SPNFTTest --gas-report                                                                                                                                 ⏎
[⠢] Compiling...
No files changed, compilation skipped

Running 24 tests for test/SPNFT.t.sol:SPNFTTest
[PASS] testBurnAfterMint() (gas: 136450)
[PASS] testBurnRevertsAfterStaked() (gas: 979)
[PASS] testGetName() (gas: 9901)
[PASS] testGetSymbol() (gas: 10040)
[PASS] testGetTokenIDsMinted() (gas: 162419)
[PASS] testGetTokenURI() (gas: 262796)
[PASS] testGetTotalDepositedETH() (gas: 7768)
[PASS] testMintToAnyonePayingETH(address,bytes32,bytes32) (runs: 256, μ: 171233, ~: 171233)
[PASS] testRevertGetTokenUriOfNonMinted() (gas: 13512)
[PASS] testRevertMintInsufficientETH(address) (runs: 256, μ: 18637, ~: 18637)
[PASS] testRevertMintToZeroAddress() (gas: 18029)
[PASS] testRevertMintTokenWEmptyDescription() (gas: 18372)
[PASS] testRevertMintTokenWEmptyName() (gas: 18424)
[PASS] testRevertNonAdminMintToAnyonePayingETH(address) (runs: 256, μ: 19769, ~: 19769)
[PASS] testRevertOthersBurnAfterMintedToAlice(address) (runs: 256, μ: 166877, ~: 166877)
[PASS] testSetUpEmptyAttributeOptionsEyes() (gas: 209584)
[PASS] testSetUpEmptyAttributeOptionsFace() (gas: 212570)
[PASS] testSetUpEmptyAttributeOptionsHair() (gas: 211899)
[PASS] testSetUpEmptyAttributeOptionsMouth() (gas: 215024)
[PASS] testSetUpEmptyName() (gas: 189053)
[PASS] testSetUpEmptySymbol() (gas: 188875)
[PASS] testSetUpInvalidTokenAddress() (gas: 206950)
[PASS] testStake() (gas: 385)
[PASS] testUnstake() (gas: 933)
Test result: ok. 24 passed; 0 failed; 0 skipped; finished in 33.40ms
| src/SPNFT.sol:SPNFT contract |                 |       |        |        |         |
|------------------------------|-----------------|-------|--------|--------|---------|
| Deployment Cost              | Deployment Size |       |        |        |         |
| 6635109                      | 36068           |       |        |        |         |
| Function Name                | min             | avg   | median | max    | # calls |
| burn                         | 692             | 4102  | 4102   | 7512   | 2       |
| mint                         | 2910            | 75718 | 74936  | 148903 | 10      |
| name                         | 2981            | 2981  | 2981   | 2981   | 1       |
| revealedSPNFT                | 418             | 418   | 418    | 418    | 24      |
| symbol                       | 3377            | 3377  | 3377   | 3377   | 1       |
| tokenIds                     | 526             | 1192  | 526    | 2526   | 3       |
| tokenURI                     | 3095            | 46863 | 46863  | 90631  | 2       |
| totalDepositedETH            | 592             | 1592  | 1592   | 2592   | 2       |


| src/SPToken.sol:SPToken contract |                 |       |        |       |         |
|----------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                  | Deployment Size |       |        |       |         |
| 731671                           | 4805            |       |        |       |         |
| Function Name                    | min             | avg   | median | max   | # calls |
| balanceOf                        | 590             | 590   | 590    | 590   | 72      |
| transfer                         | 24819           | 24819 | 24819  | 24819 | 48      |


| test/SPNFT.t.sol:SPNFTTest contract |                 |     |        |     |         |
|-------------------------------------|-----------------|-----|--------|-----|---------|
| Deployment Cost                     | Deployment Size |     |        |     |         |
| 45626497                            | 227258          |     |        |     |         |
| Function Name                       | min             | avg | median | max | # calls |
| receive                             | 75              | 75  | 75     | 75  | 5       |



Ran 1 test suites: 24 tests passed, 0 failed, 0 skipped (24 total tests)
```
