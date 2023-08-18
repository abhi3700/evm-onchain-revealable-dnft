// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import {RevealedSPNFT} from "../src/RevealedSPNFT.sol";
import {SPNFT} from "../src/SPNFT.sol";

contract SPNFTScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // 1. deploy Revealed SPNFT

        // 2. deploy SPNFT with Revealed SPNFT contract & chainlink details

        // 3. transfer ownership of `RevealedSPNFT` to `SPNFT` for minting

        // 4. deploy staking contract with both the contracts (as they have revealed types 1 & 2)

        vm.stopBroadcast();
    }
}
