// SPDX-License-Identifier: MIT

// Narrow down the way we call function

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {BIOTAINEngine} from "../../src/BIOTAINEngine.sol";
import {BiotainStableCoin} from "../../src/BiotainStableCoin.sol";

contract Handler is Test {
    BIOTAINEngine bsce;
    BiotainStableCoin bsc;
    constructor() {BIOTAINEngine _biotainEngine, BiotainStableCoin _bsc} {
        bsce = _biotainEngine;
        bsc = _bsc;
    }

    // redeemCollateral <-


    // and now, by making the first function in handler and implementing it to invariant stateful fuzz testing,
    // test will not go for a target contract as a random ones, but with only this function to revert.
    function depositCollateral(address collateral, uint256 amountCollateral) public {
        bsce.depositCollateral(collateral, amountCollateral);

    }
}
