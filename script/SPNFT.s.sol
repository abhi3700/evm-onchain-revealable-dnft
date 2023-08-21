// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import {RevealedSPNFT} from "../src/RevealedSPNFT.sol";
import {SPNFT} from "../src/SPNFT.sol";
import {SPToken} from "../src/SPToken.sol";

contract SPNFTScript is Script {
    SPToken public spToken;
    RevealedSPNFT public rSPNFT;
    SPNFT public spNFT;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // 1. deploy ERC20
        spToken = new SPToken("SP Token", "SPT", 18);
        // 2. deploy SPNFT
        //   - linked ERC20 (into NFTStaking) to SPNFT
        //   - created RSPNFT contract
        //     - linked ERC20 (into NFTStaking) to RSPNFT

        /// chainlink 3 params parsed for sepolia network. Goerli faucets difficult to get as mainnet balance required > 0.1 ETH.
        spNFT = new SPNFT(
            "SP NFT", 
            "SPNFT",  
            ["#634e34","#3d671d","#2e536f","#1c7847"],
            ["#583322","#1e90ff","#eeb2d2","#4b0082"],
            ["#f5f3e7","#ffcc99","#fde0d9","#808000"],
            ["#d291bc","#ff0000","#ff7f50","#800020"],
            uint64(4562),
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            address(spToken)
        );

        console2.log("ERC20 token deployed at: ", address(spToken));
        console2.log("SPNFT contract deployed at: ", address(spNFT));
        address rSPNFTAddress = address(spNFT.revealedSPNFT());
        console2.log("RSPNFT contract deployed at: ", rSPNFTAddress);

        // NOTE: There can be 1 common function created for transferring tokens at once.
        // 3. transfer 10k tokens to SPNFT contract
        spToken.transfer(address(spNFT), 1e22);
        console2.log("The SPNFT's balance: ", spToken.balanceOf(address(spNFT)));
        // 4. transfer 10k tokens to RSPNFT contract
        spToken.transfer(rSPNFTAddress, 1e22);
        console2.log("The SPNFT's balance: ", spToken.balanceOf(rSPNFTAddress));

        vm.stopBroadcast();
    }
}
