// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

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

library OracleLib {
    error OracleLib__StalePrice();

    // hardcoded heartbeats except Chainlink dynamic per heartbeat to pairs
    uint256 private constant TIMEOUT = 3 hours; // 10800 seconds

    function stalePriceCheck(AggregatorV3Interface priceFeed)
        public
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            priceFeed.latestRoundData();

        uint256 secondsSince = block.timestamp - updatedAt;
        if (secondsSince > TIMEOUT) revert OracleLib__StalePrice();
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}
