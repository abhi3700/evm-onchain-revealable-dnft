## Overview

The project is a dynamic onchain NFT collection based on ERC721. This allows an operator (admin/deployer) to mint tokens by purchasing in ETH.

When token is minted to an address, the address can reveal the token at any point of time via two reveal methods:

1. **In-collection approach**: Here, the token is revealed by the owner of the token by calling the `revealToken()` function on the contract. This function will reveal the token and set its metadata based on traits set via randomization using chainlink VRF. The token remains with the `SPNFT` collection.
2. **Separate collection approach**: Here, the token is revealed by the owner of the token by calling the `revealToken()` function on the contract. This function will reveal the token and set its metadata based on traits set via randomization using chainlink VRF. The token is minted to the `RevealedSPNFT` collection and burned from the `SPNFT` collection.

Any token holder can stake the tokens and can unstake any time afterwards. During unstake, the token owner would receive some rewards based on the time the token was staked for with 5% APY (annual percentage yield).

Any token holder can't burn token if it's staked.

For security reasons, we have incorporated `Pausable` feature. This allows the operator to pause the contract in case of any emergency. In order to pause/unpause `SPNFT` contract, the deployer can directly pause/unpause it using functions `pause`, `unpause`. But, in order to pause/unpause `RevealedSPNFT` contract, the deployer needs to pause/unpause via `SPNFT` contract using functions: `pauseRevealedSPNFT`, `unpauseRevealedSPNFT`. This is because the owner of `RevealedSPNFT` contract is `SPNFT` contract.
