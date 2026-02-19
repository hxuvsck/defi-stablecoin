// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.19;

// We gonna be very verbose with our code documentation from now on. It is when security professionals reviewing these code when we have ton of texts of explaining what we are doing. And we can debug our issues through AI such verbose documentation would help much more lot than doing nothing to it.

// Natspec here.
/**
 * @title Biotain Stable Coin
 * @author Khuslen Ganbat
 * @notice Open-Source
 * Collateral: Exogenous (ETH & BTC)
 * Minting/Stability Mechanism: Algorithmic (Meaning it's Decentralized)
 * Relative Stability: Pegged to USD
 *
 * This is the contract meant to be governed by DSCEngine. This contract is just the ERC20 implementation of our stablecoin system.
 * This contract is purely going to be an ERC20 minting and burning sort of stuff. It's not gonna have any of the logic. The logic in here is at separate contract.
 */

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BiotainStableCoin is ERC20Burnable, Ownable {
    error BiotainStableCoin__MustBeMoreThanZero();
    error BiotainStableCoin__BurnAmountExceedsBalance();
    error BiotainStableCoin__NotZeroAddress();

    constructor() ERC20("BiotainStableCoin", "BIOTAIN") {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert BiotainStableCoin__MustBeMoreThanZero();
        }
        if (balance < _amount) {
            revert BiotainStableCoin__BurnAmountExceedsBalance();
        }
        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert BiotainStableCoin__NotZeroAddress();
        }
        if (_amount <= 0) {
            revert BiotainStableCoin__MustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}
