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
 * @title Decentralized Stable Coin
 * @author Khuslen Ganbat
 * @notice Open-Source
 * Collateral: Exogenous (ETH & BTC)
 * Minting/Stability Mechanism: Algorithmic (Meaning it's Decentralized)
 * Relative Stability: Pegged to USD
 *
 * This is the contract meant to be governed by DSCEngine. This contract is just the ERC20 implementation of our stablecoin system.
 * This contract is purely going to be an ERC20 minting and burning sort of stuff. It's not gonna have any of the logic. The logic in here is at separate contract.
 */

contract DecentralizedStableCoin {

}
