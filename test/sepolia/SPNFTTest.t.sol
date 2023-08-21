// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {ISPToken} from "../../src/interfaces/ISPToken.sol";
import {ISPNFT} from "../../src/interfaces/ISPNFT.sol";
import {IRevealedSPNFT} from "../../src/interfaces/IRevealedSPNFT.sol";

// import {SPToken} from "../../src/SPToken.sol";
// import {SPNFT} from "../../src/SPNFT.sol";
// import {RevealedSPNFT} from "../../src/RevealedSPNFT.sol";

contract SPNFTTest is Test {
    ISPToken public spToken;
    IRevealedSPNFT public rSPNFT;
    ISPNFT public spNFT;

    address public constant ZERO_ADDRESS = address(0);
    address public constant ME = 0x0370D871f1D4B256E753120221F3Be87A40bd246;

    // Deploy contracts on Sepolia network
    address public constant SP_TOKEN_ADDRESS = 0x3B2D448296b0E73f33ca98459EFD256C22656f4B;
    address public constant SP_NFT_ADDRESS = 0x185104B1fF9494A4587fAAE6104c8b5333e21D0d;
    address public constant RSP_NFT_ADDRESS = 0x6edDF6A2480d45A0E6C14D07e3273eB8eC0De012;

    // ===================== EVENT ===========================
    event Minted(address indexed mintedBy, address indexed mintedTo, uint256 indexed tokenId);
    event Burned(address indexed BurnedBy, uint256 indexed tokenId);
    event RequestSent(uint256 indexed requestId, uint32 numWords);
    event RequestFulfilled(uint256 indexed requestId, uint256[] randomWords);
    event ETHRefunded(address indexed mintedBy, uint256 ethAmount);

    // ===================== CONSTRUCTOR ===========================
    function setUp() public {
        // 1. deploy ERC20
        spToken = ISPToken(SP_TOKEN_ADDRESS);
        // 2. deploy SPNFT
        //   - linked ERC20 (into NFTStaking) to SPNFT
        //   - created RSPNFT contract
        //     - linked ERC20 (into NFTStaking) to RSPNFT
        /// chainlink 3 params parsed for sepolia network. Goerli faucets difficult to get as mainnet balance required > 0.1 ETH.
        spNFT = ISPNFT(SP_NFT_ADDRESS);
    }

    function testContractBalances() public {
        // get ERC20 balance of SPNFT contract
        assertEq(spToken.balanceOf(SP_NFT_ADDRESS), 1e22, "mismatch in ERC20 token balance of SPNFT");
        // get ERC20 balance of RSPNFT contract
        assertEq(spToken.balanceOf(RSP_NFT_ADDRESS), 1e22, "mismatch in ERC20 token balance of RSPNFT");
    }
}
