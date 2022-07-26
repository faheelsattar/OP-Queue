// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

/// @title Optimized Queue data structure implementation
/// @author @721Orbit
/// @notice Can be used in many scenrios eg: vault strategies
/// @custom:experimental This is an experimental contract.

contract Queue {
    /// @notice used to store data in the queue
    mapping(uint256 => uint256) public store;

    /// @notice used to keep track of the queue data
    uint256 public lastFirst;

    /// @notice helper constants for adding and masking data
    uint256 private constant LAST_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000;
    uint256 private constant FIRST_MASK = 0x00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint256 private constant LAST_ADD_ONE = 0x0000000000000000000000000000000100000000000000000000000000000000;
    uint256 private constant FIRST_ADD_ONE = 0x0000000000000000000000000000000000000000000000000000000000000001;

    /// @notice function to insert data inside the queue
    /// @param _data The data that gets inserted
    function enqueue(uint256 _data) external {
        uint256 max256 = type(uint256).max;
        uint256 max128 = type(uint128).max;

        assembly {
            //loading lastFirst slot number
            let lastFirstSlot := lastFirst.slot

            let storedData := sload(lastFirstSlot)

            //adding one in the last 128 bits eveytime data gets enqueued
            let addOneInLast := add(storedData, LAST_ADD_ONE)

            //overflow check
            if eq(addOneInLast, 0) {
                revert(0, 0)
            }
            // extract last 128 bits
            let last := shr(0x80, addOneInLast)

            // last never gt then max128 referenced before
            // assembly block
            if gt(last, max128) {
                revert(0, 0)
            }

            // remove the bits for the part under updation "and"
            // restore the other part as it is
            let removedBits := and(storedData, xor(max256, LAST_MASK))

            // update the required bits
            let updateLastBits := or(removedBits, addOneInLast)

            //store updated data at required slot
            sstore(lastFirstSlot, updateLastBits)

            // load free memory ptr
            let ptr := mload(0x40)

            // store the key in memory
            mstore(ptr, last)
            //store the slot in memory
            mstore(add(ptr, 0x20), store.slot)

            // calculate mapping slot => (keccak256(key, slot))
            let calcNewSlot := keccak256(ptr, 0x40)

            //store _data at the new calculate slot
            sstore(calcNewSlot, _data)
        }
    }

    function dequeue() external returns (uint256 data) {
        uint256 max256 = type(uint256).max;

        assembly {
            //loading lastFirst slot number
            let lastFirstSlot := lastFirst.slot

            let storedData := sload(lastFirstSlot)

            // revert if nothing to dequeue
            if eq(storedData, 0x0) {
                revert(0, 0)
            }

            //adding one in the first 128 bits eveytime data gets dequeued
            let addOneInFirst := add(storedData, FIRST_ADD_ONE)

            //extracting last bits
            let last := shr(0x80, addOneInFirst)

            //extracting first bits
            let first := and(FIRST_MASK, addOneInFirst)

            // fallback lastFirst to default if queue will be 
            // empty after this call
            if eq(last, first) {
                sstore(lastFirstSlot, 0x0)
            }

            // if more items are present in the queue after 
            // this call  
            if gt(last, first) {
                // remove the bits for the part under updation "and"
                // restore the other part as it is
                let removedBits := and(storedData, xor(max256, FIRST_MASK))

                // update the required bits
                let updateFirstBits := or(removedBits, addOneInFirst)

                //store updated data at required slot
                sstore(lastFirstSlot, updateFirstBits)
            }

            // load free memory ptr
            let ptr := mload(0x40)

            // store the key in memory
            mstore(ptr, first)

            //store the slot in memory
            mstore(add(ptr, 0x20), store.slot)

            // calculate mapping slot => (keccak256(key, slot))
            let calcNewSlot := keccak256(ptr, 0x40)

            // return data that is dequeued
            data := sload(calcNewSlot)

            // fallback to default after dequeue at that key 
            sstore(calcNewSlot, 0)
        }
    }
}
