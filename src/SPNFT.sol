// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {LibString} from "solmate/utils/LibString.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";

import {IRevealedSPNFT} from "./interfaces/IRevealedSPNFT.sol";
import {console2} from "forge-std/Test.sol";

contract SPNFT is ERC721, Owned, ReentrancyGuard {
    using LibString for uint256;

    // no. of tokens minted so far
    // NOTE: burnt NFTs doesn't decrement this no.
    uint256 public tokenIds;

    mapping(uint256 => uint8) public revealedTypes;

    IRevealedSPNFT public revealedSPNFT;

    // required for setting during deployment
    string private revealedBaseUri1;
    // metadata i.e. token uri (containing image url) for unrevealed asset (shown by default).
    string public constant UNREVEALED_URI =
        "https://white-chilly-koi-665.mypinata.cloud/ipfs/QmVzu86nv6wUbUgFxBdeQt9954yf4Ty8eFdYPfA5Cu1M8o/mystery_box.json";

    event Minted(address indexed caller, address indexed to, uint256 indexed tokenId);
    event Burned(address indexed holder, uint256 indexed tokenId);

    error EmptyBaseURI();
    error NotOwner(address);
    error InvalidToken(uint256); // Invalid Token ID
    error AlreadyRevealed();
    error InvalidRevealType();
    error InvalidRSPNFTAddress(address);

    /// @param _uri common base URI for the entire collection set during deployment
    constructor(address rSPNFTAddress, string memory _n, string memory _s, bytes memory _uri)
        ERC721(_n, _s)
        Owned(msg.sender)
    {
        // check for empty base Uri
        if (keccak256(_uri) == keccak256(bytes(""))) {
            revert EmptyBaseURI();
        }

        // check if contract
        uint256 size;
        assembly {
            size := extcodesize(rSPNFTAddress)
        }
        if (size == 0) {
            revert InvalidRSPNFTAddress(rSPNFTAddress);
        }

        revealedBaseUri1 = string(_uri);
        revealedSPNFT = IRevealedSPNFT(rSPNFTAddress);
    }

    /// @dev tokenURI returns the metadata
    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        // token exists
        ownerOf(id);

        uint8 _revealedType = revealedTypes[id];

        // revealed type is 0 i.e. not revealed yet
        if (_revealedType == 0) {
            // give the notRevealUrl
            return UNREVEALED_URI;
        }
        // revealed type is 1
        else if (_revealedType == 1) {
            // give the revealed Url for the token id
            return string(abi.encodePacked(revealedBaseUri1, id.toString()));
        }
        // revealed type is 2
        else {
            // TODO: Verify
            return revealedSPNFT.tokenURI(id);
        }
    }

    function mint(address to, uint256 id) external onlyOwner {
        _mint(to, id);
        ++tokenIds;
        emit Minted(msg.sender, to, id);
    }

    function burn(uint256 id) external {
        if (msg.sender != ownerOf(id)) {
            revert NotOwner(msg.sender);
        }
        _burn(id);

        emit Burned(msg.sender, id);
    }

    /// @dev reveal collection is possible only once, by current token owner .
    ///     There could be a case where the 1st owner didn't reveal and transferred as is
    ///     to the 2nd owner. Now, 2nd owner decides to reveal it with 1/2 type.
    /// @param id token id
    /// @param revealType reveal type
    function revealToken(uint256 id, uint8 revealType) external nonReentrant {
        // token exists
        address owner = ownerOf(id);

        uint8 _revealedType = revealedTypes[id];

        // check if token already revealed
        if (_revealedType != 0) {
            revert AlreadyRevealed();
        }

        // revealType == 1 || 2
        if (revealType == 1 || revealType == 2) {
            revealedTypes[id] = revealType;

            // TODO: Verify
            // if revealType == 2, then burn the token &
            // mint into "RevealedSPNFT" contract
            // with same owner
            if (revealType == 2) {
                // burn from current contract
                this.burn(id);

                // mint to `msg.sender` (original owner) into `RevealedSPNFT` contract
                revealedSPNFT.mint(owner, id);
            }
        } else {
            revert InvalidRevealType();
        }
    }
}
