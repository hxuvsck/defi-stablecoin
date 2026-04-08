// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title OracleLib
 * @author Khuslen Ganbat
 * @notice This library is used to check the Chainlink Oracle for stale data
 * If a price is stale, the function will revert, and render the BIOTAINEngine unusable — This is by design
 * We want the BIOTAINENgine to freeze if prices become stale.
 *
 * So if the Cahainlink network explodes and you have a lot of money locked in the protocol...
 *
 */

library OracleLib {}
