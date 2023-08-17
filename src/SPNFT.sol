// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Owned} from "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import {console2} from "forge-std/Test.sol";

contract SPNFT is ERC721, Owned {
    using Strings for uint256;

    mapping(uint256 => uint8) private revealedTypes;

    // required for setting during deployment
    string private revealedBaseUrl1;
    // metadata (containing image url) for not unrevealed asset (shown by default).
    string public unrevealedUrl =
        "https://white-chilly-koi-665.mypinata.cloud/ipfs/QmVzu86nv6wUbUgFxBdeQt9954yf4Ty8eFdYPfA5Cu1M8o/mystery_box.json";

    event Minted(address indexed caller, address indexed to, uint256 indexed tokenId);
    event Burned(address indexed holder, uint256 indexed tokenId);

    error EmptyBaseURI();
    error NotOwner(address);
    error InvalidToken(uint256); // Invalid Token ID
    error AlreadyRevealed();
    error InvalidRevealType();

    /// @param _uri common base URI for the entire collection set during deployment
    constructor(string memory _n, string memory _s, bytes memory _uri) ERC721(_n, _s) Owned(msg.sender) {
        if (keccak256(_uri) == keccak256(bytes(""))) {
            revert EmptyBaseURI();
        }
        revealedBaseUrl1 = string(_uri);
    }

    /// @dev reveal collection at once
    function revealToken(uint256 id, uint8 revealType) external {
        // token exists
        ownerOf(id);

        uint8 _revealedType = revealedTypes[id];

        // check if token already revealed
        if (_revealedType != 0) {
            revert AlreadyRevealed();
        }

        // ensure revealType == 1 || 2
        if (revealType == 1 || revealType == 2) {
            revealedTypes[id] = revealType;
        } else {
            revert InvalidRevealType();
        }
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        // token exists
        ownerOf(id);

        uint8 _revealedType = revealedTypes[id];

        // revealed type is 0 i.e. not revealed yet
        if (_revealedType == 0) {
            // give the notRevealUrl
            return unrevealedUrl;
        }
        // revealed type is 1
        else if (_revealedType == 1) {
            // give the revealed Url for the token id
            return string(abi.encodePacked(revealedBaseUrl1, id.toString()));
        }
        // revealed type is 2
        else {
            // TODO:
            return string(abi.encodePacked(revealedBaseUrl1, id.toString()));
        }
    }

    function mint(address to, uint256 id) external onlyOwner {
        _mint(to, id);
        emit Minted(msg.sender, to, id);
    }

    function burn(uint256 id) external {
        if (msg.sender != ownerOf(id)) {
            revert NotOwner(msg.sender);
        }
        _burn(id);

        emit Burned(msg.sender, id);
    }
}
