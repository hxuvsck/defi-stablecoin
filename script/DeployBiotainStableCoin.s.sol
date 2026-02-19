// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {BiotainStableCoin} from "../src/BiotainStableCoin.sol";
import {BIOTAINEngine} from "../src/BIOTAINEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployBiotainStableCoin is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (BiotainStableCoin, BIOTAINEngine, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerKey) =
            helperConfig.activeNetworkConfig();
        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];

        vm.startBroadcast(deployerKey);
        BiotainStableCoin bsc = new BiotainStableCoin();
        BIOTAINEngine engine = new BIOTAINEngine(tokenAddresses, priceFeedAddresses, address(bsc));

        bsc.transferOwnership(address(engine));
        vm.stopBroadcast();
        return (bsc, engine, helperConfig);
    }
}
