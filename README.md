# 1. What we will be doing during this course:

We will be making a stable-coin where it has these features during our stable-coin course period:

1. Relative Stability: Anchored / Pegged to 1.00$ (USD). / Coded to be always stable coin is always worth 1$ /

- Getting price feed through Chainlink.
- Will set a function to exchange ETH & BTC for worth of their $ price is.
-

2. Stability Mechanism (Minting): Algorithmic (Decentralized, means there is no centralized entity to mint or burn maintain the price).
<!-- Future of stable coins will be algorithmic, but a better stablecoin for Web3 probably is an anchored or pegged contemporarily. It's may probably floating, but that's a much harder mechanism to do. -->

- People can only mint the stablecoin with enough collateral. / Will be coded directly into our protocol.

3. Collateral Type: Exogenous (Crypto Collateral: Use cryptocurrencies as collateral for this currency).

Which will be using wBTC (wrapped Bitcoin which is ERC20 version of BTC), wETH (wrapped Ethereum which is ERC20 version of ETH.) for our collateral system.

<!-- Some might argue that this wBTC is a little bit centralized depending on who is onboarding the Bitcoin to Ethereum, but that's not quite important for this. (Keep in mind)-->

During testing, I must let:

- calculate health factor function
- set health factor if debt is 0
- added bunch of view function <!-- As of Patrick made (See course repo) -->
