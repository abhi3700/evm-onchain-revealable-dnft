// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {ERC20} from "solmate/tokens/ERC20.sol";

import {Owned} from "solmate/auth/Owned.sol";

contract SPToken is ERC20, Owned {
    constructor(string memory n, string memory s, uint8 _decimals) ERC20(n, s, _decimals) Owned(msg.sender) {
        // mint 1M tokens to owner
        _mint(msg.sender, 1_000_000 * 10 ** _decimals);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
