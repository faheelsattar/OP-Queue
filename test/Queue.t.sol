// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console } from "forge-std/console.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";

import { Queue } from "../src/Queue.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract ContractTest is PRBTest {
    Queue q1;

    function setUp() public {
        q1 = new Queue();
    }

    /// @dev Run Forge with `-vvvv` to see console logs.
    function testExample() public {
        q1.enqueue();
        q1.enqueue();
        q1.enqueue();
        q1.enqueue();
        q1.enqueue();
        
        assertTrue(true);
    }
}
