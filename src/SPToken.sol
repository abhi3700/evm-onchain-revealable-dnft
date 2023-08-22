// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {ERC20} from "./dependencies/ERC20.sol";
import {Owned} from "./dependencies/Owned.sol";
import {Pausable} from "./dependencies/Pausable.sol";

contract SPToken is ERC20, Owned, Pausable {
    constructor(string memory n, string memory s, uint8 _decimals)
        ERC20(n, s, _decimals)
        Owned(msg.sender)
        Pausable()
    {
        // mint 1M tokens to owner
        _mint(msg.sender, 1_000_000 * 10 ** _decimals);
    }

    function mint(address to, uint256 amount) external whenNotPaused onlyOwner {
        _mint(to, amount);
    }
}
