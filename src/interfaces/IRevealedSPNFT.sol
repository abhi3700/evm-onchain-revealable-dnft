// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC721Metadata} from "./IERC721.sol";
import {INFTStaking} from "./INFTStaking.sol";

/// @notice Interface for RevealedSPNFT
interface IRevealedSPNFT is IERC721Metadata, INFTStaking {
    function totalDepositedETH() external view returns (uint256);
    function tokenIds() external view returns (uint256);
    function owner() external view returns (address);
    function paused() external view returns (bool);

    function mint(address to, uint256 id, bytes32 _name, bytes32 _description, string[4] memory attributeValues)
        external;
    function stake(uint256 _tokenId) external;
    function unstake(uint256 _tokenId) external;
    function pause() external;
    function unpause() external;
}
