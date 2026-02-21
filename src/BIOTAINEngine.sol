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
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

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
    error BIOTAINEngine__BreaksHealthFactor(uint256 healthFactor);
    error BIOTAINEngine__MintFailed();

    //////////////////////////////
    ///// State Vars         /////
    //////////////////////////////

    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; // 200% overcollaterized
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1;

    mapping(address token => address priceFeed) private s_priceFeeds; // tokenToPriceFeeds
    mapping(address user => mapping(address collateralToken => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amountBiotainMinted) private s_BiotainMinted;
    address[] private s_collateralTokens;

    BiotainStableCoin private immutable i_biotain;

    //////////////////////////
    ///// Events         /////
    //////////////////////////

    event CollateralDeposited(address indexed user, address indexed token, uint256 amount);
    event CollateralRedeemed(address indexed user, address indexed token, uint256 indexed amount);

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
        if (s_priceFeeds[token] == address(0)) {
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
            s_collateralTokens.push(tokenAddresses[i]);
        }
        i_biotain = BiotainStableCoin(biotainAddress);
    }

    ///////////////////////////////////
    ///// External Functions      /////
    ///////////////////////////////////

    /**
     *
     * @param tokenCollateralAddress The address of a token to deposit as collateral
     * @param amountCollateral The amount collateral to deposit
     * @param AmountBiotainToMint The amount of decentralized stablecoin to mint
     * @notice This function will deposit your collateral and mint BIOTAIN in one tx.
     */
    function despositCollateralAndMintBiotain(
        address tokenCollateralAddress,
        uint256 amountCollateral,
        uint256 AmountBiotainToMint
    ) external {
        depositCollateral(tokenCollateralAddress, amountCollateral);
        mintBiotain(AmountBiotainToMint); // make it public unless external function cannot call in contract itself (both depositCol and mintBiotain are made public since this LOC)
    }

    function redeemCollateralForBiotain() external {}

    // in order to redeem collateral:
    // 1. Health factor must be over 1 AFTER collateral pulled
    // DRY: Don't repeat yourself (Will refactor after we done as DRY in comp.sci says)

    // CEI: Checks, Effects, Interactions
    function redeemCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] -= amountCollateral;
        emit CollateralRedeemed(msg.sender, tokenCollateralAddress, amountCollateral);
        // _calculateHealthFactorAfter();
        bool success = IERC20(tokenCollateralAddress).transfer(msg.sender, amountCollateral);
        if (!success) {
            revert BIOTAINEngine__TransferFailed();
        }
        _revertIfHealthFactorIsBroken(msg.sender);
    }

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
        public
        moreThanZero(amountCollateral) //Checks
        isAllowedToken(tokenCollateralAddress) //Checks
        nonReentrant //Checks

    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral; //Effects
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral); //Effects
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral); //Interactions
        if (!success) {
            revert BIOTAINEngine__TransferFailed();
        }
    }

    // 1. Check if the value of collateral is always greater than BIOTAIN amount
    // $200 ETH -> $20 BIOTAIN
    /**
     * @notice follows CEI
     * @param amountBiotainToMint The amount of decentralized stable coin to mint.
     * @notice They must have more collateral value than minimum threshold.
     */
    function mintBiotain(uint256 amountBiotainToMint) public moreThanZero(amountBiotainToMint) nonReentrant {
        s_BiotainMinted[msg.sender] += amountBiotainToMint;
        // If minted too much ($150 BIOTAIN, $100 ETH) it mnust be 100% reverted
        _revertIfHealthFactorIsBroken(msg.sender);
        bool minted = i_biotain.mint(msg.sender, amountBiotainToMint);
        if (!minted) {
            revert BIOTAINEngine__MintFailed();
        }
    }

    function burnBiotain() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}

    /////////////////////////////////////////////
    ///// Private & Internal View Functions /////
    /////////////////////////////////////////////

    function _getAccountInformation(address user)
        private
        view
        returns (uint256 totalBiotainMinted, uint256 collateralValueInUsd)
    {
        totalBiotainMinted = s_BiotainMinted[user];
        collateralValueInUsd = getAccountCollateralValue(user);
    }

    /**
     *
     * Returns how close to liquidation a user is
     * If a user goes below 1, then they can get liquidated
     */
    function _healthFactor(address user) private view returns (uint256) {
        // total BIOTAIN minted
        // total collateral VALUE
        (uint256 totalBiotanMinted, uint256 collateralValueInUsd) = _getAccountInformation(user);
        // return (collateralValueInUsd / totalBiotanMinted); // 100 / 100 is undercollateralized, must be undercollaterized
        uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        // 150$ ETH * 50 / 100 = 75% < 100%
        return (collateralAdjustedForThreshold * PRECISION / totalBiotanMinted);
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        // 1. Check health factor (do they have enough collateral?)
        // 2. Revert if they don't
        uint256 userHealthFactor = _healthFactor(user);
        if (userHealthFactor < MIN_HEALTH_FACTOR) {
            revert BIOTAINEngine__BreaksHealthFactor(userHealthFactor);
        }
    }

    /////////////////////////////////////////////
    ///// Public & External View Functions //////
    /////////////////////////////////////////////

    function getAccountCollateralValue(address user) public view returns (uint256 totalCollateralValueInUsd) {
        // loop through each collateral token, get the amount they have deposited, and map it to the price, to get the USD value.
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
        return totalCollateralValueInUsd;
    }

    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (, int256 price,,,) = priceFeed.latestRoundData();
        // 1 ETH = $1000
        // The returned value from CL will be 1000 * 1e8
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION; // (1000 * 1e8 *(1e10)) * 1000 * 1e18;
    }
}
