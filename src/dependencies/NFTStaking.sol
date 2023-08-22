// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ERC721} from "./ERC721.sol";
import {ERC20} from "./ERC20.sol";
import {SafeTransferLib} from "../libs/SafeTransferLib.sol";
// import {console2} from "forge-std/Test.sol";

abstract contract NFTStaking is ERC721 {
    using SafeTransferLib for ERC20;

    uint8 public constant APY = 5;
    uint256 public constant PURCHASE_PRICE = 5e15; // 0.005 ETH or ERC20

    ERC20 public erc20Token;

    struct Stake {
        bool isStaked;
        uint32 stakedTime; // time from when the accrued interest calculation starts, reset the time (to now) when claimed
    }

    // tokenId => Stake
    mapping(uint256 => Stake) public stakedTokenIds;

    event Staked(address indexed user, uint256 indexed tokenId);
    event Unstaked(address indexed user, uint256 indexed tokenId);

    error NotStaked();
    error AlreadyStaked();
    error NotTokenOwner();

    constructor(string memory _n, string memory _s, address _erc20TokenAddress) ERC721(_n, _s) {
        erc20Token = ERC20(_erc20TokenAddress);
    }

    // ===================== Getters ===========================

    // function getTotalStaked() external view returns (uint256) {}
    function getTokenIdStatus(uint256 _tokenId) external view returns (bool) {
        return stakedTokenIds[_tokenId].isStaked;
    }

    // ===================== Setters ===========================
    /// @dev stake function
    function _stake(uint256 _tokenId) internal {
        // check for valid token id: owned or not by caller
        ownerOf(_tokenId);

        // check for correct owner
        _isOwnerOf(_tokenId);

        // By default the type is 2 as minted by SPNFT after contract deployment settings for the project.
        // So, no need to check for the reveal type.
        // as the type 2 is burned here & moved to other contract

        Stake storage stake = stakedTokenIds[_tokenId];

        // check if token id already staked or not
        if (stake.isStaked) {
            revert AlreadyStaked();
        }

        stake.isStaked = true;
        stake.stakedTime = uint32(block.timestamp);

        emit Staked(msg.sender, _tokenId);
    }

    /// @dev unstake & claim rewards token Id
    /// @param _tokenId token Id for which accrued interest rewards are to be claimed & then unstake
    function _unstake(uint256 _tokenId) internal {
        // check for valid token id whether minted or not
        ownerOf(_tokenId);

        // check for correct owner
        _isOwnerOf(_tokenId);

        // check if token id staked or not
        if (!stakedTokenIds[_tokenId].isStaked) {
            revert NotStaked();
        }

        uint256 accruedInterest = (PURCHASE_PRICE * APY) / 100;

        // reset to zero.
        delete stakedTokenIds[_tokenId];

        // mint the accrued interest
        erc20Token.safeTransfer(msg.sender, accruedInterest);

        emit Unstaked(msg.sender, _tokenId);
    }

    function _isOwnerOf(uint256 id) internal view {
        // check for the correct owner
        if (ownerOf(id) != msg.sender) {
            revert NotTokenOwner();
        }
    }
}
