// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployBiotainStableCoin} from "../../script/DeployBiotainStableCoin.s.sol";
import {BiotainStableCoin} from "../../src/BiotainStableCoin.sol";
import {BIOTAINEngine} from "../../src/BIOTAINEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract BIOTAINEngineTest is Test {
    DeployBiotainStableCoin deployer;
    BiotainStableCoin bsc;
    BIOTAINEngine engine;
    HelperConfig config;
    address ethUsdPriceFeed;
    address weth;

    function setUp() public {
        deployer = new DeployBiotainStableCoin();
        (bsc, engine, config) = deployer.run();
        (ethUsdPriceFeed,, weth,,) = config.activeNetworkConfig();
    }

    // First test is to check the price feed retrieval (getFunc) which is GetUsdValue. It has some weird math functions that needs to be checked

    ////////////////////////
    //// Price tests ///////
    ////////////////////////

    //Added HelperConfig to run function on deploy script by returning config value to get easily testing priceFeed addresses
    function testGetUsdValue() public {
        uint256 ethAmount = 15e18;
        // 15e18 * 2000/ETH = 30'000e18
        uint256 expectedUsd = 30000e18;
        uint256 actualUsd = engine.getUsdValue(weth, ethAmount);
        assertEq(expectedUsd, actualUsd);
    }
}
