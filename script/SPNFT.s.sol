// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import {RevealedSPNFT} from "../src/RevealedSPNFT.sol";
import {SPNFT} from "../src/SPNFT.sol";

contract SPNFTScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // deploy Revealed SPNFT

        // deploy SPNFT with Revealed SPNFT contract

        vm.stopBroadcast();
    }
}
