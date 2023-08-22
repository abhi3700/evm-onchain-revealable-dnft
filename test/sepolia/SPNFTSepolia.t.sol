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
contract SPNFTSepoliaTest is Test {
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
        // get ERC20 balance of SPNFT contract
        assertEq(spToken.balanceOf(SP_NFT_ADDRESS), 1e22, "mismatch in ERC20 token balance of SPNFT");
    }

    function testGetOwners() public {
        assertEq(spNFT.owner(), ME);
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

    // ===================== Setters ===========================

    // -------Reveal Token------------
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
        // Fullfill randomness still not happened.
        skip(15 minutes);

        // get the tokenURI
        // console2.log("tokenURI: ", spNFT.tokenURI(1));

        // if not eq, then it's revealed.
        assertNotEq(
            spNFT.tokenURI(1),
            "data:application/json;base64,eyJuYW1lIjogIlNQMDAxIiwiZGVzY3JpcHRpb24iOiJTdG9yeSBQcm90b2NvbCBNeXN0ZXJ5IEJveCBORlQiLCJpbWFnZSI6ICI8c3ZnIHdpZHRoPVwiODAwcHhcIiBoZWlnaHQ9XCI4MDBweFwiIHZpZXdCb3g9XCIwIDAgMjQgMjRcIiB4bWxucz1cImh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnXCIgZmlsbD1cIiNGNDgwMjRcIiBzdHJva2U9XCIjMDAwMDAwXCIgc3Ryb2tlLXdpZHRoPVwiMVwiIHN0cm9rZS1saW5lY2FwPVwicm91bmRcIiBzdHJva2UtbGluZWpvaW49XCJtaXRlclwiPjxwb2x5Z29uIHBvaW50cz1cIjMgMTYgMyA4IDEyIDE0IDIxIDggMjEgMTYgMTIgMjIgMyAxNlwiIHN0cm9rZS13aWR0aD1cIjBcIiBvcGFjaXR5PVwiMC4xXCIgZmlsbD1cIiMwNTljZjdcIj48L3BvbHlnb24+PHBvbHlnb24gcG9pbnRzPVwiMjEgOCAyMSAxNiAxMiAyMiAzIDE2IDMgOCAxMiAyIDIxIDhcIj48L3BvbHlnb24+PHBvbHlsaW5lIHBvaW50cz1cIjMgOCAxMiAxNCAxMiAyMlwiIHN0cm9rZS1saW5lY2FwPVwicm91bmRcIj48L3BvbHlsaW5lPjxsaW5lIHgxPVwiMjFcIiB5MT1cIjhcIiB4Mj1cIjEyXCIgeTI9XCIxNFwiIHN0cm9rZS1saW5lY2FwPVwicm91bmRcIj48L2xpbmU+PC9zdmc+IiwiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAiU2hhcGUiLCJ2YWx1ZSI6ICJDdWJlIn0seyJ0cmFpdF90eXBlIjogIkJvcmRlcnMiLCJ2YWx1ZSI6ICJCbGFjayJ9LHsidHJhaXRfdHlwZSI6ICJGaWxsZWQiLCJ2YWx1ZSI6ICJPcmFuZ2UifV19"
        );
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
        // Fullfill randomness still not happened.
        skip(15 minutes);

        // get the tokenURI
        // console2.log("tokenURI: ", spNFT.tokenURI(1));

        // Here, the revealedSPNFT contract hasn't minted token 1 yet.
        // assertNotEq(
        //     rSPNFT.tokenURI(1),
        //     "data:application/json;base64,eyJuYW1lIjogIlNQMDAxIiwiZGVzY3JpcHRpb24iOiJTdG9yeSBQcm90b2NvbCBNeXN0ZXJ5IEJveCBORlQiLCJpbWFnZSI6ICI8c3ZnIHdpZHRoPVwiODAwcHhcIiBoZWlnaHQ9XCI4MDBweFwiIHZpZXdCb3g9XCIwIDAgMjQgMjRcIiB4bWxucz1cImh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnXCIgZmlsbD1cIiNGNDgwMjRcIiBzdHJva2U9XCIjMDAwMDAwXCIgc3Ryb2tlLXdpZHRoPVwiMVwiIHN0cm9rZS1saW5lY2FwPVwicm91bmRcIiBzdHJva2UtbGluZWpvaW49XCJtaXRlclwiPjxwb2x5Z29uIHBvaW50cz1cIjMgMTYgMyA4IDEyIDE0IDIxIDggMjEgMTYgMTIgMjIgMyAxNlwiIHN0cm9rZS13aWR0aD1cIjBcIiBvcGFjaXR5PVwiMC4xXCIgZmlsbD1cIiMwNTljZjdcIj48L3BvbHlnb24+PHBvbHlnb24gcG9pbnRzPVwiMjEgOCAyMSAxNiAxMiAyMiAzIDE2IDMgOCAxMiAyIDIxIDhcIj48L3BvbHlnb24+PHBvbHlsaW5lIHBvaW50cz1cIjMgOCAxMiAxNCAxMiAyMlwiIHN0cm9rZS1saW5lY2FwPVwicm91bmRcIj48L3BvbHlsaW5lPjxsaW5lIHgxPVwiMjFcIiB5MT1cIjhcIiB4Mj1cIjEyXCIgeTI9XCIxNFwiIHN0cm9rZS1saW5lY2FwPVwicm91bmRcIj48L2xpbmU+PC9zdmc+IiwiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAiU2hhcGUiLCJ2YWx1ZSI6ICJDdWJlIn0seyJ0cmFpdF90eXBlIjogIkJvcmRlcnMiLCJ2YWx1ZSI6ICJCbGFjayJ9LHsidHJhaXRfdHlwZSI6ICJGaWxsZWQiLCJ2YWx1ZSI6ICJPcmFuZ2UifV19"
        // );
    }

    function testRevertRevealAlreadyRevealedToken() public {
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

        vm.expectRevert(SPNFT.AlreadyRevealed.selector);
        vm.prank(ALICE);
        spNFT.revealToken(2, 1);
    }

    function testRevertNonTokenOwnerRevealToken(address revealBy) public {
        vm.assume(revealBy != ALICE);

        // mint successfully
        vm.prank(ME);
        spNFT.mint{value: 1e16}(ALICE, bytes32("nft 1"), bytes32("good nft"));

        // reveal type before revealing
        ISPNFT.Metadata memory mdataBefore = spNFT.metadata(1);
        assertEq(mdataBefore.revealType, 0);

        vm.expectRevert(abi.encodeWithSignature("NotTokenOwner()"));
        vm.prank(revealBy);
        spNFT.revealToken(2, 1);
    }

    function testRevertRevealTokenOfInvalidType(uint8 revealType) public {
        vm.assume(revealType != 1);
        vm.assume(revealType != 2);

        // mint successfully
        vm.prank(ME);
        spNFT.mint{value: 1e16}(ALICE, bytes32("nft 1"), bytes32("good nft"));

        // reveal type before revealing
        ISPNFT.Metadata memory mdataBefore = spNFT.metadata(1);
        assertEq(mdataBefore.revealType, 0);

        vm.expectRevert(SPNFT.InvalidRevealType.selector);
        vm.prank(ALICE);
        spNFT.revealToken(revealType, 1);

        vm.expectRevert(SPNFT.InvalidRevealType.selector);
        vm.prank(ALICE);
        spNFT.revealToken(revealType, 1);
    }

    // -------Stake------------

    /// token owner is able to stake revealed (type-1) token id
    function testStakeRevealedTokenType1() public {
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

        // alice can stake now
        vm.expectEmit(true, false, false, true);
        emit Staked(ALICE, 1);
        vm.prank(ALICE);
        spNFT.stake(1);
    }

    /// token owner is able to stake revealed (type-1) token id, not others
    function testRevertStakeRevealedTokenTypeNot1() public {
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

        // alice can't stake now as reveal type is 2, so, stake into RevealedSPNFT
        vm.expectRevert(abi.encodeWithSignature("TokenIdMustBeType1ForStake(uint256)", 1));
        vm.prank(ALICE);
        spNFT.stake(1);
    }

    /// token owner is not able to stake unrevealed token id
    function testRevertStakeUnrevealedToken() public {
        // mint successfully
        vm.prank(ME);
        spNFT.mint{value: 1e16}(ALICE, bytes32("nft 1"), bytes32("good nft"));
        assertEq(spNFT.totalDepositedETH(), PURCHASE_PRICE);

        // reveal type before revealing
        ISPNFT.Metadata memory mdataBefore = spNFT.metadata(1);
        assertEq(mdataBefore.revealType, 0);

        // alice can't stake now
        vm.expectRevert(abi.encodeWithSignature("TokenIdMustBeType1ForStake(uint256)", 1));
        vm.prank(ALICE);
        spNFT.stake(1);
    }

    /// only token owner is able to stake revealed token id
    function testRevertNonTokenOwnerStakeRevealedToken(address stakeBy) public {
        vm.assume(stakeBy != ALICE);

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

        // others can't stake ALICE's token
        vm.expectRevert(abi.encodeWithSignature("NotTokenOwner()"));
        vm.prank(stakeBy);
        spNFT.stake(1);
    }

    // -------Unstake------------

    function testUnstakeStakedToken() public {
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

        // alice can stake now
        vm.expectEmit(true, false, false, true);
        emit Staked(ALICE, 1);
        vm.prank(ALICE);
        spNFT.stake(1);

        // after 1 week
        skip(1 weeks);

        // get erc20 balance of alice before unstake
        uint256 balBefore = spToken.balanceOf(ALICE);

        // alice can unstake now
        vm.prank(ALICE);
        spNFT.unstake(1);

        // get erc20 balance of alice before unstake
        uint256 balAfter = spToken.balanceOf(ALICE);

        // check if unstaked
        assertFalse(spNFT.stakedTokenIds(1).isStaked, "token didn't get unstaked");

        // check for rewards
        assertGe(balAfter, balBefore, "there should be some rewards claimed if staked for some time");
    }

    /// Revert Unstake Non minted tokens
    function testRevertUnstakeNonMintedToken(uint256 tokenId) public {
        vm.assume(tokenId != 1);

        vm.expectRevert("NOT_MINTED");
        spNFT.unstake(tokenId);
    }

    /// Revert unstake of tokens by the caller who are not owner of given token id
    function testRevertUnstakeByNonTokenOwner(address unstakeBy) public {
        vm.assume(unstakeBy != ALICE);

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

        // alice can stake now
        vm.expectEmit(true, false, false, true);
        emit Staked(ALICE, 1);
        vm.prank(ALICE);
        spNFT.stake(1);

        // after 1 week
        skip(1 weeks);

        vm.expectRevert(abi.encodeWithSignature("NotTokenOwner()"));
        vm.prank(unstakeBy);
        spNFT.unstake(1);
    }

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
        vm.expectRevert(abi.encodeWithSignature("NotStaked()"));
        vm.prank(ALICE);
        spNFT.unstake(1);

        // get erc20 balance of alice before unstake
        uint256 balAfter = spToken.balanceOf(ALICE);

        // check for rewards
        assertEq(balAfter, balBefore);
    }
}
