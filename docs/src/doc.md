# Documentation

- **Unrevealed NFT metadata** contains all the information about the NFT including the image. Find the metadata [here](../../assets/metadata/Unrevealed.json) which is to be stored in IPFS cloud.
- **Revealed NFT metadata** has to be stored on-chain, not offchain.
- `mint`: here, we mint & set the **name**, **description** of the NFT
- `reveal`: here, we define the image svg using random traits (stored onchain) & set the **attributes** of the NFT. Also based on reveal type 2, we need to burn & mint.
- `tokenUri`: here, we return the metadata of the NFT in base64 encoded format
  - `_getUnrevealedMetadataWEncoding`: returns the unrevealed metadata in base64 encoded format
    - `getSvg()`: returns the SVG based on reveal type
  - `_getRevealedMetadataWEncoding`: returns the revealed metadata in base64 encoded format for type 1.
    - `getSvg()`: returns the SVG based on reveal type
