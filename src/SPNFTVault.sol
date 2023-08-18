// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {console2} from "forge-std/Test.sol";

contract SPNFTVault is ERC20, ReentrancyGuard, Owned {
    // using SafeTransferLib for IERC20;

    IRevealedSPNFT public revealedSPNFT;

    error InvalidDepositToken();
    error ZeroDepositAmount();
    error InsufficientDepositAmount(uint256);
    error ZeroSharesAmount();
    error InsufficientSharesAmount(uint256);
    error InvalidTokenAddress(address);

    mapping(address => uint256) public depositNFTIds;
    uint256 public totalDepositIds;     // 
    mapping(address => uint256) public totalNFTBalanceOf;

    constructor(address _revealedSPNFT, string memory _name, string memory _symbol)
        ERC20(_name, _symbol, 18)
        Owned(msg.sender)
    {
        uint256 codelen = 0;
        assembly {
            codelen := extcodesize(_token)
        }

        if (codelen == 0) {
            revert InvalidTokenAddress(_token);
        }
        token = IERC20(address(_token));
    }

    function deposit(address _token, uint256 _dAmount) external nonReentrant returns (uint256 mintedAmount) {
        // check for valid token address
        if (_token != address(token)) {
            revert InvalidDepositToken();
        }
        // check for available deposit amount
        if (_dAmount == 0) {
            revert ZeroDepositAmount();
        }

        // check for sufficient balance
        if (_dAmount > token.balanceOf(msg.sender)) {
            revert InsufficientDepositAmount(_dAmount);
        }

        // calc mint amount
        mintedAmount = _dAmount;
        if (this.totalSupply() != 0) {
            console2.log("caller: ", msg.sender);
            mintedAmount = _dAmount * this.totalSupply() / totalDepositBalances;
        }

        // update the user and total deposit balances
        depositBalances[msg.sender] += _dAmount;
        totalDepositBalances += _dAmount;

        // mint amount
        _mint(msg.sender, mintedAmount);

        // transferFrom amount
        SafeTransferLib.safeTransferFrom(ERC20(_token), msg.sender, address(this), _dAmount);
    }

    function withdraw(uint256 shares) external nonReentrant returns (uint256 wAmount) {
        // check for valid amount
        if (shares == 0) {
            revert ZeroSharesAmount();
        }
        if (this.balanceOf(msg.sender) < shares) {
            revert InsufficientSharesAmount(shares);
        }

        // calc amount to give back
        wAmount = shares * totalDepositBalances / this.totalSupply();
        console2.log("2");

        // update the user and total deposit balances
        depositBalances[msg.sender] -= wAmount;

        totalDepositBalances -= wAmount;

        // burn shares
        _burn(msg.sender, shares);

        // transfer calculated amount
        SafeTransferLib.safeTransfer(ERC20(address(token)), msg.sender, wAmount);
    }
}
