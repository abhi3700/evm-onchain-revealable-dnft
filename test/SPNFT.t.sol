// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {SPNFT} from "../src/SPNFT.sol";
import {RevealedSPNFT} from "../src/RevealedSPNFT.sol";

contract SPNFTTest is Test {
/// Mint
/// - P | Admin mint to Anyone (itself/others) by paying in ETH
/// - F | Admin mint to Anyone (itself/others) by not paying in ETH

/// Burn
/// - P | burn before staking
/// - F | burn after staking

// RevealedSPNFT public rSPNFT;
// SPNFT public spNFT;

// address public constant ALICE = address(0x1);

// event Minted(address indexed caller, address indexed to, uint256 indexed tokenId);
// event Burned(address indexed holder, uint256 indexed tokenId);

// function setUp() public {
//     rSPNFT =
//         new RevealedSPNFT("Revealed SP NFT", "RSPNFT", bytes("https://white-chilly-koi-665.mypinata.cloud/ipfs/"));
//     spNFT =
//         new SPNFT(address(rSPNFT), "SP NFT", "SPNFT", bytes("https://white-chilly-koi-665.mypinata.cloud/ipfs/"));

//     assertEq(spNFT.name(), "SP NFT");
//     assertEq(spNFT.symbol(), "SPNFT");

//     // for calling function
//     deal(ALICE, 100);
//     assertEq(ALICE.balance, 100);

//     // mint some nfts
//     spNFT.mint(ALICE, 1);
//     assertEq(spNFT.ownerOf(1), ALICE);
// }

// // == Reveal
// // TODO:

// // === tokenURI
// function testRevertTokenURIInvalidToken() public {
//     vm.expectRevert("NOT_MINTED");
//     spNFT.tokenURI(2);
// }

// function testTokenURIWorksForUnrevealed() public {
//     assertEq(
//         spNFT.tokenURI(1),
//         "https://white-chilly-koi-665.mypinata.cloud/ipfs/QmVzu86nv6wUbUgFxBdeQt9954yf4Ty8eFdYPfA5Cu1M8o/mystery_box.json"
//     );
// }

// function testTokenURIWorksForRevealed1() public {
//     spNFT.revealToken(1, uint8(1));
//     assertEq(spNFT.tokenURI(1), "https://white-chilly-koi-665.mypinata.cloud/ipfs/1");
// }

// // === mint

// function testRevertMintAlreadyMintedToken() public {
//     vm.expectRevert("ALREADY_MINTED");
//     spNFT.mint(ALICE, 1);
// }

// function testRevertMintByNonAdmin() public {
//     vm.prank(ALICE);
//     vm.expectRevert("UNAUTHORIZED");
//     spNFT.mint(ALICE, 2);
// }

// function testMintWorks() public {
//     vm.expectEmit(true, true, true, true);
//     emit Minted(address(this), ALICE, 2);
//     spNFT.mint(ALICE, 2);
//     assertEq(spNFT.ownerOf(2), ALICE);
// }

// function testMintTwiceSuccessively() public {
//     spNFT.mint(ALICE, 2);
//     assertEq(spNFT.ownerOf(2), ALICE);

//     spNFT.mint(ALICE, 3);
//     assertEq(spNFT.ownerOf(3), ALICE);

//     assertEq(spNFT.balanceOf(ALICE), 3);
// }

// function testMintTwiceSuccessivelyWithTimeGap() public {
//     spNFT.mint(ALICE, 2);
//     assertEq(spNFT.ownerOf(2), ALICE);
//     assertEq(block.timestamp, 1);

//     // set time to 4
//     vm.warp(4);
//     assertEq(block.timestamp, 4);
//     spNFT.mint(ALICE, 3);
//     assertEq(spNFT.ownerOf(3), ALICE);

//     // forwarded time by 10s from last tstamp
//     skip(10);
//     spNFT.mint(ALICE, 4);
//     assertEq(spNFT.ownerOf(4), ALICE);

//     assertEq(spNFT.balanceOf(ALICE), 4);
// }

// // === burn

// /// address who doesn't own the nft token id, can't burn
// function testBurnFailsByNonOwner() public {
//     vm.expectRevert(abi.encodeWithSignature("NotOwner(address)", address(this)));
//     spNFT.burn(1);
// }

// /// address who owns the nft token id, can only burn
// function testBurnWorks() public {
//     vm.expectEmit(true, true, true, true);
//     emit Burned(ALICE, 1);
//     vm.prank(ALICE);
//     spNFT.burn(1);
//     assertEq(spNFT.balanceOf(ALICE), 0);
// }
}
