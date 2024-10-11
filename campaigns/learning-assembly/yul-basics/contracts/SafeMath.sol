// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SafeMath {

    /// @notice Returns lhs + rhs.
    /// @dev Reverts on overflow / underflow.
    //相加的結果小於任何一個都代表overflow
    function add(
        int256 lhs, 
        int256 rhs
    ) public pure returns (int256 result) {
        result = lhs+rhs;
        // // Convert this to assembly
        // assembly{
        //     let temp := add(lhs,rhs)
        //     if or(lt(temp , lhs),lt(temp,rhs)){
        //         revert(0,0)
        //     } 
        //     result:=temp 
        // }
    }

    /// @notice Returns lhs - rhs.
    /// @dev Reverts on overflow / underflow.
    function sub(int256 lhs, int256 rhs) public pure returns (int256 result) {
        // Convert this to assembly
        result = lhs - rhs;
    }

    /// @notice Returns lhs * rhs.
    /// @dev Reverts on overflow / underflow.
    function mul(int256 lhs, int256 rhs) public pure returns (int256 result) {
        // Convert this to assembly
        result = lhs * rhs;
    }

    /// @notice Returns lhs / rhs.
    /// @dev Reverts on overflow / underflow.
    function div(int256 lhs, int256 rhs) public pure returns (int256 result) {
        // Convert this to assembly
        result = lhs / rhs;
    }
}
