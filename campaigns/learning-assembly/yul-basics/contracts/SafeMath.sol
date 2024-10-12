// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SafeMath {

    /// @notice Returns lhs + rhs.
    /// @dev Reverts on overflow / underflow.
    function add(int256 lhs, int256 rhs) public pure returns (int256 result) {
        assembly {
            // Perform the addition
            let temp := add(lhs, rhs)

            // Check for overflow
            // Positive overflow: both lhs and rhs are positive, but temp is negative
            if and(sgt(lhs, 0), and(sgt(rhs, 0), slt(temp, 0))) {
                revert(0, 0)
            }
            // Negative overflow: both lhs and rhs are negative, but temp is positive
            if and(slt(lhs, 0), and(slt(rhs, 0), sgt(temp, 0))) {
                revert(0, 0)
            }

            // Set the result to temp
            result := temp
        }
    }

    /// @notice Returns lhs - rhs.
    /// @dev Reverts on overflow / underflow.
    function sub(int256 lhs, int256 rhs) public pure returns (int256 result) {
        assembly {
            // Perform the subtraction
            let temp := sub(lhs, rhs)

            // Check for overflow / underflow
            // For int256, overflow happens if lhs and rhs have different signs
            // and the result sign is opposite to lhs
            if and(xor(slt(lhs, 0), slt(rhs, 0)), xor(slt(lhs, 0), slt(temp, 0))) {
                revert(0, 0)
            }

            // Set the result to temp
            result := temp
        }
    }

    /// @notice Returns lhs * rhs.
    /// @dev Reverts on overflow / underflow.
    function mul(int256 lhs, int256 rhs) public pure returns (int256 result) {
        assembly {
            // Handle multiplication overflow
            // Special cases: multiplication by 0
            if iszero(lhs) {
                result := 0
            }
            if iszero(rhs) {
                result := 0
            }
            // Perform the multiplication
            let temp := mul(lhs, rhs)

            // Check for overflow by dividing temp by rhs and comparing to lhs
            if iszero(eq(sdiv(temp, rhs), lhs)) {
                revert(0, 0)
            }

            // Set the result to temp
            result := temp
        }
    }

    /// @notice Returns lhs / rhs.
    /// @dev Reverts on division by zero or overflow.
    function div(int256 lhs, int256 rhs) public pure returns (int256 result) {
        assembly {
            // Revert if dividing by zero
            if iszero(rhs) {
                revert(0, 0)
            }
            // Handle int256 minimum value divided by -1 (overflow)
            if and(eq(lhs, 0x8000000000000000000000000000000000000000000000000000000000000000), eq(rhs, not(0))) {
                revert(0, 0)
            }

            // Perform the division
            result := sdiv(lhs, rhs)
        }
    }
}
