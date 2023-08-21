// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {SPToken} from "../src/SPToken.sol";
import {SPNFT} from "../src/SPNFT.sol";
import {RevealedSPNFT} from "../src/RevealedSPNFT.sol";

contract SPNFTTest is Test {
    SPToken public spToken;
    RevealedSPNFT public rSPNFT;
    SPNFT public spNFT;

    uint256 public constant PURCHASE_PRICE = 5e15; // 0.005 ETH or ERC20

    address public constant ZERO_ADDRESS = address(0);
    address public constant ALICE = address(0xA11CE);
    address public constant BOB = address(0xB0B);
    address public constant CHARLIE = address(0xC11A11E);

    // ===================== EVENT ===========================
    event Minted(address indexed mintedBy, address indexed mintedTo, uint256 indexed tokenId);
    event Burned(address indexed BurnedBy, uint256 indexed tokenId);
    event RequestSent(uint256 indexed requestId, uint32 numWords);
    event RequestFulfilled(uint256 indexed requestId, uint256[] randomWords);
    event ETHRefunded(address indexed mintedBy, uint256 ethAmount);

    // ===================== CONSTRUCTOR ===========================
    function setUp() public {
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

        address rSPNFTAddress = address(spNFT.revealedSPNFT());

        assertEq(spToken.balanceOf(address(this)), 1e24, "mismatch in owner's balance");

        // NOTE: There can be 1 common function created for transferring tokens at once.
        // 3. transfer 10k tokens to SPNFT contract
        spToken.transfer(address(spNFT), 1e22);
        assertEq(spToken.balanceOf(address(spNFT)), 1e22, "mismatch in transfer tokens to SPNFT");
        // 4. transfer 10k tokens to RSPNFT contract
        spToken.transfer(rSPNFTAddress, 1e22);
        assertEq(spToken.balanceOf(rSPNFTAddress), 1e22, "mismatch in transfer tokens to RSPNFT");
    }

    /// deploy SPNFT with empty name fails
    function testSetUpEmptyName() public {
        vm.expectRevert(SPNFT.EmptyNameOrSymbol.selector);
        spNFT = new SPNFT(
            "", 
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
    }

    /// deploy SPNFT with empty symbol fails
    function testSetUpEmptySymbol() public {
        vm.expectRevert(SPNFT.EmptyNameOrSymbol.selector);
        spNFT = new SPNFT(
            "SP NFT", 
            "",  
            ["#634e34","#3d671d","#2e536f","#1c7847"],
            ["#583322","#1e90ff","#eeb2d2","#4b0082"],
            ["#f5f3e7","#ffcc99","#fde0d9","#808000"],
            ["#d291bc","#ff0000","#ff7f50","#800020"],
            uint64(4562),
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            address(spToken)
        );
    }
    // deploy SPNFT fails with atleast 1 attribute option values as empty eyes

    function testSetUpEmptyAttributeOptionsEyes() public {
        vm.expectRevert(SPNFT.AttributeOptionsMustBeFourAndNonEmptyElements.selector);
        spNFT = new SPNFT(
            "SP NFT", 
            "SPNFT",  
            ["","#3d671d","#2e536f","#1c7847"],
            ["#583322","#1e90ff","#eeb2d2","#4b0082"],
            ["#f5f3e7","#ffcc99","#fde0d9","#808000"],
            ["#d291bc","#ff0000","#ff7f50","#800020"],
            uint64(4562),
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            address(spToken)
        );
    }

    // deploy SPNFT fails with atleast 1 attribute option values as empty hair

    function testSetUpEmptyAttributeOptionsHair() public {
        vm.expectRevert(SPNFT.AttributeOptionsMustBeFourAndNonEmptyElements.selector);
        spNFT = new SPNFT(
            "SP NFT", 
            "SPNFT",  
            ["#634e34","#3d671d","#2e536f","#1c7847"],
            ["#583322","#1e90ff","","#4b0082"],
            ["#f5f3e7","#ffcc99","#fde0d9","#808000"],
            ["#d291bc","#ff0000","#ff7f50","#800020"],
            uint64(4562),
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            address(spToken)
        );
    }

    // deploy SPNFT fails with atleast 1 attribute option values as empty face

    function testSetUpEmptyAttributeOptionsFace() public {
        vm.expectRevert(SPNFT.AttributeOptionsMustBeFourAndNonEmptyElements.selector);
        spNFT = new SPNFT(
            "SP NFT", 
            "SPNFT",  
            ["#634e34","#3d671d","#2e536f","#1c7847"],
            ["#583322","#1e90ff","#eeb2d2","#4b0082"],
            ["#f5f3e7","","#fde0d9","#808000"],
            ["#d291bc","#ff0000","#ff7f50","#800020"],
            uint64(4562),
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            address(spToken)
        );
    }

    // deploy SPNFT fails with atleast 1 attribute option values as empty mouth
    function testSetUpEmptyAttributeOptionsMouth() public {
        vm.expectRevert(SPNFT.AttributeOptionsMustBeFourAndNonEmptyElements.selector);
        spNFT = new SPNFT(
            "SP NFT", 
            "SPNFT",  
            ["#634e34","#3d671d","#2e536f","#1c7847"],
            ["#583322","#1e90ff","#eeb2d2","#4b0082"],
            ["#f5f3e7","#ffcc99","#fde0d9","#808000"],
            ["#d291bc","#ff0000","#ff7f50",""],
            uint64(4562),
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            address(spToken)
        );
    }

    // deploy SPNFT fails with invalid contract address
    function testSetUpInvalidTokenAddress() public {
        // get EOA address from `$ cast wallet new` command
        vm.expectRevert(abi.encodeWithSignature("InvalidERC20(address)", 0x0D0E8357424B4E9415EC19305A793aC2839471FD));
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
            0x0D0E8357424B4E9415EC19305A793aC2839471FD
        );
    }

    // ===================== Getters ===========================

    // get token URI for token 0 i.e. by default it's mystery box
    function testGetTokenURI() public {
        // mint successfully
        spNFT.mint{value: 6e18}(ALICE, bytes32("nft 1"), bytes32("good nft"));

        uint256 tokenIdMinted = spNFT.tokenIds();
        string memory tokenUri = spNFT.tokenURI(tokenIdMinted);
        assertEq(
            tokenUri,
            "data:application/json;base64,eyJuYW1lIjogIlNQMDAxIiwiZGVzY3JpcHRpb24iOiJTdG9yeSBQcm90b2NvbCBNeXN0ZXJ5IEJveCBORlQiLCJpbWFnZSI6ICI8c3ZnIHdpZHRoPVwiODAwcHhcIiBoZWlnaHQ9XCI4MDBweFwiIHZpZXdCb3g9XCIwIDAgMjQgMjRcIiB4bWxucz1cImh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnXCIgZmlsbD1cIiNGNDgwMjRcIiBzdHJva2U9XCIjMDAwMDAwXCIgc3Ryb2tlLXdpZHRoPVwiMVwiIHN0cm9rZS1saW5lY2FwPVwicm91bmRcIiBzdHJva2UtbGluZWpvaW49XCJtaXRlclwiPjxwb2x5Z29uIHBvaW50cz1cIjMgMTYgMyA4IDEyIDE0IDIxIDggMjEgMTYgMTIgMjIgMyAxNlwiIHN0cm9rZS13aWR0aD1cIjBcIiBvcGFjaXR5PVwiMC4xXCIgZmlsbD1cIiMwNTljZjdcIj48L3BvbHlnb24+PHBvbHlnb24gcG9pbnRzPVwiMjEgOCAyMSAxNiAxMiAyMiAzIDE2IDMgOCAxMiAyIDIxIDhcIj48L3BvbHlnb24+PHBvbHlsaW5lIHBvaW50cz1cIjMgOCAxMiAxNCAxMiAyMlwiIHN0cm9rZS1saW5lY2FwPVwicm91bmRcIj48L3BvbHlsaW5lPjxsaW5lIHgxPVwiMjFcIiB5MT1cIjhcIiB4Mj1cIjEyXCIgeTI9XCIxNFwiIHN0cm9rZS1saW5lY2FwPVwicm91bmRcIj48L2xpbmU+PC9zdmc+IiwiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAiU2hhcGUiLCJ2YWx1ZSI6ICJDdWJlIn0seyJ0cmFpdF90eXBlIjogIkJvcmRlcnMiLCJ2YWx1ZSI6ICJCbGFjayJ9LHsidHJhaXRfdHlwZSI6ICJGaWxsZWQiLCJ2YWx1ZSI6ICJPcmFuZ2UifV19"
        );
    }

    function testRevertGetTokenUriOfNonMinted() public {
        vm.expectRevert("NOT_MINTED");
        spNFT.tokenURI(0);
    }

    function testGetTokenIDsMinted() public {
        // mint successfully
        spNFT.mint{value: 6e18}(ALICE, bytes32("nft 1"), bytes32("good nft"));
        assertEq(spNFT.tokenIds(), 1);
    }

    /// get total deposited ETH
    function testGetTotalDepositedETH() public {
        assertEq(spNFT.totalDepositedETH(), 0);
    }

    // get name
    function testGetName() public {
        assertEq(spNFT.name(), "SP NFT");
    }

    // get name
    function testGetSymbol() public {
        assertEq(spNFT.symbol(), "SPNFT");
    }

    // ===================== Setters ===========================

    // for receiving ether refund
    receive() external payable {}

    // ------mint-------
    /// Admin mint to Anyone (itself/others) via fuzzing address by paying in ETH > PURCHASE_PRICE
    // function testMintToAnyonePayingETH(address to) public {
    function testMintToAnyonePayingETH(address to, bytes32 _name, bytes32 _description) public {
        vm.assume(to != ZERO_ADDRESS);
        vm.assume(_name != bytes32(""));
        vm.assume(_description != bytes32(""));

        // vm.expectEmit(true, false, false, true);
        emit ETHRefunded(address(this), 5995000000000000000);

        vm.expectEmit(true, true, false, true);
        emit Minted(address(this), to, spNFT.tokenIds() + 1);

        spNFT.mint{value: 6e18}(to, bytes32("nft 1"), bytes32("good nft"));
        assertEq(spNFT.totalDepositedETH(), PURCHASE_PRICE);
    }

    /// Non-Admin (fuzzed with) can't mint to Anyone (itself/others) by paying in ETH
    function testRevertNonAdminMintToAnyonePayingETH(address to) public {
        vm.assume(to != ZERO_ADDRESS);
        vm.expectRevert("Only callable by owner");
        hoax(to, 6e18);
        spNFT.mint{value: 6e18}(to, bytes32("nft 1"), bytes32("good nft"));
    }

    /// Admin can't mint to ZERO Address by paying in ETH
    function testRevertMintToZeroAddress() public {
        vm.expectRevert(SPNFT.ZeroAddress.selector);
        spNFT.mint{value: 6e18}(ZERO_ADDRESS, bytes32("nft 1"), bytes32("good nft"));
    }

    /// Admin can't mint Token (w Empty name) to Anyone (itself/others) by paying in ETH
    function testRevertMintTokenWEmptyName() public {
        vm.expectRevert(SPNFT.EmptyName.selector);
        spNFT.mint{value: 6e18}(ALICE, bytes32(""), bytes32("good nft"));
    }

    /// Admin can't mint Token (w Empty description) to Anyone (itself/others) by paying in ETH
    function testRevertMintTokenWEmptyDescription() public {
        vm.expectRevert(SPNFT.EmptyDescription.selector);
        spNFT.mint{value: 6e18}(ALICE, bytes32("nft 1"), bytes32(""));
    }

    /// Admin can't mint to Anyone (itself/others) by paying in ETH less than PURCHASE_PRICE
    function testRevertMintInsufficientETH(address to) public {
        vm.assume(to != ZERO_ADDRESS);
        vm.expectRevert(SPNFT.InsufficientETHForMinting.selector);
        spNFT.mint{value: 4e15}(to, bytes32("nft 1"), bytes32("good nft"));
    }

    // ------burn-------
    /// Token owner burns after mint
    function testBurnAfterMint() public {
        // mint successfully
        spNFT.mint{value: 6e18}(ALICE, bytes32("nft 1"), bytes32("good nft"));

        // burn
        vm.expectEmit(true, false, false, true);
        emit Burned(ALICE, 1);
        vm.prank(ALICE);
        spNFT.burn(1);
    }

    /// Account (not the Token owner of given id) fails to burn the token id after mint
    function testRevertOthersBurnAfterMintedToAlice(address by) public {
        vm.assume(by != ALICE);

        // mint successfully
        spNFT.mint{value: 6e18}(ALICE, bytes32("nft 1"), bytes32("good nft"));

        vm.expectRevert(abi.encodeWithSignature("NotOwner(address)", by));
        vm.prank(by);
        spNFT.burn(1);
    }

    /// TODO: Token owner can't burn if token id is staked
    function testBurnRevertsAfterStaked() public {}

    // ------stake-------

    /// User with tokens revealed as type 1 can only stake
    function testStake() public {}

    // ------unstake-------
    /// User with staked token can only unstake & claim rewards simultaneously
    function testUnstake() public {}
}
