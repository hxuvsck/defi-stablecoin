// SPDX-License-Identifier: MIT

// Have our invariants aka properties

// What are our invariants?
// 1. The total supply of BIOTAIN should be less than the total value of collateral.

// 2. Getter view functions should never revert <- evergreen invariant

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";

contract InvariantsTest is Test, StdInvariant {}
