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
    uint256 amountCollateral = 10 ether;
    uint256 amountToMint = 100 ether;

    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant MIN_HEALTH_FACTOR = 1e18;
    uint256 public constant LIQUIDATION_THRESHOLD = 50;

    // Liquidation
    address public liquidator = makeAddr("liquidator");
    uint256 public collateralToCover = 20 ether;

    function setUp() public {
        deployer = new DeployBiotainStableCoin();
        (bsc, engine, config) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc,) = config.activeNetworkConfig();

        // for better test, we made a mint for user in setUp
        ERC20Mock(weth).mint(USER, STARTING_USER_BALANCE);
        ERC20Mock(wbtc).mint(USER, STARTING_USER_BALANCE);
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

    // moreThanZero constructor
    function testRevertsIfCollateralZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);

        vm.expectRevert(BIOTAINEngine.BIOTAINEngine__NeedsMoreThanZero.selector);
        engine.depositCollateral(weth, 0);
        vm.stopPrank();
    }

    // isAllowedToken constructor
    function testRevertsWithUnapprovedCollateral() public {
        ERC20Mock ranToken = new ERC20Mock("RAN", "RAN", USER, AMOUNT_COLLATERAL); //ranToken == random token
        vm.startPrank(USER);
        vm.expectRevert(BIOTAINEngine.BIOTAINEngine__NotAllowedToken.selector);
        engine.depositCollateral(address(ranToken), AMOUNT_COLLATERAL);
        vm.stopPrank();
    }
    // re-entrancy constructor test skipped for now

    // Adding modifiers since depositCollateral has a lot stuff to do

    modifier depositedCollateral() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);
        engine.depositCollateral(weth, AMOUNT_COLLATERAL);
        vm.stopPrank();
        _;
    }

    // s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
    function testCanDepositCollateralAndGetAccountInfo() public depositedCollateral {
        (uint256 totalBiotainMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(USER);

        uint256 expectedTotalBiotainMinted = 0;
        uint256 expectedDepositAmount = engine.getTokenAmountFromUsd(weth, collateralValueInUsd);
        assertEq(totalBiotainMinted, expectedTotalBiotainMinted);
        assertEq(AMOUNT_COLLATERAL, expectedDepositAmount);
    }
}
