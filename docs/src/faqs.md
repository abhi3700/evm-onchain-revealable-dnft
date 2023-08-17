# FAQs

#### Q. Should there be revealing feature defined for each token?

**A**.

The revealing feature does not need to be defined for each token individually. Instead, the reveal process is implemented as part of the smart contract, and the operator of the NFT contract can choose between two revealing approaches before the revealing starts:

1. **In-Collection Revealing**: In this approach, the NFT and the revealed NFT reside in the same ERC-721 smart contract. The revealing process switches the NFT's metadata to another set, effectively transforming it into the revealed NFT.

2. **Separate Collection Revealing**: In this approach, the NFT and the revealed NFT are stored in separate ERC-721 smart contracts. When revealing, the system burns the NFT, mints a new NFT in the revealed NFT smart contract, and transfers it to the end user.

The revealing process is designed to be flexible and support future approaches as well. The operator can choose the desired revealing approach, and the end users can initiate the revelation of the metadata corresponding to the tokens they possess.
