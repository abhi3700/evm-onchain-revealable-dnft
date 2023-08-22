// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/// @notice Efficient library for creating string representations of integers.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)
/// @author Modified from Solady (https://github.com/Vectorized/solady/blob/main/src/utils/LibString.sol)
library LibString {
    function toString(int256 value) internal pure returns (string memory str) {
        if (value >= 0) return toString(uint256(value));

        unchecked {
            str = toString(uint256(-value));

            /// @solidity memory-safe-assembly
            assembly {
                // Note: This is only safe because we over-allocate memory
                // and write the string from right to left in toString(uint256),
                // and thus can be sure that sub(str, 1) is an unused memory location.

                let length := mload(str) // Load the string length.
                // Put the - character at the start of the string contents.
                mstore(str, 45) // 45 is the ASCII code for the - character.
                str := sub(str, 1) // Move back the string pointer by a byte.
                mstore(str, add(length, 1)) // Update the string length.
            }
        }
    }

    function toString(uint256 value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but we allocate 160 bytes
            // to keep the free memory pointer word aligned. We'll need 1 word for the length, 1 word for the
            // trailing zeros padding, and 3 other words for a max of 78 digits. In total: 5 * 32 = 160 bytes.
            let newFreeMemoryPointer := add(mload(0x40), 160)

            // Update the free memory pointer to avoid overriding our string.
            mstore(0x40, newFreeMemoryPointer)

            // Assign str to the end of the zone of newly allocated memory.
            str := sub(newFreeMemoryPointer, 32)

            // Clean the last word of memory it may not be overwritten.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                // Move the pointer 1 byte to the left.
                str := sub(str, 1)

                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))

                // Keep dividing temp until zero.
                temp := div(temp, 10)

                // prettier-ignore
                if iszero(temp) { break }
            }

            // Compute and cache the final total length of the string.
            let length := sub(end, str)

            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 32)

            // Store the string's length at the start of memory allocated for our string.
            mstore(str, length)
        }
    }
}

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}

library LibBase64 {
    string internal constant TABLE_ENCODE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    bytes internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
        hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
        hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
        hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {} lt(dataPtr, endPtr) {} {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        // load the table into memory
        bytes memory table = TABLE_DECODE;

        // every 4 characters represent 3 bytes
        uint256 decodedLen = (data.length / 4) * 3;

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            // padding with '='
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) { decodedLen := sub(decodedLen, 1) }
            }

            // set the actual output length
            mstore(result, decodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 4 characters at a time
            for {} lt(dataPtr, endPtr) {} {
                // read 4 characters
                dataPtr := add(dataPtr, 4)
                let input := mload(dataPtr)

                // write 3 bytes
                let output :=
                    add(
                        add(
                            shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                            shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))
                        ),
                        add(
                            shl(6, and(mload(add(tablePtr, and(shr(8, input), 0xFF))), 0xFF)),
                            and(mload(add(tablePtr, and(input, 0xFF))), 0xFF)
                        )
                    )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}

interface VRFCoordinatorV2Interface {
    /**
     * @notice Get configuration relevant for making requests
     * @return minimumRequestConfirmations global min for request confirmations
     * @return maxGasLimit global max for request gas limit
     * @return s_provingKeyHashes list of registered key hashes
     */
    function getRequestConfig() external view returns (uint16, uint32, bytes32[] memory);

    /**
     * @notice Request a set of random words.
     * @param keyHash - Corresponds to a particular oracle job which uses
     * that key for generating the VRF proof. Different keyHash's have different gas price
     * ceilings, so you can select a specific one to bound your maximum per request cost.
     * @param subId  - The ID of the VRF subscription. Must be funded
     * with the minimum subscription balance required for the selected keyHash.
     * @param minimumRequestConfirmations - How many blocks you'd like the
     * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
     * for why you may want to request more. The acceptable range is
     * [minimumRequestBlockConfirmations, 200].
     * @param callbackGasLimit - How much gas you'd like to receive in your
     * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
     * may be slightly less than this amount because of gas used calling the function
     * (argument decoding etc.), so you may need to request slightly more than you expect
     * to have inside fulfillRandomWords. The acceptable range is
     * [0, maxGasLimit]
     * @param numWords - The number of uint256 random values you'd like to receive
     * in your fulfillRandomWords callback. Note these numbers are expanded in a
     * secure way by the VRFCoordinator from a single random value supplied by the oracle.
     * @return requestId - A unique identifier of the request. Can be used to match
     * a request to a response in fulfillRandomWords.
     */
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);

    /**
     * @notice Create a VRF subscription.
     * @return subId - A unique subscription id.
     * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
     * @dev Note to fund the subscription, use transferAndCall. For example
     * @dev  LINKTOKEN.transferAndCall(
     * @dev    address(COORDINATOR),
     * @dev    amount,
     * @dev    abi.encode(subId));
     */
    function createSubscription() external returns (uint64 subId);

    /**
     * @notice Get a VRF subscription.
     * @param subId - ID of the subscription
     * @return balance - LINK balance of the subscription in juels.
     * @return reqCount - number of requests for this subscription, determines fee tier.
     * @return owner - owner of the subscription.
     * @return consumers - list of consumer address which are able to use this subscription.
     */
    function getSubscription(uint64 subId)
        external
        view
        returns (uint96 balance, uint64 reqCount, address owner, address[] memory consumers);

    /**
     * @notice Request subscription owner transfer.
     * @param subId - ID of the subscription
     * @param newOwner - proposed new owner of the subscription
     */
    function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

    /**
     * @notice Request subscription owner transfer.
     * @param subId - ID of the subscription
     * @dev will revert if original owner of subId has
     * not requested that msg.sender become the new owner.
     */
    function acceptSubscriptionOwnerTransfer(uint64 subId) external;

    /**
     * @notice Add a consumer to a VRF subscription.
     * @param subId - ID of the subscription
     * @param consumer - New consumer which can use the subscription
     */
    function addConsumer(uint64 subId, address consumer) external;

    /**
     * @notice Remove a consumer from a VRF subscription.
     * @param subId - ID of the subscription
     * @param consumer - Consumer to remove from the subscription
     */
    function removeConsumer(uint64 subId, address consumer) external;

    /**
     * @notice Cancel a subscription
     * @param subId - ID of the subscription
     * @param to - Where to send the remaining LINK to
     */
    function cancelSubscription(uint64 subId, address to) external;

    /*
    * @notice Check to see if there exists a request commitment consumers
    * for all consumers and keyhashes for a given sub.
    * @param subId - ID of the subscription
    * @return true if there exists at least one unfulfilled request for the subscription, false
    * otherwise.
    */
    function pendingRequestExists(uint64 subId) external view returns (bool);
}

/**
 *
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
    error OnlyCoordinatorCanFulfill(address have, address want);

    address private immutable vrfCoordinator;

    /**
     * @param _vrfCoordinator address of VRFCoordinator contract
     */
    constructor(address _vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
    }

    /**
     * @notice fulfillRandomness handles the VRF response. Your contract must
     * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
     * @notice principles to keep in mind when implementing your fulfillRandomness
     * @notice method.
     *
     * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
     * @dev signature, and will call it once it has verified the proof
     * @dev associated with the randomness. (It is triggered via a call to
     * @dev rawFulfillRandomness, below.)
     *
     * @param requestId The Id initially returned by requestRandomness
     * @param randomWords the VRF output expanded to the requested number of words
     */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

    // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
    // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
    // the origin of the call
    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
        if (msg.sender != vrfCoordinator) {
            revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        }
        fulfillRandomWords(requestId, randomWords);
    }
}

// import {ConfirmedOwner} from "./dependencies/ConfirmedOwner.sol";

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)
// NOTE: removed Context.sol

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");

        return _balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address from, address to, uint256 id) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id], "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint256 id) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "")
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes calldata data) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data)
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == 0x01ffc9a7 // ERC165 Interface ID for ERC165
            || interfaceId == 0x80ac58cd // ERC165 Interface ID for ERC721
            || interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "")
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(address to, uint256 id, bytes memory data) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data)
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(address, address, uint256, bytes calldata) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        public
        virtual
    {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(ERC20 token, address from, address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success :=
                and(
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                    // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                    // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                    // Counterintuitively, this call must be positioned second to the or() call in the
                    // surrounding and() call or else returndatasize() will be zero during the computation.
                    call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
                )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(ERC20 token, address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success :=
                and(
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                    // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                    // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                    // Counterintuitively, this call must be positioned second to the or() call in the
                    // surrounding and() call or else returndatasize() will be zero during the computation.
                    call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
                )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(ERC20 token, address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success :=
                and(
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                    // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                    // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                    // Counterintuitively, this call must be positioned second to the or() call in the
                    // surrounding and() call or else returndatasize() will be zero during the computation.
                    call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
                )
        }

        require(success, "APPROVE_FAILED");
    }
}

// import {console2} from "forge-std/Test.sol";

abstract contract NFTStaking is ERC721 {
    using SafeTransferLib for ERC20;

    uint8 public constant APY = 5;
    uint256 public constant PURCHASE_PRICE = 5e15; // 0.005 ETH or ERC20

    ERC20 public erc20Token;

    struct Stake {
        bool isStaked;
        uint32 stakedTime; // time from when the accrued interest calculation starts, reset the time (to now) when claimed
    }

    // tokenId => Stake
    mapping(uint256 => Stake) public stakedTokenIds;

    event Staked(address indexed user, uint256 indexed tokenId);
    event Unstaked(address indexed user, uint256 indexed tokenId);

    error NotStaked();
    error AlreadyStaked();
    error NotTokenOwner();

    constructor(string memory _n, string memory _s, address _erc20TokenAddress) ERC721(_n, _s) {
        erc20Token = ERC20(_erc20TokenAddress);
    }

    // ===================== Getters ===========================

    // function getTotalStaked() external view returns (uint256) {}
    function getTokenIdStatus(uint256 _tokenId) external view returns (bool) {
        return stakedTokenIds[_tokenId].isStaked;
    }

    // ===================== Setters ===========================
    /// @dev stake function
    function _stake(uint256 _tokenId) internal {
        // check for valid token id: owned or not by caller
        ownerOf(_tokenId);

        // check for correct owner
        _isOwnerOf(_tokenId);

        // By default the type is 2 as minted by SPNFT after contract deployment settings for the project.
        // So, no need to check for the reveal type.
        // as the type 2 is burned here & moved to other contract

        Stake storage stake = stakedTokenIds[_tokenId];

        // check if token id already staked or not
        if (stake.isStaked) {
            revert AlreadyStaked();
        }

        stake.isStaked = true;
        stake.stakedTime = uint32(block.timestamp);

        emit Staked(msg.sender, _tokenId);
    }

    /// @dev unstake & claim rewards token Id
    /// @param _tokenId token Id for which accrued interest rewards are to be claimed & then unstake
    function _unstake(uint256 _tokenId) internal {
        // check for valid token id whether minted or not
        ownerOf(_tokenId);

        // check for correct owner
        _isOwnerOf(_tokenId);

        // check if token id staked or not
        if (!stakedTokenIds[_tokenId].isStaked) {
            revert NotStaked();
        }

        uint256 accruedInterest = (PURCHASE_PRICE * APY) / 100;

        // reset to zero.
        delete stakedTokenIds[_tokenId];

        // mint the accrued interest
        erc20Token.safeTransfer(msg.sender, accruedInterest);

        emit Unstaked(msg.sender, _tokenId);
    }

    function _isOwnerOf(uint256 id) internal view {
        // check for the correct owner
        if (ownerOf(id) != msg.sender) {
            revert NotTokenOwner();
        }
    }
}

// import {console2} from "forge-std/Test.sol";

/// @title Revealed SP NFT contract
/// @notice For "Separate Collection Revealing" approach i.e Type-2
contract RevealedSPNFT is NFTStaking, Owned, ReentrancyGuard, Pausable {
    using LibString for uint256;

    // ===================== STORAGE ===========================

    // NFT metadata
    struct Metadata {
        bytes32 name;
        bytes32 description;
        // string image;    // it is to be generated during revealing randomizing traits' values options (colors).
        string[4] attributeValues;
    }

    // no. of tokens (revealed Type 2) minted so far
    // NOTE: burnt NFTs doesn't decrement this no.
    uint256 public tokenIds;

    uint256 public totalDepositedETH;

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
        Pausable()
    {}

    // ===================== Getters ===========================
    function tokenURI(uint256 id) public view override returns (string memory) {
        ownerOf(id);

        Metadata memory mdata = _metadata[id];
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

    // ===================== Setters ===========================
    /// @dev Only Owner can
    ///     - mint the exact same token id as `SPNFT` contract
    ///     - set name, description, attributes of the NFT
    function mint(address to, uint256 id, bytes32 _name, bytes32 _description, string[4] memory attributeValues)
        external
        payable
        whenNotPaused
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
        if (_isStringArrayElementEmpty(attributeValues)) {
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
        totalDepositedETH += PURCHASE_PRICE;

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

    /// @notice Pause contract
    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    /// @notice Unpause contract
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    // ===================== UTILITY ===========================

    // function _isBytes8ArrayElementEmpty(bytes8[4] memory arr) private pure returns (bool) {
    //     bool isEmpty = false;
    //     for (uint256 i = 0; i < arr.length; ++i) {
    //         if (arr[i].length == 0) {
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

    function _getSvg(uint256 tokenId) private view returns (string memory svg) {
        Metadata memory mdata = _metadata[tokenId];

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

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    /// uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    /// `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
/// Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface IERC721 is IERC165 {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    /// This event emits when NFTs are created (`from` == 0) and destroyed
    /// (`to` == 0). Exception: during contract creation, any number of NFTs
    /// may be created and assigned without emitting Transfer. At the time of
    /// any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    /// reaffirmed. The zero address indicates there is no approved address.
    /// When a Transfer event emits, this also indicates that the approved
    /// address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    /// The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    /// function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    /// about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    /// operator, or the approved address for this NFT. Throws if `_from` is
    /// not the current owner. Throws if `_to` is the zero address. Throws if
    /// `_tokenId` is not a valid NFT. When transfer is complete, this function
    /// checks if `_to` is a smart contract (code size > 0). If so, it calls
    /// `onERC721Received` on `_to` and throws if the return value is not
    /// `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    /// except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    /// TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    /// THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    /// operator, or the approved address for this NFT. Throws if `_from` is
    /// not the current owner. Throws if `_to` is the zero address. Throws if
    /// `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    /// Throws unless `msg.sender` is the current NFT owner, or an authorized
    /// operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    /// all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    /// multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface IERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    /// after a `transfer`. This function MAY throw to revert and reject the
    /// transfer. Return of other than the magic value MUST result in the
    /// transaction being reverted.
    /// Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data)
        external
        returns (bytes4);
}

/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
/// Note: the ERC-165 identifier for this interface is 0x5b5e139f.
interface IERC721Metadata is IERC721 {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory _name);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory _symbol);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    /// 3986. The URI may point to a JSON file that conforms to the "ERC721
    /// Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

/// @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
/// Note: the ERC-165 identifier for this interface is 0x780e9d63.
interface IERC721Enumerable is IERC721 {
    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    /// them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    /// (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256);

    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    /// `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    /// (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

/// @notice Interface for RevealedSPNFT
interface INFTStaking {
    struct Stake {
        bool isStaked;
        uint32 stakedTime; // time from when the accrued interest calculation starts, reset the time (to now) when claimed
    }

    function stakedTokenIds(uint256 tokenId) external view returns (Stake memory);
    function getTokenIdStatus(uint256 _tokenId) external view returns (bool);
}

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

// import {console2} from "forge-std/Test.sol";

contract SPNFT is NFTStaking, ReentrancyGuard, VRFConsumerBaseV2, Owned, Pausable {
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
    event Burned(address indexed burnedBy, uint256 indexed tokenId);
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
    )
        VRFConsumerBaseV2(_coordinatorContract)
        // ConfirmedOwner(msg.sender)
        Owned(msg.sender)
        NFTStaking(_n, _s, _erc20TokenAddress)
        Pausable()
    {
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
    function mint(address to, bytes32 _name, bytes32 _description)
        external
        payable
        whenNotPaused
        onlyOwner
        nonReentrant
    {
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
    function burn(uint256 id) external whenNotPaused {
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
    function revealToken(uint8 _revealType, uint256 id) external whenNotPaused nonReentrant {
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

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords)
        internal
        override
        whenNotPaused
        nonReentrant
    {
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
    function stake(uint256 _tokenId) external whenNotPaused nonReentrant {
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
    function unstake(uint256 _tokenId) external whenNotPaused nonReentrant {
        _unstake(_tokenId);
    }

    /// @notice Pause contract
    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    /// @notice Unpause contract
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    /// @notice Pause revealed SPNFT contract
    function pauseRevealedSPNFT() external onlyOwner whenNotPaused {
        revealedSPNFT.pause();
    }

    /// @notice Unpause revealed SPNFT contract
    function unpauseRevealedSPNFT() external onlyOwner whenPaused {
        revealedSPNFT.unpause();
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
