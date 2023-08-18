// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {LibString} from "solmate/utils/LibString.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {LibBase64} from "./libs/LibBase64.sol";

import {IRevealedSPNFT} from "./interfaces/IRevealedSPNFT.sol";
import {console2} from "forge-std/Test.sol";

contract SPNFT is ERC721, Owned, ReentrancyGuard {
    using LibString for uint256;

    // ===================== STORAGE ===========================
    // metadata
    struct Metadata {
        bytes32 name;
        bytes32 description;
        // string image;    // it is to be generated during revealing randomizing traits' values options (colors).
        bytes8[4] attributeValues;
    }

    // attribute options
    struct AttributeOptions {
        bytes8[4] eyes;
        bytes8[4] hair;
        bytes8[4] face;
        bytes8[4] mouth;
    }

    AttributeOptions private _attributeOptions;

    mapping(uint256 => Metadata) private _metadata;

    // no. of tokens minted so far
    // NOTE: burnt NFTs doesn't decrement this no.
    uint256 public tokenIds;

    mapping(uint256 => uint8) public revealedTypes;

    IRevealedSPNFT public revealedSPNFT;

    // ===================== EVENT ===========================
    event Minted(address indexed caller, address indexed to, uint256 indexed tokenId);
    event Burned(address indexed holder, uint256 indexed tokenId);

    // ===================== ERROR ===========================
    error EmptyName();
    error AttributeOptionsMustBeFourAndNonEmptyElements();
    error NotOwner(address);
    error AlreadyRevealed();
    error InvalidRevealType();
    error InvalidRSPNFTAddress(address);

    // ===================== CONSTRUCTOR ===========================
    constructor(address rSPNFTAddress, string memory _n, string memory _s, AttributeOptions memory _aOptions)
        ERC721(_n, _s)
        Owned(msg.sender)
    {
        // check if contract
        uint256 size;
        assembly {
            size := extcodesize(rSPNFTAddress)
        }
        if (size == 0) {
            revert InvalidRSPNFTAddress(rSPNFTAddress);
        }

        // sanitize attribute options
        // length of each attribute options - eyes, hair, nose, mouth would be 4 for sure as declared above.
        if (
            !(
                !_isBytes8ArrayElementEmpty(_aOptions.eyes) && !_isBytes8ArrayElementEmpty(_aOptions.hair)
                    && !_isBytes8ArrayElementEmpty(_aOptions.face) && !_isBytes8ArrayElementEmpty(_aOptions.mouth)
            )
        ) {
            revert AttributeOptionsMustBeFourAndNonEmptyElements();
        }

        _attributeOptions = _aOptions;

        revealedSPNFT = IRevealedSPNFT(rSPNFTAddress);
    }

    // ===================== Getters ===========================

    /// @dev tokenURI returns the metadata
    // function tokenURI(uint256 id) public view virtual override returns (string memory) {}

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        // token exists
        ownerOf(id);

        uint8 _revealedType = revealedTypes[id];

        // revealed type is 0 i.e. not revealed yet
        if (_revealedType == 0) {
            // return _getUnrevealedMetadataWoEncoding(id);
            return _getUnrevealedMetadataWEncoding(id);
        }
        // revealed type is 1
        else if (_revealedType == 1) {
            Metadata memory mdata = _metadata[id];

            // TODO: return the decoded onchain metadata
            string memory json = LibBase64.encode(
                bytes(
                    string(
                        abi.encodePacked(
                            '{"name": "',
                            mdata.name,
                            '",',
                            '"description":"',
                            mdata.description,
                            '"image": "',
                            _getSvg(id),
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
            // TODO: add onchain data
            return revealedSPNFT.tokenURI(id);
        }
    }

    /// @dev Only Owner can
    ///     - mint token
    ///     - set name, description of the NFT
    function mint(address to, uint256 id, bytes32 _name, bytes32 _description) external onlyOwner {
        if (_name.length == 0) {
            revert EmptyName();
        }

        // description is OPTIONAL

        Metadata storage mdata = _metadata[id];

        // TODO: encode each or only image
        mdata.name = _name;
        mdata.description = _description;

        ++tokenIds;

        _mint(to, id);

        emit Minted(msg.sender, to, id);
    }

    /// @dev NFT asset holder can burn any token
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

            // TODO: randomize traits values using chainlink & set the attributes for the token id
            // (string eye, string hair, string face, string mouth) = requestRandomTraits()
            // Metadata storage mdata = _metadata[id];
            // mdata.attributeValues[0] = eye;
            // mdata.attributeValues[1] = hair;
            // mdata.attributeValues[2] = face;
            // mdata.attributeValues[3] = mouth;

            // TODO: Verify & also check for onchain storage in another contract
            // if revealType == 2, then burn the token &
            // mint into "RevealedSPNFT" contract
            // with same owner
            if (revealType == 2) {
                // burn from current contract
                this.burn(id);

                // mint to `msg.sender` (original owner) into `RevealedSPNFT` contract
                revealedSPNFT.mint(owner, id);

                // TODO: transfer the metadata as well.
            }
        } else {
            revert InvalidRevealType();
        }
    }

    function _getSvg(uint256 tokenId) private view returns (string memory svg) {
        uint8 _revealedType = revealedTypes[tokenId];

        // revealed type is 0 i.e. not revealed yet
        if (_revealedType == 0) {
            // give the unrevealed uri
            svg =
                '<svg width="800px" height="800px" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" fill="#F48024" stroke="#000000" stroke-width="1" stroke-linecap="round" stroke-linejoin="miter"><polygon points="3 16 3 8 12 14 21 8 21 16 12 22 3 16" stroke-width="0" opacity="0.1" fill="#059cf7"></polygon><polygon points="21 8 21 16 12 22 3 16 3 8 12 2 21 8"></polygon><polyline points="3 8 12 14 12 22" stroke-linecap="round"></polyline><line x1="21" y1="8" x2="12" y2="14" stroke-linecap="round"></line></svg>';
        }
        // in case of type = 1, 2
        else {
            Metadata memory mdata = _metadata[tokenId];

            svg = string(
                abi.encodePacked(
                    '<svg viewBox="0 0 58 58" style="enable-background:new 0 0 58 58;" xml:space="preserve"><g><path style="fill:',
                    mdata.attributeValues[2],
                    ';" d="M29.392,54.999c11.246,0.156,17.52-4.381,21.008-9.189c3.603-4.966,4.764-11.283,3.647-17.323 C50.004,6.642,29.392,6.827,29.392,6.827S8.781,6.642,4.738,28.488c-1.118,6.04,0.044,12.356,3.647,17.323 C11.872,50.618,18.146,55.155,29.392,54.999z"/><path style="fill:#F9A671;" d="M4.499,30.125c-0.453-0.429-0.985-0.687-1.559-0.687C1.316,29.438,0,31.419,0,33.862 c0,2.443,1.316,4.424,2.939,4.424c0.687,0,1.311-0.37,1.811-0.964C4.297,34.97,4.218,32.538,4.499,30.125z"/><path style="fill:#F9A671;" d="M57.823,26.298c-0.563-2.377-2.3-3.999-3.879-3.622c-0.491,0.117-0.898,0.43-1.225,0.855 c0.538,1.515,0.994,3.154,1.328,4.957c0.155,0.837,0.261,1.679,0.328,2.522c0.52,0.284,1.072,0.402,1.608,0.274 C57.562,30.908,58.386,28.675,57.823,26.298z"/><path style="fill:',
                    mdata.attributeValues[1],
                    ';" d="M13.9,16.998c-0.256,0-0.512-0.098-0.707-0.293l-5-5c-0.391-0.391-0.391-1.023,0-1.414 s1.023-0.391,1.414,0l5,5c0.391,0.391,0.391,1.023,0,1.414C14.412,16.901,14.156,16.998,13.9,16.998z"/><path style="fill:',
                    mdata.attributeValues[1],
                    ';" d="M16.901,13.998c-0.367,0-0.72-0.202-0.896-0.553l-3-6c-0.247-0.494-0.047-1.095,0.447-1.342 c0.495-0.245,1.094-0.047,1.342,0.447l3,6c0.247,0.494,0.047,1.095-0.447,1.342C17.204,13.964,17.052,13.998,16.901,13.998z"/><path style="fill:',
                    mdata.attributeValues[1],
                    ';" d="M20.9,11.998c-0.419,0-0.809-0.265-0.948-0.684l-2-6c-0.175-0.524,0.108-1.091,0.632-1.265 c0.527-0.176,1.091,0.108,1.265,0.632l2,6c0.175,0.524-0.108,1.091-0.632,1.265C21.111,11.982,21.005,11.998,20.9,11.998z"/><path style="fill:',
                    mdata.attributeValues[1],
                    ';" d="M25.899,10.998c-0.48,0-0.904-0.347-0.985-0.836l-1-6c-0.091-0.544,0.277-1.06,0.822-1.15 c0.543-0.098,1.061,0.277,1.15,0.822l1,6c0.091,0.544-0.277,1.06-0.822,1.15C26.009,10.995,25.954,10.998,25.899,10.998z"/><path style="fill:',
                    mdata.attributeValues[1],
                    ';" d="M29.9,10.998c-0.553,0-1-0.447-1-1v-6c0-0.553,0.447-1,1-1s1,0.447,1,1v6 C30.9,10.551,30.453,10.998,29.9,10.998z"/><path style="fill:',
                    mdata.attributeValues[1],
                    ';" d="M33.9,10.998c-0.104,0-0.211-0.017-0.316-0.052c-0.523-0.174-0.807-0.74-0.632-1.265l2-6 c0.175-0.523,0.736-0.809,1.265-0.632c0.523,0.174,0.807,0.74,0.632,1.265l-2,6C34.709,10.734,34.319,10.998,33.9,10.998z"/><path style="fill:',
                    mdata.attributeValues[1],
                    ';" d="M37.9,11.998c-0.104,0-0.211-0.017-0.316-0.052c-0.523-0.174-0.807-0.74-0.632-1.265l2-6c0.175-0.523,0.737-0.808,1.265-0.632c0.523,0.174,0.807,0.74,0.632,1.265l-2,6C38.709,11.734,38.319,11.998,37.9,11.998z"/><path style="fill:',
                    mdata.attributeValues[1],
                    ';" d="M40.899,13.998c-0.15,0-0.303-0.034-0.446-0.105c-0.494-0.247-0.694-0.848-0.447-1.342l3-6c0.248-0.494,0.848-0.692,1.342-0.447c0.494,0.247,0.694,0.848,0.447,1.342l-3,6C41.619,13.796,41.267,13.998,40.899,13.998z"/><circle style="fill:#FFFFFF;" cx="22" cy="26.003" r="6"/><circle style="fill:#FFFFFF;" cx="36" cy="26.003" r="8"/><circle style="fill:',
                    mdata.attributeValues[0],
                    ';" cx="22" cy="26.003" r="2"/><circle style="fill:',
                    mdata.attributeValues[0],
                    ';" cx="36" cy="26.003" r="3"/><path style="fill:',
                    mdata.attributeValues[3],
                    ';" d="M28.229,50.009c-3.336,0-6.646-0.804-9.691-2.392c-0.49-0.255-0.68-0.859-0.425-1.349 c0.255-0.49,0.856-0.682,1.349-0.425c4.505,2.348,9.648,2.802,14.487,1.28c4.839-1.522,8.796-4.842,11.144-9.346 c0.255-0.491,0.857-0.684,1.349-0.425c0.49,0.255,0.68,0.859,0.425,1.349c-2.595,4.979-6.969,8.646-12.316,10.329 C32.474,49.685,30.346,50.009,28.229,50.009z"/><path style="fill:',
                    mdata.attributeValues[3],
                    ';" d="M18,50.003c-0.553,0-1-0.447-1-1c0-2.757,2.243-5,5-5c0.553,0,1,0.447,1,1s-0.447,1-1,1 c-1.654,0-3,1.346-3,3C19,49.556,18.553,50.003,18,50.003z"/><path style="fill:',
                    mdata.attributeValues[3],
                    ';" d="M48,42.003c-0.553,0-1-0.447-1-1c0-1.654-1.346-3-3-3c-0.553,0-1-0.447-1-1s0.447-1,1-1 c2.757,0,5,2.243,5,5C49,41.556,48.553,42.003,48,42.003z"/></g></svg>'
                )
            );
        }
    }

    // ===================== UTILITY ===========================

    function _isBytes8ArrayElementEmpty(bytes8[4] memory arr) private view returns (bool) {
        bool isEmpty = false;
        for (uint256 i = 0; i < arr.length; ++i) {
            if (arr[i].length == 0) {
                isEmpty = true;
                break;
            }
        }

        return isEmpty;
    }

    /// @dev Get metadata with unrevealed image with encoding
    /// @param id token id
    function _getUnrevealedMetadataWEncoding(uint256 id) private view returns (string memory) {
        string memory json = LibBase64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "SP001",',
                        '"description":"Story Protocol Mystery Box NFT","image": "',
                        _getSvg(id),
                        '",',
                        '"attributes": [{"trait_type": "Shape","value": "Cube"},{"trait_type": "Borders","value": "Black"},{"trait_type": "Filled","value": "Orange"}]',
                        "}"
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    /// @dev Get metadata with unrevealed image without encoding
    /// @param id token id
    function _getUnrevealedMetadataWoEncoding(uint256 id) private view returns (string memory) {
        string memory json = string(
            abi.encodePacked(
                '{"name": "SP001",',
                '"description":"Story Protocol Mystery Box NFT","image": "',
                _getSvg(id),
                '",',
                '"attributes": [{"trait_type": "Shape","value": "Cube"},{"trait_type": "Borders","value": "Black"},{"trait_type": "Filled","value": "Orange"}]',
                "}"
            )
        );

        return json;
    }
}
