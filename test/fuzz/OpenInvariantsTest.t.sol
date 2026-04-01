// SPDX-License-Identifier: MIT

// Have our invariants aka properties

// What are our invariants?
// 1. The total supply of BIOTAIN should be less than the total value of collateral.

// 2. Getter view functions should never revert <- evergreen invariant

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployBiotainStableCoin} from "../../script/DeployBiotainStableCoin.s.sol";
import {BIOTAINEngine} from "../../src/BIOTAINEngine.sol";
import {BiotainStableCoin} from "../../src/BiotainStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract OpenInvariantsTest is Test, StdInvariant {
    DeployBiotainStableCoin deployer;
    BIOTAINEngine bsce;
    BiotainStableCoin bsc;
    HelperConfig config;

    function setUp() external {
        deployer = new DeployBiotainStableCoin();
        (bsce, bsc, config) = deployer.run();
        targetContract(address(bsce));
    }
}
