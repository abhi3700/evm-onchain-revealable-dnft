// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ISPNFT {
    // function revealedSPNFT() external view returns ()
    function tokenURI(uint256 id) external view returns (string memory);
    function mint(address to, bytes32 _name, bytes32 _description) external;
    function burn(uint256 id) external;
    function revealToken(uint8 _revealType, uint256 id) external;
    function stake(uint256 _tokenId) external;
    function unstake(uint256 _tokenId) external;
}
