// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {BiotainStableCoin} from "../src/BiotainStableCoin.sol";

contract DeployBiotainStableCoin is Script {
    function run() external returns (BiotainStableCoin) {
        vm.startBroadcast();
        BiotainStableCoin biotainStableCoin = new BiotainStableCoin();
        vm.stopBroadcast();
        return biotainStableCoin;
    }
}
