// SPDX-License-Identifier: MIT

// Have our invariants aka properties

// What are our invariants?
// 1. The total supply of BIOTAIN should be less than the total value of collateral.

// 2. Getter view functions should never revert <- evergreen invariant

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployBiotainStableCoin} from "../../script/DeployBiotainStableCoin.s.sol";
import {BIOTAINEngine} from "../../src/BIOTAINEngine.sol";
import {BiotainStableCoin} from "../../src/BiotainStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handler} from "./Handler.t.sol";

contract Invariants is StdInvariant, Test {
    DeployBiotainStableCoin deployer;
    BIOTAINEngine bsce;
    BiotainStableCoin bsc;
    HelperConfig config;
    address weth;
    address wbtc;
    Handler handler;

    function setUp() external {
        deployer = new DeployBiotainStableCoin();
        (bsc, bsce, config) = deployer.run();
        (,, weth, wbtc,) = config.activeNetworkConfig();
        // targetContract(address(bsce));
        handler = new Handler(bsce, bsc);
        targetContract(address(handler));
        // need to make it more sensible due to Handlers.
        // in toml file, making it fail_on_revert = true as:
        // hey, don't call redeemCollateral, unless there is collateral to redeem
    }

    function invariant__ProtocolMustHaveMoreValueThanTotalSupply() public view {
        // get the value of all the collateral in the protocol
        // compare it to all the debt (bsc)
        uint256 totalSupply = bsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(bsce));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(bsce));

        uint256 wethValue = bsce.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = bsce.getUsdValue(wbtc, totalWbtcDeposited);

        console.log("weth value", wethValue);
        console.log("wbtc value", wbtcValue);
        console.log("total supply", totalSupply);
        console.log("Times mint called", handler.timesMintIsCalled());

        assert(wethValue + wbtcValue >= totalSupply);
    }

    function invariant__gettersShouldNotRevert() public view {
        // bsce.getAccountCollateralValue();
        // bsce.getAccountInformation();
        // bsce.getCollateralBalanceOfUser();
        // bsce.getCollateralTokens();
        // bsce.getHealthFactor();
        // bsce.getTokenAmountFromUsd();
        // bsce.getUsdValue();
    }
}
