// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {LibString} from "solmate/utils/LibString.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {console2} from "forge-std/Test.sol";

/// @title Revealed SP NFT contract
/// @notice For "Separate Collection Revealing" approach.
contract RevealedSPNFT is ERC721, Owned {
    using LibString for uint256;

    // required for setting during deployment
    string public baseURI;

    event Minted(address indexed caller, address indexed to, uint256 indexed tokenId);
    event Burned(address indexed holder, uint256 indexed tokenId);

    error EmptyBaseURI();
    error NotOwner(address);
    error InvalidToken(uint256); // Invalid Token ID

    /// _uri common base URI for the entire collection set during deployment
    constructor(string memory _n, string memory _s, bytes memory _uri) ERC721(_n, _s) Owned(msg.sender) {
        if (keccak256(_uri) == keccak256(bytes(""))) {
            revert EmptyBaseURI();
        }
        baseURI = string(_uri);
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        ownerOf(id);
        return string(abi.encodePacked(baseURI, id.toString()));
    }

    function mint(address to, uint256 id) internal {
        _mint(to, id);
        emit Minted(msg.sender, to, id);
    }

    function burn(uint256 id) internal {
        if (msg.sender != ownerOf(id)) {
            revert NotOwner(msg.sender);
        }
        _burn(id);

        emit Burned(msg.sender, id);
    }
}
