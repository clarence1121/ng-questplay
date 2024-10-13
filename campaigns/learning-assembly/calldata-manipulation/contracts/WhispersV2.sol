// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract WhispersV2 {

    /// @notice Converts a compressed uint256 array into standard uint256[].
    function compressedWhisper() public pure returns (uint256[] memory array) {
        assembly {
            // Load the calldata size
            let dataLength := calldatasize()
            
            // Skip the first 4 bytes (function selector)
            let dataOffset := 4
            
            // Calculate the number of elements in the resulting array
            // Since we don't know the number upfront, we'll allocate the memory dynamically.
            // For now, let's start by pointing the memory pointer to the free memory location.
            let arrayPointer := mload(0x40)
            
            // We use this to store the size of the array at the beginning.
            let arraySizeLocation := arrayPointer
            // Reserve 32 bytes for array length at the beginning
            mstore(arrayPointer, 0)
            arrayPointer := add(arrayPointer, 0x20)
            
            // Variable to count the number of extracted uint256 values
            let arrayLength := 0
            
            // Iterate through the calldata until the end
            for { } lt(dataOffset, dataLength) { } {
                // Read the length byte from calldata (1 byte)
                let length := byte(0, calldataload(dataOffset))
                dataOffset := add(dataOffset, 1)

                // Now extract the following `length` bytes and construct the uint256
                let value := 0
                
                for { let i := 0 } lt(i, length) { i := add(i, 1) } {
                    // Shift the value left by 8 bits (to make room for the next byte)
                    value := shl(8, value)
                    // Read the next byte from calldata and OR it into the value
                    let nextByte := byte(0, calldataload(add(dataOffset, i)))
                    value := or(value, nextByte)
                }
                
                // Move the data offset by `length` bytes
                dataOffset := add(dataOffset, length)
                
                // Store the extracted uint256 in memory
                mstore(arrayPointer, value)
                arrayPointer := add(arrayPointer, 0x20)
                
                // Increment the array length
                arrayLength := add(arrayLength, 1)
            }
            
            // Store the final length of the array in the reserved 32 bytes
            mstore(arraySizeLocation, arrayLength)
            
            // Update the free memory pointer
            mstore(0x40, arrayPointer)
            
            // Return the array pointer to Solidity
            array := arraySizeLocation
        }
    }

}
