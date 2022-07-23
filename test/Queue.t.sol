// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console } from "forge-std/console.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";

import { Queue } from "../src/Queue.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract QueueTest is PRBTest {
    Queue q1;

    function setUp() public {
        q1 = new Queue();
    }

    /// @dev Run Forge with `-vvvv` to see console logs.
    function testEnqueue() public {
        q1.enqueue(5);
        q1.enqueue(4);
        q1.enqueue(3);
        q1.enqueue(2);
        q1.enqueue(1);

        assertEq(q1.store(1), 5);
        assertEq(q1.store(2), 4);
        assertEq(q1.store(3), 3);
        assertEq(q1.store(4), 2);
        assertEq(q1.store(5), 1);
        assertEq(q1.store(6), 0);
    }

    function testLastFirst() public {
        q1.enqueue(5);
        q1.enqueue(4);

        assertEq(bytes32(q1.lastFirst()), 0x0000000000000000000000000000000200000000000000000000000000000000);
    }

    function testDequeue() public {
        q1.enqueue(5);
        q1.enqueue(4);
        q1.enqueue(3);
        q1.enqueue(2);
        q1.enqueue(1);

        console.logBytes32(bytes32(q1.lastFirst()));
        console.log(q1.dequeue());
        console.log(q1.dequeue());
        console.log(q1.dequeue());
        console.log(q1.dequeue());
        console.logBytes32(bytes32(q1.lastFirst()));
        console.log(q1.dequeue());
        console.logBytes32(bytes32(q1.lastFirst()));
    }
}
