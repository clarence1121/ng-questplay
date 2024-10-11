// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract For {
    
    /// @notice Sum the elements in [`beg`, `end`) and return the result.
    /// Skips elements divisible by 5. 
    /// Exits the summation loop when it encounters a factor of `end`.
    /// @dev You can ignore overflow / underflow bugs.
    function sumElements(uint256 beg, uint256 end)
        public
        pure
        returns (uint256 sum)
    {
        assembly {
            // Initialize the sum to 0
            sum := 0

            // Loop from beg to end (exclusive)
            for { let i := beg } lt(i, end) { i := add(i, 1) } {
                // Skip if the current element is divisible by 5
                if iszero(mod(i, 5)) {
                    continue
                }
                
                // Exit the loop if the current element is a factor of `end`
                if iszero(mod(end, i)) {
                    break
                }

                // Add the current element to the sum
                sum := add(sum, i)
            }
        }
    }
}
