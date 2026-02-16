// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {BiotainStableCoin} from "../src/BiotainStableCoin.sol";
import {BIOTAINEngine} from "../src/BIOTAINEngine.sol";

contract DeployBiotainStableCoin is Script {
    function run() external returns (BiotainStableCoin, BIOTAINEngine) {
        vm.startBroadcast();
        BiotainStableCoin bsc = new BiotainStableCoin();
        BIOTAINEngine engine = new BIOTAINEngine();
        vm.stopBroadcast();
        return (bsc, engine);
    }
}
