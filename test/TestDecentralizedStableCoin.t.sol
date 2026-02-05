// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {DeployDecentralizedStableCoin} from "../script/DeployDecentralizedStableCoin.s.sol";

contract TestDecentralizedStableCoin is Test {
    DecentralizedStableCoin decentralizedStableCoin;

    function setUp() external {
        DeployDecentralizedStableCoin deployDecentralizedStableCoin = new DeployDecentralizedStableCoin();
        decentralizedStableCoin = deployDecentralizedStableCoin.run();
    }

    function testIsMinting() public {}

    function testIsBurning() public {}
}
