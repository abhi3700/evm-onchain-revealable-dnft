## Architecture

**Deployment of the project is done in 5 steps**:

1. Deploy `token` contract.
2. Deploy `SPNFT` contract.
   > `RevealedSPNFT` contract is deployed by `SPNFT` contract.
3. Transfer some tokens to `SPNFT` contract for stake rewards.
4. Transfer some tokens to `RevealedSPNFT` contract for stake rewards.
5. Add `SPNFT` contract as consumer in `VRFCoordinatorV2` contract.
   > NOT considered as deployment script because it exceeded deployment gas limit (~800,000 unit). So, needs to be done externally from [here](https://vrf.chain.link/sepolia/4562).

So, actually [1], [2], [3], [4].

Here is the diagram:

```mermaid
sequenceDiagram
    actor A as Operator
    participant B as SPToken
    participant C as SPNFT
    participant D as RevealedSPNFT
    participant E as VRFCoordinatorV2
    A->>B: 1. Deploy
    A->>C: 2. Deploy
    C->>D: 2a. Deploy
    A->>+B: 3. call transfer
    B->>-C: 3a. transfer
    A->>+B: 4. call transfer
    B->>-D: 4a. Transfer
    A->>E: 5. Add SPNFT as Consumer
```

---

**User workflow**:

- Mint token to an address in `SPNFT` contract.
- Reveal token in `SPNFT` contract.
- Stake token in `SPNFT` contract.
- Unstake token in `SPNFT` contract.
- Burn token in `SPNFT` contract.
- Pause/Unpause `SPNFT` contract.
- Pause/Unpause `RevealedSPNFT` contract.
- Mint token to an address in `RevealedSPNFT` contract.
- Stake token in `RevealedSPNFT` contract.
- Unstake token in `RevealedSPNFT` contract.
- Burn token in `RevealedSPNFT` contract.
- Pause/Unpause `RevealedSPNFT` contract.
- Get token details in `SPNFT` contract.
- Get token details in `RevealedSPNFT` contract.
- Get token details in `SPToken` contract.

```mermaid
sequenceDiagram
    actor A as Operator(Admin)
    actor F as User
    actor A/F as Operator/User
    participant B as SPToken
    participant C as SPNFT
    participant E as Oracle
    participant D as RevealedSPNFT
    A->>+B: Mint some tokens to itself
    B->>-A: Minted
    A->>+B: Mint some tokens to SPNFT for stake rewards
    B->>-C: Minted
    A->>+B: Mint some tokens to Revealed SPNFT for stake rewards
    B->>-D: Minted
    A->>+C: Mint token to User
    C->>-F: Minted
    F->>+C: Reveal token
    C->>+E: Request RNG to Oracle
    E->>-C: RNG response to contract, then set the traits of token (type 1 or 2) based on RNG value
    C->>C: Burn tokens if reveal type is separate-collection
    C->>D: Mint token with same token id
    F->>C: Stake if revealed type is in-collection
    F->>C: Unstake
    F->>C: Burn
    A->>C: Pause
    A->>C: Unpause
    F->>D: Stake if revealed type is separate-collection
    F->>D: Unstake
    F->>D: Burn
    A->>+C: Pause
    C->>-D: Pause
    A->>+C: Unpause
    C->>-D: Unpause
    A/F->>B: Get token details like name, symbol, total Supply
    A/F->>C: Get token details like name, symbol, token owners, balances
    A/F->>D: Get token details like name, symbol, token owners, balances
```

---

**Main functions in `SPNFT` contract**:

```mermaid
graph TB
    subgraph SPNFT
        subgraph Setters
            mint
            burn
            revealToken
            stake
            unstake
            pause
            unpause
            pauseRevealedSPNFT
            unpauseRevealedSPNFT
        end
        subgraph Getters
            name
            symbol
            tokenURI
            metadata
            tokenIds
            stakedTokenIds
            getTokenIdStatus
            totalDepositedETH
            owner
            paused
        end
    end

```

---

**Main functions in `RevealedSPNFT` contract**:

```mermaid
graph TB
    subgraph RevealedSPNFT
        subgraph Setters
            mint
            burn
            stake
            unstake
            pause
            unpause
        end
        subgraph Getters
            name
            symbol
            tokenURI
            tokenIds
            stakedTokenIds
            getTokenIdStatus
            totalDepositedETH
            owner
            paused
        end
    end
```
