// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {IERC20} from "./IERC20.sol";

interface ISPToken is IERC20 {
    function mint(address to, uint256 amount) external;
}
