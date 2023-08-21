// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import {RevealedSPNFT} from "../src/RevealedSPNFT.sol";
import {SPNFT} from "../src/SPNFT.sol";

contract SPNFTScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // 1. deploy ERC20
        // 2. deploy SPNFT
        //   - linked ERC20 (into NFTStaking) to SPNFT
        //   - created RSPNFT contract
        //     - linked ERC20 (into NFTStaking) to RSPNFT

        // NOTE: There can be 1 common function for transferring tokens at once.
        // 3. transfer 1 M tokens to SPNFT contract
        // 4. transfer 1 M tokens to RSPNFT contract

        vm.stopBroadcast();
    }
}
