// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Doubloon.sol";

contract MintableDoubloon is Doubloon {

    constructor(uint256 _supply) Doubloon(_supply) {}
    function mint(address _to, uint256 _amount) external {
        require(msg.sender==owner,"not owner");
         _totalSupply += _amount;
        _balances[_to]+=_amount;
        emit Transfer(address(0), _to, _amount); 
    }
}

