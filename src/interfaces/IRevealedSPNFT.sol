// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC721Metadata} from "forge-std/interfaces/IERC721.sol";

/// @notice Interface for RevealedSPNFT
interface IRevealedSPNFT is IERC721Metadata {
    function totalDepositedETH() external view returns (uint256);
    function owner() external view returns (address);
    function mint(address to, uint256 id, bytes32 _name, bytes32 _description, string[4] memory attributeValues)
        external;
    function stake(uint256 _tokenId) external;
    function unstake(uint256 _tokenId) external;
}
