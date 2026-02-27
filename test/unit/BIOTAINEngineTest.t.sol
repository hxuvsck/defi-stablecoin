// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployBiotainStableCoin} from "../../script/DeployBiotainStableCoin.s.sol";
import {BiotainStableCoin} from "../../src/BiotainStableCoin.sol";
import {BIOTAINEngine} from "../../src/BIOTAINEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract BIOTAINEngineTest is Test {
    DeployBiotainStableCoin deployer;
    BiotainStableCoin bsc;
    BIOTAINEngine engine;
    HelperConfig config;
    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    address weth;
    address wbtc;

    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;

    function setUp() public {
        deployer = new DeployBiotainStableCoin();
        (bsc, engine, config) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc,) = config.activeNetworkConfig();

        // for better test, we made a mint for user in setUp
    }

    // First test is to check the price feed retrieval (getFunc) which is GetUsdValue. It has some weird math functions that needs to be checked

    ///////////////////////////////
    //// Constructor tests ///////
    //////////////////////////////

    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function testRevertsIfTokenLengthDoesntMatchPriceFeeds() public {
        tokenAddresses.push(weth);
        priceFeedAddresses.push(ethUsdPriceFeed);
        priceFeedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(BIOTAINEngine.BIOTAINEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength.selector);
        new BIOTAINEngine(tokenAddresses, priceFeedAddresses, address(bsc));
    }

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

    function testGetTokenAmountFromUsd() public {
        uint256 usdAmount = 100 ether;
        // $2000 / $100 ETH
        uint256 expectedWeth = 0.05 ether;
        uint256 actualWeth = engine.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(expectedWeth, actualWeth);
    }

    ////////////////////////////////////
    //// depositCollateral Tests ///////
    ////////////////////////////////////

    function testRevertsIfCollateralZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);

        vm.expectRevert(BIOTAINEngine.BIOTAINEngine__NeedsMoreThanZero.selector);
        engine.depositCollateral(weth, 0);
        vm.stopPrank();
    }
}
