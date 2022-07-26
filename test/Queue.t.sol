// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { PRBTest } from "@prb/test/PRBTest.sol";

import { Queue } from "../src/Queue.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract QueueTest is PRBTest {
    Queue q1;
    uint256 testNumber;

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

    function testCannotEnqueueMoreThenMax128() public {
        q1.enqueue(5);

        uint256 max128 = type(uint128).max;
        uint256 last = max128 << 0x80;

        vm.store(address(q1), bytes32(uint256(1)), bytes32(last));

        vm.expectRevert();
        q1.enqueue(5);
    }

    function testDequeue() public {
        q1.enqueue(5);
        q1.enqueue(4);
        q1.enqueue(3);
        q1.enqueue(2);
        q1.enqueue(1);

        assertEq(q1.dequeue(), 5);
        assertEq(q1.dequeue(), 4);
        assertEq(q1.dequeue(), 3);
        assertEq(q1.dequeue(), 2);
        assertEq(q1.dequeue(), 1); //at this point the queue is empty
    }

    function testDequeueWhenLastFirstEqualMax256() public {
        q1.enqueue(5);

        uint256 max256 = type(uint256).max - 1;

        vm.store(address(q1), bytes32(uint256(1)), bytes32(max256));

        assertEq(q1.dequeue(), 0); //at this point the queue is empty

        assertEq(bytes32(q1.lastFirst()), 0x0);
    }

    function testCannotDequeueWhenStoreIsEmpty1() public {
        vm.expectRevert();
        q1.dequeue();
    }

    function testCannotDequeueWhenStoreIsEmpty2() public {
        q1.enqueue(5);
        q1.enqueue(4);
        q1.enqueue(3);
        q1.enqueue(2);
        q1.enqueue(1);

        q1.dequeue();
        q1.dequeue();
        q1.dequeue();
        q1.dequeue();
        q1.dequeue(); //at this point the queue is empty

        vm.expectRevert();
        q1.dequeue();
    }

    function testLastFirst() public {
        q1.enqueue(5);
        q1.enqueue(4);

        assertEq(bytes32(q1.lastFirst()), 0x0000000000000000000000000000000200000000000000000000000000000000);
    }

    function testLastFirstWithMultipleOps() public {
        assertEq(bytes32(q1.lastFirst()), 0x0);

        q1.enqueue(20);
        q1.enqueue(12);

        assertEq(bytes32(q1.lastFirst()), 0x0000000000000000000000000000000200000000000000000000000000000000);

        q1.dequeue();

        assertEq(bytes32(q1.lastFirst()), 0x0000000000000000000000000000000200000000000000000000000000000001);

        q1.dequeue();

        assertEq(bytes32(q1.lastFirst()), 0x0);
    }
}
