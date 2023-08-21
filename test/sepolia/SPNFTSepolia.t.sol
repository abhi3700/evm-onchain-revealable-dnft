// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {ISPToken} from "../../src/interfaces/ISPToken.sol";
import {ISPNFT} from "../../src/interfaces/ISPNFT.sol";
import {IRevealedSPNFT} from "../../src/interfaces/IRevealedSPNFT.sol";

// import {SPToken} from "../../src/SPToken.sol";
// import {SPNFT} from "../../src/SPNFT.sol";
// import {RevealedSPNFT} from "../../src/RevealedSPNFT.sol";

/* 
    This contract is mainly to test the chainlink VRF based functions for randomization on Sepolia network using `fork-url`:
    - `revealToken`
    - `stake`
    - `unstake`
*/
contract SPNFTSepoliaTest is Test {
    ISPToken public spToken;
    IRevealedSPNFT public rSPNFT;
    ISPNFT public spNFT;

    uint256 public constant PURCHASE_PRICE = 5e15; // 0.005 ETH or ERC20

    address public constant ZERO_ADDRESS = address(0);
    address public constant ALICE = address(0xA11CE);

    // EOAs on Sepolia contract
    address public constant ME = 0x0370D871f1D4B256E753120221F3Be87A40bd246;

    // Deploy contracts on Sepolia network
    address public constant SP_TOKEN_ADDRESS = 0x9975Bb4628824540e3E722090b05E33554c9738e;
    address public constant SP_NFT_ADDRESS = 0xaD8aAFE5D6e74d88f079fb10A5E82a55B93CD016;
    address public constant RSP_NFT_ADDRESS = 0xcA60E721Fa62Ec10F2452cadBDAED7Dc4B02B5DB;

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
        rSPNFT = IRevealedSPNFT(RSP_NFT_ADDRESS);
    }

    // ===================== Getters ===========================

    function testContractBalances() public {
        // get ERC20 balance of SPNFT contract
        assertEq(spToken.balanceOf(SP_NFT_ADDRESS), 1e22, "mismatch in ERC20 token balance of SPNFT");
        // get ERC20 balance of RSPNFT contract
        assertEq(spToken.balanceOf(RSP_NFT_ADDRESS), 1e22, "mismatch in ERC20 token balance of RSPNFT");
    }

    function testGetOwners() public {
        assertEq(spNFT.owner(), ME);
        assertEq(rSPNFT.owner(), address(spNFT));
    }

    /// spNFT token id must increase after mint
    function testGetTokenIdsBeforeMint() public {
        assertEq(spNFT.tokenIds(), 0);
    }

    /// spNFT token id must increase after mint
    function testGetTokenIdsAfterMint() public {
        // mint (only once)
        vm.prank(ME);
        spNFT.mint{value: 1e16}(ALICE, bytes32("nft 1"), bytes32("good nft"));
        assertEq(spNFT.tokenIds(), 1);
    }

    /// reveal token of type-1
    function testRevealTokenType1() public {
        // mint successfully
        vm.prank(ME);
        spNFT.mint{value: 1e16}(ALICE, bytes32("nft 1"), bytes32("good nft"));
        assertEq(spNFT.totalDepositedETH(), PURCHASE_PRICE);

        // reveal type before revealing
        ISPNFT.Metadata memory mdataBefore = spNFT.metadata(1);
        assertEq(mdataBefore.revealType, 0);

        vm.prank(ALICE);
        spNFT.revealToken(1, 1);

        // reveal type after revealing
        ISPNFT.Metadata memory mdataAfter = spNFT.metadata(1);
        assertEq(mdataAfter.revealType, 1);

        // skip 15 mins, sufficient enough to fulfill randomness from chainlink oracle.
        skip(1 hours);

        // get the tokenURI
        console2.log("tokenURI: ", spNFT.tokenURI(1));
    }

    /// reveal token of type-2
    function testRevealTokenType2() public {
        // mint successfully
        vm.prank(ME);
        spNFT.mint{value: 1e16}(ALICE, bytes32("nft 1"), bytes32("good nft"));
        assertEq(spNFT.totalDepositedETH(), PURCHASE_PRICE);

        // reveal type before revealing
        ISPNFT.Metadata memory mdataBefore = spNFT.metadata(1);
        assertEq(mdataBefore.revealType, 0);

        vm.prank(ALICE);
        spNFT.revealToken(2, 1);

        // reveal type after revealing
        ISPNFT.Metadata memory mdataAfter = spNFT.metadata(1);
        assertEq(mdataAfter.revealType, 2);

        // skip 15 mins, sufficient enough to fulfill randomness from chainlink oracle.
        skip(15 minutes);

        // get the tokenURI
        console2.log(spNFT.tokenURI(1));
    }
}
