// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @notice Interface for RevealedSPNFT
interface IRevealedSPNFT {
    function tokenURI(uint256 id) external view returns (string memory);
    function mint(address to, uint256 id, bytes32 _name, bytes32 _description, bytes8[4] memory attributeValues)
        external;
    function burn(uint256 id) external;
}
