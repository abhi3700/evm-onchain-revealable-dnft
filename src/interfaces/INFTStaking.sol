// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @notice Interface for RevealedSPNFT
interface INFTStaking {
    struct Stake {
        bool isStaked;
        uint32 stakedTime; // time from when the accrued interest calculation starts, reset the time (to now) when claimed
    }

    function stakedTokenIds(uint256 tokenId) external view returns (Stake memory);
    function getTokenIdStatus(uint256 _tokenId) external view returns (bool);
}
