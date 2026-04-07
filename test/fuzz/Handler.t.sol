// SPDX-License-Identifier: MIT

// Narrow down the way we call function

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {BIOTAINEngine} from "../../src/BIOTAINEngine.sol";
import {BiotainStableCoin} from "../../src/BiotainStableCoin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
// Price Feed
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

contract Handler is Test {
    BIOTAINEngine bsce;
    BiotainStableCoin bsc;

    ERC20Mock weth;
    ERC20Mock wbtc;

    uint256 public timesMintIsCalled;
    address[] public usersWithCollateralDeposited;

    uint256 MAX_DEPOSIT_SIZE = type(uint96).max; // the max uint96 value

    MockV3Aggregator public ethUsdPriceFeed;

    constructor(BIOTAINEngine _biotainEngine, BiotainStableCoin _bsc) {
        bsce = _biotainEngine;
        bsc = _bsc;

        address[] memory collateralTokens = bsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);

        ethUsdPriceFeed = MockV3Aggregator(bsce.getCollateralTokenPriceFeed(address(weth)));
    }

    function mintBiotain(uint256 amount, uint256 addressSeed) public {
        // msg.sender
        if (usersWithCollateralDeposited.length == 0) {
            return;
        }
        address sender = usersWithCollateralDeposited[addressSeed % usersWithCollateralDeposited.length];
        (uint256 totalBiotainMinted, uint256 collateralValueInUsd) = bsce.getAccountInformation(sender);

        int256 maxBiotainToMint = (int256(collateralValueInUsd) / 2) - int256(totalBiotainMinted);
        if (maxBiotainToMint < 0) {
            return;
        }
        amount = bound(amount, 0, uint256(maxBiotainToMint));
        if (amount == 0) {
            return;
        }
        vm.startPrank(sender);
        bsce.mintBiotain(amount);
        vm.stopPrank();
        timesMintIsCalled++; //handler ghost variables
    }

    // and now, by making the first function in handler and implementing it to invariant stateful fuzz testing,
    // test will not go for a target contract as a random ones, but with only this function to revert.
    function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        // bsce.depositCollateral(collateral, amountCollateral);
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(bsce), amountCollateral);
        bsce.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
        // double push
        usersWithCollateralDeposited.push(msg.sender);
    }

    function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        uint256 maxCollateralToRedeem = bsce.getCollateralBalanceOfUser(address(collateral), msg.sender);
        // seems a bit deceptive even in fail on revert is true.
        // let's say there is a bug, where a user can redeem more than they have
        amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);
        if (amountCollateral == 0) {
            return; // in this case, we often use vm.assume cheatcode from foundry: this will discard the current fuzz run inputs and start a new fuzz run when boolean expression turns false.
            // https://www.getfoundry.sh/reference/cheatcodes/assume#assume
        }
        bsce.redeemCollateral(address(collateral), amountCollateral);
    }

    // This breaks our invariant test suite!
    // function updateCollateralPrice(uint96 newPrice) public {
    //     int256 newPriceInt = int256(uint256(newPrice));
    //     ethUsdPriceFeed.updateAnswer(newPriceInt);
    // }

    // Helper functions
    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth;
        }
        return wbtc;
    }
}
