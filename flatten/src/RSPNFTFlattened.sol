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
