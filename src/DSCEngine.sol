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

import {} from "";

/**
 * @title DSCEngine
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
 * Our DSC system should always be "overcollateralized". At no point, should the value of all collateral is minimum or equal to the $ backed value of all the DSC.
 * 
 * @notice This contract is the core of the DSC System. It handles all the logic for minting and redeeming DSC. As well as depositing and withdrawing collateral. 
 * @notice This contract is VERY loosely based on the MakerDAO DSS (DAI) system.
 */

contract DSCEngine {

    
    //////////////////////////
    ///// Errors         /////
    //////////////////////////

    error DSCEngine__NeedsMoreThanZero();

    
    //////////////////////////////
    ///// State Vars         /////
    //////////////////////////////

    mapping(address token=>address priceFeed) private s_priceFeeds; // tokenToPriceFeeds

    //////////////////////////
    ///// Modifiers      /////
    //////////////////////////

    modifier moreThanZero(uint256 amount) {
        if(amount == 0){
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        // If token is not allowed, reverts
    }

    //////////////////////////
    ///// Functions      /////
    //////////////////////////

    constructor() {}


    ///////////////////////////////////
    ///// External Functions      /////
    ///////////////////////////////////

    function despositCollateralAndMintDsc() external {}

    function redeemCollateralForDsc() external {}
    
    // Threshold to let's say 150%
    // $100 ETH -> $75 ETH
    // $50  DSC

    // Hey, if someone pays back your minted DSC, they can have all your collateral for a discount. 
    // Ломбардны систем шиг, хэрэв оруулсан хөрөнгийн хэмжээ тухайн зээлдүүлсэн хэмжээний хувьчлалаас хэтэрвэл өөр хэрэглэгч тухайн зээлдүүлсэн хөрөнгийг өмнөөс нь төлөн оруулсан хөрөнгийг авч, ашиг хийх процесс яригдав.

    /**
     * @notice People do actually start testing so early within core concepts of any functions and operations of the smartcontracts right away...
     */
    /**
     * @param tokenCollateralAddress The address of the token to deposit as collateral
     * @param amountCollateral The amount of collateral to deposit
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral) external moreThanZero(amountCollateral) {

    }

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}