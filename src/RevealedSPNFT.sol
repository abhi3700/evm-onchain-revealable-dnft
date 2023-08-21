// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {LibString} from "solmate/utils/LibString.sol";
import {LibBase64} from "./libs/LibBase64.sol";
import {Owned} from "solmate/auth/Owned.sol";

import {NFTStaking} from "./NFTStaking.sol";
import {console2} from "forge-std/Test.sol";

/// @title Revealed SP NFT contract
/// @notice For "Separate Collection Revealing" approach.
contract RevealedSPNFT is NFTStaking, Owned, ReentrancyGuard {
    using LibString for uint256;

    // ===================== STORAGE ===========================

    // NFT metadata
    struct Metadata {
        bytes32 name;
        bytes32 description;
        // string image;    // it is to be generated during revealing randomizing traits' values options (colors).
        bytes8[4] attributeValues;
    }

    // no. of tokens minted so far
    // NOTE: burnt NFTs doesn't decrement this no.
    uint256 public tokenIds;

    // tokenId => Metadata
    mapping(uint256 => Metadata) private _metadata;

    // ===================== EVENT ===========================
    event Minted(address indexed caller, address indexed to, uint256 indexed tokenId);
    event Burned(address indexed holder, uint256 indexed tokenId);

    // ===================== ERROR ===========================
    error EmptyName();
    error NotOwner(address);
    error EmptyAttributeValues();
    error InsufficientETHForMinting();
    error ETHRefundFailed();
    error EmptyDescription();

    // ===================== CONSTRUCTOR ===========================

    constructor(string memory _n, string memory _s, address _erc20TokenAddress)
        NFTStaking(_n, _s, _erc20TokenAddress)
        Owned(msg.sender)
    {}

    // ===================== Getters ===========================
    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        ownerOf(id);

        Metadata memory mdata = _metadata[id];
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

    function _getSvg(uint256 tokenId) private view returns (string memory svg) {
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

    // ===================== Setters ===========================
    /// @dev Only Owner can
    ///     - mint the exact same token id as `SPNFT` contract
    ///     - set name, description, attributes of the NFT
    function mint(address to, uint256 id, bytes32 _name, bytes32 _description, bytes8[4] memory attributeValues)
        external
        payable
        onlyOwner
        nonReentrant
    {
        if (_name.length == 0) {
            revert EmptyName();
        }

        if (_description.length == 0) {
            revert EmptyDescription();
        }

        if (msg.value < PURCHASE_PRICE) {
            revert InsufficientETHForMinting();
        }

        // check for non-empty elements inside attribute values
        if (_isBytes8ArrayElementEmpty(attributeValues)) {
            revert EmptyAttributeValues();
        }

        Metadata storage mdata = _metadata[tokenIds];

        mdata.name = _name;
        mdata.description = _description;
        for (uint256 i = 0; i < 4; ++i) {
            mdata.attributeValues[i] = attributeValues[i];
        }
        // total minted tokens updated for record.
        ++tokenIds;

        uint256 refundableETH = msg.value - PURCHASE_PRICE;

        _mint(to, id);

        if (refundableETH > 0) {
            (bool success,) = payable(msg.sender).call{gas: 2300, value: refundableETH}("");
            if (!success) {
                revert ETHRefundFailed();
            }
        }

        emit Minted(msg.sender, to, tokenIds);
    }

    function burn(uint256 id) internal {
        if (msg.sender != ownerOf(id)) {
            revert NotOwner(msg.sender);
        }
        _burn(id);

        emit Burned(msg.sender, id);
    }

    /// @dev stake function
    function stake(uint256 _tokenId) external nonReentrant {
        _stake(_tokenId);
    }

    /// @dev unstake & claim rewards token Id
    /// @param _tokenId token Id for which accrued interest rewards are to be claimed & then unstake
    function unstake(uint256 _tokenId) external nonReentrant {
        _unstake(_tokenId);
    }

    // TODO: override all external setters: approve, transfer, transferFrom functions ensuring the tokens are not transferable or approvable

    // ===================== UTILITY ===========================

    function _isBytes8ArrayElementEmpty(bytes8[4] memory arr) private pure returns (bool) {
        bool isEmpty = false;
        for (uint256 i = 0; i < arr.length; ++i) {
            if (arr[i].length == 0) {
                isEmpty = true;
                break;
            }
        }

        return isEmpty;
    }
}
