// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {LibString} from "solmate/utils/LibString.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {LibBase64} from "./libs/LibBase64.sol";
import {VRFCoordinatorV2Interface} from "./dependencies/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "./dependencies/VRFConsumerBaseV2.sol";
import {ConfirmedOwner} from "./dependencies/ConfirmedOwner.sol";
import {RevealedSPNFT} from "./RevealedSPNFT.sol";
import {IRevealedSPNFT} from "./interfaces/IRevealedSPNFT.sol";
import {NFTStaking} from "./NFTStaking.sol";
import {console2} from "forge-std/Test.sol";

contract SPNFT is NFTStaking, ReentrancyGuard, VRFConsumerBaseV2, ConfirmedOwner {
    using LibString for uint256;

    // ===================== STORAGE ===========================

    // NFT attribute value options for selection based on
    // random value generated chainlink VRF
    struct AttributeOptions {
        string[4] eyes;
        string[4] hair;
        string[4] face;
        string[4] mouth;
    }

    // NFT metadata
    struct Metadata {
        uint8 revealType;
        bytes32 name;
        bytes32 description;
        // string image;    // it is to be generated during revealing randomizing traits' values options (colors).
        string[4] attributeValues;
    }

    AttributeOptions private _attributeOptions;

    // tokenId => Metadata
    mapping(uint256 => Metadata) private _metadata;

    // no. of tokens (unrevealed initially) minted so far & also mint the next available token id
    // NOTE: burnt NFTs doesn't decrement this no.
    uint256 public tokenIds;

    IRevealedSPNFT public revealedSPNFT;

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint8 revealType; // input taken during `revealToken` function
        uint256 tokenId; // input taken during `revealToken` function
    }
    // uint256[] randomWords;  // OPTIONAL for storage, helpful for debugging, testing

    mapping(uint256 => RequestStatus) public sRequests; /* requestId --> requestStatus */
    VRFCoordinatorV2Interface private _coordinator;

    // Your subscription ID.
    uint64 private _sSubscriptionId;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    bytes32 private _keyHash;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 private callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 private requestConfirmations = 3;

    // For this example, retrieve 4 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 private _numWords = 4;

    uint256 public totalDepositedETH;

    // ===================== EVENT ===========================
    event Minted(address indexed mintedBy, address indexed mintedTo, uint256 indexed tokenId);
    event Burned(address indexed BurnedBy, uint256 indexed tokenId);
    event RequestSent(uint256 indexed requestId, uint32 numWords);
    event RequestFulfilled(uint256 indexed requestId, uint256[] randomWords);
    event ETHRefunded(address indexed mintedBy, uint256 ethAmount);

    // ===================== ERROR ===========================
    error EmptyName();
    error EmptyNameOrSymbol();
    error AttributeOptionsMustBeFourAndNonEmptyElements();
    error NotOwner(address);
    error AlreadyRevealed();
    error InvalidRevealType();
    error InvalidERC20(address);
    error RequestIdNotFound();
    error RequestIdAlreadyFulfilled();
    error TokenIdMustBeType1ForStake(uint256);
    error InsufficientETHForMinting();
    error ETHRefundFailed();
    error EmptyDescription();
    error ZeroAddress();

    // ===================== CONSTRUCTOR ===========================
    constructor(
        string memory _n,
        string memory _s,
        // AttributeOptions memory _aOptions,
        string[4] memory eyes,
        string[4] memory hair,
        string[4] memory face,
        string[4] memory mouth,
        uint64 _subId,
        address _coordinatorContract,
        bytes32 _kHash,
        address _erc20TokenAddress
    ) VRFConsumerBaseV2(_coordinatorContract) ConfirmedOwner(msg.sender) NFTStaking(_n, _s, _erc20TokenAddress) {
        // check if contract
        uint256 size;
        assembly {
            size := extcodesize(_erc20TokenAddress)
        }

        if (size == 0) {
            revert InvalidERC20(_erc20TokenAddress);
        }
        if (_isStringEmpty(_n) || _isStringEmpty(_s)) {
            revert EmptyNameOrSymbol();
        }

        // sanitize attribute options
        // length of each attribute options - eyes, hair, nose, mouth would be 4 for sure as declared above.
        if (
            !(
                !_isStringArrayElementEmpty(eyes) && !_isStringArrayElementEmpty(hair)
                    && !_isStringArrayElementEmpty(face) && !_isStringArrayElementEmpty(mouth)
            )
        ) {
            revert AttributeOptionsMustBeFourAndNonEmptyElements();
        }

        _attributeOptions = AttributeOptions(eyes, hair, face, mouth);

        // deploy Revealed SP NFT contract
        RevealedSPNFT rSPNFT = new RevealedSPNFT("Revealed SP NFT", "RSPNFT", _erc20TokenAddress);
        revealedSPNFT = IRevealedSPNFT(address(rSPNFT));

        // for chainlink VRF
        _sSubscriptionId = _subId;
        _keyHash = _kHash;
        _coordinator = VRFCoordinatorV2Interface(_coordinatorContract);
    }

    // ===================== Getters ===========================

    function metadata(uint256 tokenId) public view returns (Metadata memory) {
        Metadata memory mdata = _metadata[tokenId];
        return mdata;
    }

    /// @dev tokenURI returns the metadata
    function tokenURI(uint256 id) public view override returns (string memory) {
        // token exists
        ownerOf(id);

        Metadata memory mdata = _metadata[id];
        uint8 _revealedType = mdata.revealType;

        // revealed type is 0 i.e. not revealed yet
        if (_revealedType == 0) {
            // return _getUnrevealedMetadataWoEncoding(id);
            return _getUnrevealedMetadataWEncoding(id);
        }
        // revealed type is 1
        else if (_revealedType == 1) {
            // return the encoded onchain metadata for transfer data (in encoded format like serialization)
            // in terms of fast data transmission. Then, at the client level, it would be deserialized/decoded.
            string memory json = LibBase64.encode(
                bytes(
                    string(
                        abi.encodePacked(
                            '{"name": "',
                            mdata.name,
                            '",',
                            '"description": "',
                            mdata.description,
                            '",',
                            '"image": "',
                            _getSvg(id),
                            '",',
                            '"attributes": [{"trait_type": "Eyes", "value": "',
                            mdata.attributeValues[0],
                            '"},',
                            '{"trait_type": "Hair", "value": "',
                            mdata.attributeValues[1],
                            '"},',
                            '{"trait_type": "Nose", "value": "',
                            mdata.attributeValues[2],
                            '"},',
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
            // get the tokenURI of exact same token id from the `RevealedSPNFT`
            return revealedSPNFT.tokenURI(id);
        }
    }

    // ===================== Setters ===========================

    /// @dev Only Owner can
    ///     - mint next available token id
    ///     - set name, description of the NFT
    function mint(address to, bytes32 _name, bytes32 _description) external payable onlyOwner {
        if (to == address(0)) {
            revert ZeroAddress();
        }

        if (_name == bytes32("")) {
            revert EmptyName();
        }

        if (_description == bytes32("")) {
            revert EmptyDescription();
        }

        if (msg.value < PURCHASE_PRICE) {
            revert InsufficientETHForMinting();
        }

        // description is OPTIONAL
        ++tokenIds;

        Metadata storage mdata = _metadata[tokenIds];

        mdata.name = _name;
        mdata.description = _description;

        uint256 refundableETH = msg.value - PURCHASE_PRICE;
        totalDepositedETH += PURCHASE_PRICE;

        _mint(to, tokenIds);

        if (refundableETH > 0) {
            (bool success,) = payable(msg.sender).call{gas: 2300, value: refundableETH}("");
            if (!success) {
                revert ETHRefundFailed();
            }

            emit ETHRefunded(msg.sender, refundableETH);
        }

        emit Minted(msg.sender, to, tokenIds);
    }

    /// @dev NFT asset holder can burn any token
    function burn(uint256 id) external {
        if (msg.sender != ownerOf(id)) {
            revert NotOwner(msg.sender);
        }

        // check if token id already staked, don't allow to burn
        if (stakedTokenIds[id].isStaked) {
            revert AlreadyStaked();
        }

        _burn(id);

        emit Burned(msg.sender, id);
    }

    /// @dev reveal collection is possible only once, by current token owner .
    ///     There could be a case where the 1st owner didn't reveal and transferred as is
    ///     to the 2nd owner. Now, 2nd owner decides to reveal it with 1/2 type.
    /// @param _revealType reveal type to be set for unrevealed tokens.
    /// @param id token id
    function revealToken(uint8 _revealType, uint256 id) external nonReentrant {
        // token exists
        ownerOf(id);

        // check for the correct owner
        _isOwnerOf(id);

        if (!(_revealType == 1 || _revealType == 2)) {
            revert InvalidRevealType();
        }

        // get the revealed type (to check already set or not)
        uint8 _revealedType = _metadata[id].revealType;

        // check if token already revealed
        // Need to check when token owner reveals token for more than 1 time
        if (_revealedType != 0) {
            revert AlreadyRevealed();
        }

        // set revealType in `metadata`
        _metadata[id].revealType = _revealType;

        // Only for revealedType == 1 or 2
        // request random number for setting the metadata attributes (traits).
        _requestRandomWords(_revealType, id);
    }

    /// Assumes the subscription is funded sufficiently.
    /// @param _revealType reveal type
    /// @param _tokenId token id
    function _requestRandomWords(uint8 _revealType, uint256 _tokenId) private returns (uint256 requestId) {
        // Will revert if subscription is not set and funded.
        requestId = _coordinator.requestRandomWords(
            _keyHash, _sSubscriptionId, requestConfirmations, callbackGasLimit, _numWords
        );

        sRequests[requestId] =
            RequestStatus({tokenId: _tokenId, revealType: _revealType, exists: true, fulfilled: false});

        requestIds.push(requestId);

        lastRequestId = requestId;

        emit RequestSent(requestId, _numWords);

        return requestId;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override nonReentrant {
        RequestStatus memory requestStatus = sRequests[_requestId];

        // check if requestId exists
        if (!requestStatus.exists) {
            revert RequestIdNotFound();
        }

        // check if requestId is fulfilled
        if (requestStatus.fulfilled) {
            revert RequestIdAlreadyFulfilled();
        }

        sRequests[_requestId].fulfilled = true;

        // get traits options
        AttributeOptions memory traitsOptions = _attributeOptions;
        string memory eye = traitsOptions.eyes[_randomWords[0] % 4];
        string memory hair = traitsOptions.hair[_randomWords[1] % 4];
        string memory face = traitsOptions.hair[_randomWords[1] % 4];
        string memory mouth = traitsOptions.hair[_randomWords[1] % 4];

        console2.log(eye, hair, face, mouth);

        // if reveal type = 1 or 2
        if (requestStatus.revealType == 1 || requestStatus.revealType == 2) {
            // get as storage to modify
            Metadata storage mdata = _metadata[requestStatus.tokenId];

            // set the attributes for the token id based on generated rand_num
            mdata.attributeValues[0] = eye;
            mdata.attributeValues[1] = hair;
            mdata.attributeValues[2] = face;
            mdata.attributeValues[3] = mouth;

            // if revealType = 2
            if (requestStatus.revealType == 2) {
                // burn from current contract
                this.burn(requestStatus.tokenId);

                // get as memory to read.
                // NOTE: No storage for attribute values. Only name, description, revealType remain stored in this contract
                // mint to `msg.sender` (original owner) into `RevealedSPNFT` contract with metadata values
                revealedSPNFT.mint(
                    ownerOf(requestStatus.tokenId),
                    requestStatus.tokenId,
                    mdata.name,
                    mdata.description,
                    [eye, hair, face, mouth]
                );
            }
        }
        // can't be 0, but incorporated for security reasons [REDUNDANT]
        else {
            revert InvalidRevealType();
        }

        emit RequestFulfilled(_requestId, _randomWords);
    }

    /// @dev stake function
    function stake(uint256 _tokenId) external nonReentrant {
        Metadata memory mdata = _metadata[tokenIds];

        // Stake only revealed tokens of type 1
        // check if the token is revealed & the type is 1,
        // as the type 2 is burned here & moved to other contract
        if (!(mdata.revealType == 1)) {
            revert TokenIdMustBeType1ForStake(_tokenId);
        }

        _stake(_tokenId);
    }

    /// @dev unstake & claim rewards token Id
    /// @param _tokenId token Id for which accrued interest rewards are to be claimed & then unstake
    function unstake(uint256 _tokenId) external nonReentrant {
        _unstake(_tokenId);
    }

    // ===================== UTILITY ===========================

    // function _isBytes8ArrayElementEmpty(bytes8[4] memory arr) private pure returns (bool) {
    //     bool isEmpty = false;
    //     for (uint256 i = 0; i < arr.length; ++i) {
    //         if (arr[i] == bytes8("")) {
    //             isEmpty = true;
    //             break;
    //         }
    //     }

    //     return isEmpty;
    // }
    function _isStringArrayElementEmpty(string[4] memory arr) private pure returns (bool) {
        bool isEmpty = false;
        for (uint256 i = 0; i < arr.length; ++i) {
            if (_isStringEmpty(arr[i])) {
                isEmpty = true;
                break;
            }
        }

        return isEmpty;
    }

    function _isStringEmpty(string memory s1) private pure returns (bool) {
        if (keccak256(bytes(s1)) == keccak256(bytes(""))) {
            return true;
        } else {
            return false;
        }
    }

    // function _isBytes8Empty(bytes8 b1) private pure returns (bool) {
    //     if (keccak256(abi.encodePacked(b1)) == keccak256(bytes(""))) {
    //         return true;
    //     } else {
    //         return false;
    //     }
    // }

    /// bytes32 (any bytes ...here bytes8) to string
    // function _toString(bytes32 b1) private pure returns (string memory result) {
    //     uint8 length = 0;
    //     while (b1[length] != 0 && length < 32) {
    //         ++length;
    //     }
    //     assembly {
    //         result := mload(0x40)
    //         // new "memory end" including padding (the string isn't larger than 32 bytes)
    //         mstore(0x40, add(result, 0x40))
    //         // store length in memory
    //         mstore(result, length)
    //         // write actual data
    //         mstore(add(result, 0x20), b1)
    //     }
    // }

    function _getSvg(uint256 tokenId) private view returns (string memory svg) {
        Metadata memory mdata = _metadata[tokenId];
        uint8 _revealedType = mdata.revealType;

        console2.log(
            mdata.attributeValues[0], mdata.attributeValues[1], mdata.attributeValues[2], mdata.attributeValues[3]
        );

        // revealed type is 0 i.e. not revealed yet
        if (_revealedType == 0) {
            // give the unrevealed uri
            svg =
                '<svg width=\\"800px\\" height=\\"800px\\" viewBox=\\"0 0 24 24\\" xmlns=\\"http://www.w3.org/2000/svg\\" fill=\\"#F48024\\" stroke=\\"#000000\\" stroke-width=\\"1\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"miter\\"><polygon points=\\"3 16 3 8 12 14 21 8 21 16 12 22 3 16\\" stroke-width=\\"0\\" opacity=\\"0.1\\" fill=\\"#059cf7\\"></polygon><polygon points=\\"21 8 21 16 12 22 3 16 3 8 12 2 21 8\\"></polygon><polyline points=\\"3 8 12 14 12 22\\" stroke-linecap=\\"round\\"></polyline><line x1=\\"21\\" y1=\\"8\\" x2=\\"12\\" y2=\\"14\\" stroke-linecap=\\"round\\"></line></svg>';
        }
        // in case of type = 1, 2
        else {
            svg = string(
                abi.encodePacked(
                    '<svg viewBox=\\"0 0 58 58\\" style=\\"enable-background:new 0 0 58 58;\\" xml:space=\\"preserve\\"><g><path style=\\"fill:',
                    mdata.attributeValues[2],
                    ';\\" d=\\"M29.392,54.999c11.246,0.156,17.52-4.381,21.008-9.189c3.603-4.966,4.764-11.283,3.647-17.323 C50.004,6.642,29.392,6.827,29.392,6.827S8.781,6.642,4.738,28.488c-1.118,6.04,0.044,12.356,3.647,17.323 C11.872,50.618,18.146,55.155,29.392,54.999z\\"/><path style=\\"fill:#F9A671;\\" d=\\"M4.499,30.125c-0.453-0.429-0.985-0.687-1.559-0.687C1.316,29.438,0,31.419,0,33.862 c0,2.443,1.316,4.424,2.939,4.424c0.687,0,1.311-0.37,1.811-0.964C4.297,34.97,4.218,32.538,4.499,30.125z\\"/><path style=\\"fill:#F9A671;\\" d=\\"M57.823,26.298c-0.563-2.377-2.3-3.999-3.879-3.622c-0.491,0.117-0.898,0.43-1.225,0.855 c0.538,1.515,0.994,3.154,1.328,4.957c0.155,0.837,0.261,1.679,0.328,2.522c0.52,0.284,1.072,0.402,1.608,0.274 C57.562,30.908,58.386,28.675,57.823,26.298z\\"/><path style=\\"fill:',
                    mdata.attributeValues[1],
                    ';\\" d=\\"M13.9,16.998c-0.256,0-0.512-0.098-0.707-0.293l-5-5c-0.391-0.391-0.391-1.023,0-1.414 s1.023-0.391,1.414,0l5,5c0.391,0.391,0.391,1.023,0,1.414C14.412,16.901,14.156,16.998,13.9,16.998z\\"/><path style=\\"fill:',
                    mdata.attributeValues[1],
                    ';\\" d=\\"M16.901,13.998c-0.367,0-0.72-0.202-0.896-0.553l-3-6c-0.247-0.494-0.047-1.095,0.447-1.342 c0.495-0.245,1.094-0.047,1.342,0.447l3,6c0.247,0.494,0.047,1.095-0.447,1.342C17.204,13.964,17.052,13.998,16.901,13.998z\\"/><path style=\\"fill:',
                    mdata.attributeValues[1],
                    ';\\" d=\\"M20.9,11.998c-0.419,0-0.809-0.265-0.948-0.684l-2-6c-0.175-0.524,0.108-1.091,0.632-1.265 c0.527-0.176,1.091,0.108,1.265,0.632l2,6c0.175,0.524-0.108,1.091-0.632,1.265C21.111,11.982,21.005,11.998,20.9,11.998z\\"/><path style=\\"fill:',
                    mdata.attributeValues[1],
                    ';\\" d=\\"M25.899,10.998c-0.48,0-0.904-0.347-0.985-0.836l-1-6c-0.091-0.544,0.277-1.06,0.822-1.15 c0.543-0.098,1.061,0.277,1.15,0.822l1,6c0.091,0.544-0.277,1.06-0.822,1.15C26.009,10.995,25.954,10.998,25.899,10.998z\\"/><path style=\\"fill:',
                    mdata.attributeValues[1],
                    ';\\" d=\\"M29.9,10.998c-0.553,0-1-0.447-1-1v-6c0-0.553,0.447-1,1-1s1,0.447,1,1v6 C30.9,10.551,30.453,10.998,29.9,10.998z\\"/><path style=\\"fill:',
                    mdata.attributeValues[1],
                    ';\\" d=\\"M33.9,10.998c-0.104,0-0.211-0.017-0.316-0.052c-0.523-0.174-0.807-0.74-0.632-1.265l2-6 c0.175-0.523,0.736-0.809,1.265-0.632c0.523,0.174,0.807,0.74,0.632,1.265l-2,6C34.709,10.734,34.319,10.998,33.9,10.998z\\"/><path style=\\"fill:',
                    mdata.attributeValues[1],
                    ';\\" d=\\"M37.9,11.998c-0.104,0-0.211-0.017-0.316-0.052c-0.523-0.174-0.807-0.74-0.632-1.265l2-6c0.175-0.523,0.737-0.808,1.265-0.632c0.523,0.174,0.807,0.74,0.632,1.265l-2,6C38.709,11.734,38.319,11.998,37.9,11.998z\\"/><path style=\\"fill:',
                    mdata.attributeValues[1],
                    ';\\" d=\\"M40.899,13.998c-0.15,0-0.303-0.034-0.446-0.105c-0.494-0.247-0.694-0.848-0.447-1.342l3-6c0.248-0.494,0.848-0.692,1.342-0.447c0.494,0.247,0.694,0.848,0.447,1.342l-3,6C41.619,13.796,41.267,13.998,40.899,13.998z\\"/><circle style=\\"fill:#FFFFFF;\\" cx=\\"22\\" cy=\\"26.003\\" r=\\"6\\"/><circle style=\\"fill:#FFFFFF;\\" cx=\\"36\\" cy=\\"26.003\\" r=\\"8\\"/><circle style=\\"fill:',
                    mdata.attributeValues[0],
                    ';\\" cx=\\"22\\" cy=\\"26.003\\" r=\\"2\\"/><circle style=\\"fill:',
                    mdata.attributeValues[0],
                    ';\\" cx=\\"36\\" cy=\\"26.003\\" r=\\"3\\"/><path style=\\"fill:',
                    mdata.attributeValues[3],
                    ';\\" d=\\"M28.229,50.009c-3.336,0-6.646-0.804-9.691-2.392c-0.49-0.255-0.68-0.859-0.425-1.349 c0.255-0.49,0.856-0.682,1.349-0.425c4.505,2.348,9.648,2.802,14.487,1.28c4.839-1.522,8.796-4.842,11.144-9.346 c0.255-0.491,0.857-0.684,1.349-0.425c0.49,0.255,0.68,0.859,0.425,1.349c-2.595,4.979-6.969,8.646-12.316,10.329 C32.474,49.685,30.346,50.009,28.229,50.009z\\"/><path style=\\"fill:',
                    mdata.attributeValues[3],
                    ';\\" d=\\"M18,50.003c-0.553,0-1-0.447-1-1c0-2.757,2.243-5,5-5c0.553,0,1,0.447,1,1s-0.447,1-1,1 c-1.654,0-3,1.346-3,3C19,49.556,18.553,50.003,18,50.003z\\"/><path style=\\"fill:',
                    mdata.attributeValues[3],
                    ';\\" d=\\"M48,42.003c-0.553,0-1-0.447-1-1c0-1.654-1.346-3-3-3c-0.553,0-1-0.447-1-1s0.447-1,1-1 c2.757,0,5,2.243,5,5C49,41.556,48.553,42.003,48,42.003z\\"/></g></svg>'
                )
            );
        }
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
    // function _getUnrevealedMetadataWoEncoding(uint256 id) private view returns (string memory) {
    //     string memory json = string(
    //         abi.encodePacked(
    //             '{"name": "SP001",',
    //             '"description":"Story Protocol Mystery Box NFT","image": "',
    //             _getSvg(id),
    //             '",',
    //             '"attributes": [{"trait_type": "Shape","value": "Cube"},{"trait_type": "Borders","value": "Black"},{"trait_type": "Filled","value": "Orange"}]',
    //             "}"
    //         )
    //     );

    //     return json;
    // }
}
