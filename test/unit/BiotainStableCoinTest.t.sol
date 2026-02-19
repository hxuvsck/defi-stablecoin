// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {BiotainStableCoin} from "../../src/BiotainStableCoin.sol";
import {DeployBiotainStableCoin} from "../../script/DeployBiotainStableCoin.s.sol";

contract BiotainStableCoinTest is Test {
    BiotainStableCoin bsc;

    function setUp() external {
        bsc = new BiotainStableCoin();
    }

    function testIsMinting() public {}

    function testIsBurning() public {}
}
