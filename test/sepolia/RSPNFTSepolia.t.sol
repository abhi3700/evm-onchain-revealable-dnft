// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {ISPToken} from "../../src/interfaces/ISPToken.sol";
import {ISPNFT} from "../../src/interfaces/ISPNFT.sol";
import {IRevealedSPNFT} from "../../src/interfaces/IRevealedSPNFT.sol";

// import {SPToken} from "../../src/SPToken.sol";
import {SPNFT} from "../../src/SPNFT.sol";
// import {RevealedSPNFT} from "../../src/RevealedSPNFT.sol";

/* 
    This contract is mainly to test the chainlink VRF based functions for randomization on Sepolia network using `fork-url`:
    - `revealToken`
    - `stake`
    - `unstake`
*/
contract RSPNFTSepoliaTest is Test {
    ISPToken public spToken;
    IRevealedSPNFT public rSPNFT;
    ISPNFT public spNFT;

    uint256 public constant PURCHASE_PRICE = 5e15; // 0.005 ETH or ERC20

    address public constant ZERO_ADDRESS = address(0);
    address public constant ALICE = address(0xA11CE);
    address public constant BOB = address(0xB0B);

    // EOAs on Sepolia contract
    address public constant ME = 0x0370D871f1D4B256E753120221F3Be87A40bd246;

    // Deploy contracts on Sepolia network
    address public constant SP_TOKEN_ADDRESS = 0x199e8a373431bb894a4108BC5749A682Ee6D76Ab;
    address public constant SP_NFT_ADDRESS = 0x8B2B82cb1Ae16F6b9Bd825078c0c31D3BeB8c45A;
    address public constant RSP_NFT_ADDRESS = 0xF63A2898AbfB69f8A35E381793856E0e528DCFdF;

    // ===================== EVENT ===========================
    event Minted(address indexed mintedBy, address indexed mintedTo, uint256 indexed tokenId);
    event Burned(address indexed BurnedBy, uint256 indexed tokenId);
    event RequestSent(uint256 indexed requestId, uint32 numWords);
    event RequestFulfilled(uint256 indexed requestId, uint256[] randomWords);
    event ETHRefunded(address indexed mintedBy, uint256 ethAmount);
    event Staked(address indexed user, uint256 indexed tokenId);
    event Unstaked(address indexed user, uint256 indexed tokenId);

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
        // get ERC20 balance of RSPNFT contract
        assertEq(spToken.balanceOf(RSP_NFT_ADDRESS), 1e22, "mismatch in ERC20 token balance of RSPNFT");
    }

    function testGetOwners() public {
        assertEq(rSPNFT.owner(), address(spNFT));
    }

    /// spNFT token id must increase after mint
    function testGetTokenIdsBeforeMint() public {
        assertEq(spNFT.tokenIds(), 0);
    }

    // -------Stake------------

    /// token owner is able to stake revealed (type-2) token id
    function testRevertStakeRevealedWTokenType2() public {
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

        // alice can't stake now as `fulfill` random is not called yet.
        vm.expectRevert("NOT_MINTED");
        vm.prank(ALICE);
        rSPNFT.stake(1);
    }

    // -------Unstake--------
    /// Revert unstaking tokens that are not yet staked
    function testRevertUnstakeUnstakedToken() public {
        // mint successfully
        vm.prank(ME);
        spNFT.mint{value: 1e16}(ALICE, bytes32("nft 1"), bytes32("good nft"));
        assertEq(spNFT.totalDepositedETH(), PURCHASE_PRICE);

        // reveal type before revealing
        ISPNFT.Metadata memory mdataBefore = spNFT.metadata(1);
        assertEq(mdataBefore.revealType, 0);

        vm.prank(ALICE);
        spNFT.revealToken(1, 1);

        // get erc20 balance of alice before unstake
        uint256 balBefore = spToken.balanceOf(ALICE);

        // alice can't unstake now as it's not staked yet
        vm.expectRevert("NOT_MINTED");
        vm.prank(ALICE);
        rSPNFT.unstake(1);

        // get erc20 balance of alice before unstake
        uint256 balAfter = spToken.balanceOf(ALICE);

        // check for rewards
        assertEq(balAfter, balBefore);
    }
}
