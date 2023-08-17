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

    // metadata
    struct Metadata {
        string name;
        string description;
        string image;
        string[4] attributeValues;
    }

    mapping(uint256 => Metadata) private metadata;

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
    error EmptyName();
    error EmptyImage();
    error AttributeValuesMustBeFourAndNonEmpty();
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
            // give the unrevealed uri
            return UNREVEALED_URI;
        }
        // revealed type is 1
        else if (_revealedType == 1) {
            Metadata memory mdata = metadata[id];

            // TODO: return the decoded onchain metadata
            string memory json = Base64.encode(
                bytes(
                    string(
                        abi.encodePacked(
                            '{"name": "',
                            mdata.name,
                            '",',
                            '"description":"',
                            mdata.description,
                            '"image": "',
                            getSvg(tokenId),
                            '",',
                            '"attributes": [{"trait_type": "Eyes", "value": ',
                            mdata.attributeValues[0],
                            "},",
                            '{"trait_type": "Hair", "value": ',
                            mdata.attributeValues[1],
                            "},",
                            '{"trait_type": "Nose", "value": ',
                            mdata.attributeValues[2],
                            "},",
                            '{"trait_type": "Mouth", "value": "',
                            mdata.attributeValues[3],
                            '"}',
                            "]}"
                        )
                    )
                )
            );
            return string(abi.encodePacked("data:application/json;base64,", json));
        }
        // revealed type is 2
        else {
            // TODO: Verify
            return revealedSPNFT.tokenURI(id);
        }
    }

    function mint(
        address to,
        uint256 id,
        string memory _name,
        string memory _description,
        string memory _image,
        string[4] memory _attributeValues
    ) external onlyOwner {
        if (_name == "") {
            revert EmptyName();
        }

        // description is OPTIONAL

        if (_image == "") {
            revert EmptyImage();
        }
        if (
            _attributeValues.length != 4 || _attributeValues[0] != "" || _attributeValues[1] != ""
                || _attributeValues[2] != "" || _attributeValues[3] != ""
        ) {
            revert AttributeValuesMustBeFourAndNonEmpty();
        }

        Metadata storage mdata = metadata[id];

        // TODO: encode each or only image
        mdata.name = _name;
        mdata.description = _description;
        mdata.image = _image;
        mdata.attributeValues = _attributeValues;

        ++tokenIds;

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

            // TODO: Verify & also check for onchain storage in another contract
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

    function _getSvg(uint256 tokenId) private view returns (string memory svg) {
        // TODO: it should be decoded
        // svg = decode(metadata[id].image)
        svg =
            "<svg width='350px' height='350px' viewBox='0 0 24 24' fill='none' xmlns='http://www.w3.org/2000/svg'> <path d='M11.55 18.46C11.3516 18.4577 11.1617 18.3789 11.02 18.24L5.32001 12.53C5.19492 12.3935 5.12553 12.2151 5.12553 12.03C5.12553 11.8449 5.19492 11.6665 5.32001 11.53L13.71 3C13.8505 2.85931 14.0412 2.78017 14.24 2.78H19.99C20.1863 2.78 20.3745 2.85796 20.5133 2.99674C20.652 3.13552 20.73 3.32374 20.73 3.52L20.8 9.2C20.8003 9.40188 20.7213 9.5958 20.58 9.74L12.07 18.25C11.9282 18.3812 11.7432 18.4559 11.55 18.46ZM6.90001 12L11.55 16.64L19.3 8.89L19.25 4.27H14.56L6.90001 12Z' fill='red'/> <path d='M14.35 21.25C14.2512 21.2522 14.153 21.2338 14.0618 21.1959C13.9705 21.158 13.8882 21.1015 13.82 21.03L2.52 9.73999C2.38752 9.59782 2.3154 9.40977 2.31883 9.21547C2.32226 9.02117 2.40097 8.83578 2.53838 8.69837C2.67579 8.56096 2.86118 8.48224 3.05548 8.47882C3.24978 8.47539 3.43783 8.54751 3.58 8.67999L14.88 20C15.0205 20.1406 15.0993 20.3312 15.0993 20.53C15.0993 20.7287 15.0205 20.9194 14.88 21.06C14.7353 21.1907 14.5448 21.259 14.35 21.25Z' fill='red'/> <path d='M6.5 21.19C6.31632 21.1867 6.13951 21.1195 6 21L2.55 17.55C2.47884 17.4774 2.42276 17.3914 2.385 17.297C2.34724 17.2026 2.32855 17.1017 2.33 17C2.33 16.59 2.33 16.58 6.45 12.58C6.59063 12.4395 6.78125 12.3607 6.98 12.3607C7.17876 12.3607 7.36938 12.4395 7.51 12.58C7.65046 12.7206 7.72934 12.9112 7.72934 13.11C7.72934 13.3087 7.65046 13.4994 7.51 13.64C6.22001 14.91 4.82 16.29 4.12 17L6.5 19.38L9.86 16C9.92895 15.9292 10.0114 15.873 10.1024 15.8346C10.1934 15.7962 10.2912 15.7764 10.39 15.7764C10.4888 15.7764 10.5866 15.7962 10.6776 15.8346C10.7686 15.873 10.8511 15.9292 10.92 16C11.0605 16.1406 11.1393 16.3312 11.1393 16.53C11.1393 16.7287 11.0605 16.9194 10.92 17.06L7 21C6.8614 21.121 6.68402 21.1884 6.5 21.19Z' fill='red'/> </svg>";
    }
}
