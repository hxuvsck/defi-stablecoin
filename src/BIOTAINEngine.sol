// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// Errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

import {BiotainStableCoin} from "./BiotainStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title BIOTAINEngine
 * @author Khuslen Ganbat
 *
 * The system is designed to be minimal as possible, and have the tokens maintain a 1 token is equals to 1$ pegged.
 * This stablecoin has the properties:
 *  - Exogenous Collateral
 *  - Dollar Pegged
 *  - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was only backed by wETH and wBTC.
 *
 * Our BIOTAIN system should always be "overcollateralized". At no point, should the value of all collateral is minimum or equal to the $ backed value of all the BIOTAIN.
 *
 * @notice This contract is the core of the BIOTAIN System. It handles all the logic for minting and redeeming BIOTAIN. As well as depositing and withdrawing collateral.
 * @notice This contract is VERY loosely based on the MakerDAO DSS (DAI) system.
 */

contract BIOTAINEngine is ReentrancyGuard {
    //////////////////////////
    ///// Errors         /////
    //////////////////////////

    error BIOTAINEngine__NeedsMoreThanZero();
    error BIOTAINEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error BIOTAINEngine__NotAllowedToken();
    error BIOTAINEngine__TransferFailed();

    //////////////////////////////
    ///// State Vars         /////
    //////////////////////////////

    mapping(address token => address priceFeed) private s_priceFeeds; // tokenToPriceFeeds
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;

    BiotainStableCoin private immutable i_biotain;

    //////////////////////////
    ///// Events         /////
    //////////////////////////

    event CollateralDeposited(address indexed user, address indexed token, uint256 amount);

    //////////////////////////
    ///// Modifiers      /////
    //////////////////////////

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert BIOTAINEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        // If token is not allowed, reverts
        if (s_priceFeeds[token] == addresss(0)) {
            revert BIOTAINEngine__NotAllowedToken();
        }
        _;
    }

    //////////////////////////
    ///// Functions      /////
    //////////////////////////

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address biotainAddress) {
        // Every price feed that using will be USD backed.
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert BIOTAINEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }
        // e.g => ETH/USD, BTH/USD, MKR/USD etc...

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        i_biotain = BiotainStableCoin(biotainAddress);
    }

    ///////////////////////////////////
    ///// External Functions      /////
    ///////////////////////////////////

    function despositCollateralAndMintBiotain() external {}

    function redeemCollateralForBiotain() external {}

    // Threshold to let's say 150%
    // $100 ETH -> $75 ETH
    // $50  BIOTAIN

    // Hey, if someone pays back your minted BIOTAIN, they can have all your collateral for a discount.
    // Ломбардны систем шиг, хэрэв оруулсан хөрөнгийн хэмжээ тухайн зээлдүүлсэн хэмжээний хувьчлалаас хэтэрвэл өөр хэрэглэгч тухайн зээлдүүлсэн хөрөнгийг өмнөөс нь төлөн оруулсан хөрөнгийг авч, ашиг хийх процесс яригдав.

    /**
     * @notice People do actually start testing so early within core concepts of any functions and operations of the smartcontracts right away...
     */
    /**
     * @param tokenCollateralAddress The address of the token to deposit as collateral
     * @param amountCollateral The amount of collateral to deposit
     * @notice re-entrancy is the most common attacks in web3, so by importing openzeppelin contracts to it and function is external, it better be non-re-entrant (will be more gas intensive but safer)
     * @notice follow CEI (Checks,Effects,Interactions)
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral) //Checks
        isAllowedToken(tokenCollateralAddress) //Checks
        nonReentrant //Checks

    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral; //Effects
        emit s_collateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral); //Effects
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral); //Interactions
        if (!success) {
            revert BIOTAINEngine__TransferFailed();
        }
    }

    function redeemCollateral() external {}

    // 1. Check if the value of collateral is always greater than BIOTAIN amount
    function mintBiotain() external {}

    function burnBiotain() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
