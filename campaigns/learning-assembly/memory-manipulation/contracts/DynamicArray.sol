// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DynamicArray {

    /// @notice Copies `array` into a new memory array 
    /// and pushes `value` into the new array.
    /// @return array_ The new array to return.
            function push(
        uint256[] memory array, 
        uint256 value
    ) public pure returns (uint256[] memory array_) {
        assembly {
            // Load the length of the original array
            let len := mload(array)

            // Get the current free memory pointer
            let freePtr := mload(0x40)

            // Set array_ to the current free memory pointer
            array_ := freePtr

            // Update the free memory pointer to allocate space for the new array (len + 1 elements)
            mstore(0x40, add(freePtr, add(mul(add(len, 1), 0x20), 0x20))) // len + 1 elements + 1 slot for length

            // Store the new length of the array
            mstore(array_, add(len, 1))

            // Calculate the size of the original array (len * 32 bytes)
            let size := mul(len, 0x20)

            // Copy the contents of the original array into the new array
            let src := add(array, 0x20) // Start copying after the length slot
            let dest := add(array_, 0x20)
            for { let i := 0 } lt(i, size) { i := add(i, 0x20) } {
                mstore(add(dest, i), mload(add(src, i)))
            }

            // Store the new value at the end of the new array
            mstore(add(dest, size), value)
        }
    }



        function pop(uint256[] memory array) 
    public 
    pure 
    returns (uint256[] memory) 
{
    assembly {
        // Load the length of the original array
        let len := mload(array)

        // Revert if the array is empty
        if iszero(len) { revert(0, 0) }

        // Decrease the length of the array by 1 (pop operation)
        let newLen := sub(len, 1)

        // Set the new length of the array
        mstore(array, newLen)

        // Optionally, zero out the last element for safety
        // Calculate the position of the last element
        let lastElemPos := add(add(array, 0x20), mul(newLen, 0x20))

        // Zero out the last element
        mstore(lastElemPos, 0)
    }

    // Return the modified array (the original array is modified in place)
    return array;
}




function popAt(uint256[] memory array, uint256 index) 
    public 
    pure 
    returns (uint256[] memory) 
{
    assembly {
        // Load the length of the original array
        let len := mload(array)

        // Revert if index is out of bounds
        if iszero(lt(index, len)) { revert(0, 0) }

        // Start of the array data (skip length slot)
        let dataStart := add(array, 0x20)

        // Initialize pointers
        let dest := add(dataStart, mul(index, 0x20))    // Position of the element to remove
        let src := add(dest, 0x20)                      // Position of the next element

        // Number of elements to move
        let numToMove := sub(len, add(index, 1))

        // Shift elements forward using double pointers
        for { let i := 0 } lt(i, mul(numToMove, 0x20)) { i := add(i, 0x20) } {
            mstore(add(dest, i), mload(add(src, i)))
        }

        // Zero out the last element (optional, for security)
        let lastElemPos := add(dataStart, mul(sub(len, 1), 0x20))
        mstore(lastElemPos, 0)

        // Update the array length
        mstore(array, sub(len, 1))
    }

    // Return the modified array
    return array;
}





}