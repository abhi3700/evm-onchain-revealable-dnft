// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC721Metadata} from "./IERC721.sol";
import {INFTStaking} from "./INFTStaking.sol";

interface ISPNFT is IERC721Metadata, INFTStaking {
    // NFT metadata
    struct Metadata {
        uint8 revealType;
        bytes32 name;
        bytes32 description;
        // string image;    // it is to be generated during revealing randomizing traits' values options (colors).
        string[4] attributeValues;
    }

    function metadata(uint256 tokenId) external view returns (Metadata memory);
    function totalDepositedETH() external view returns (uint256);
    function tokenIds() external view returns (uint256);
    function owner() external view returns (address);
    function mint(address to, bytes32 _name, bytes32 _description) external payable;
    function burn(uint256 id) external;
    function revealToken(uint8 _revealType, uint256 id) external;
    function stake(uint256 _tokenId) external;
    function unstake(uint256 _tokenId) external;
}
