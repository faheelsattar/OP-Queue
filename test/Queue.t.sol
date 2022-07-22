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
        q1.enqueue(5);
        q1.enqueue(4);
        q1.enqueue(3);
        q1.enqueue(2);
        q1.enqueue(1);

        assertEq(q1.getStore(1), 5);
        assertEq(q1.getStore(2), 4);
        assertEq(q1.getStore(3), 3);
        assertEq(q1.getStore(4), 2);
        assertEq(q1.getStore(5), 1);
        assertEq(q1.getStore(6), 0);
    }
}
