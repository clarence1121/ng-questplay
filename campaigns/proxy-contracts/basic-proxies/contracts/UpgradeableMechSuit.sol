// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract UpgradeableMechSuit {
    // The keccak256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 private constant _IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    // The keccak256 hash of "eip1967.proxy.admin" subtracted by 1
    bytes32 private constant _ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    /// @notice Constructs the contract and sets the initial implementation
    /// @param _implementation Address of logic contract to be linked
    constructor(address _implementation) {
        _setImplementation(_implementation);
        _setAdmin(msg.sender);
    }

    /// @notice Fallback function to delegate calls to the implementation contract
    fallback() external payable {
        _delegate(_getImplementation());
    }

    /// @notice Upgrades contract by updating the linked logic contract
    /// @param _implementation Address of new logic contract to be linked
    function upgradeTo(address _implementation) external {
        require(msg.sender == _getAdmin(), "Only owner can upgrade");
        _setImplementation(_implementation);
    }

    /// @notice Delegates calls to the logic contract
    /// @param _impl Address of the logic contract
    function _delegate(address _impl) internal {
        assembly {
            // Load the free memory pointer
            let ptr := mload(0x40)
            // Copy msg.data (input data) into memory starting at the free memory pointer
            calldatacopy(ptr, 0, calldatasize())
            // Perform the delegatecall
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            // Copy the returned data into memory
            returndatacopy(ptr, 0, returndatasize())
            // If the delegatecall failed, revert with the return data
            if iszero(result) {
                revert(ptr, returndatasize())
            }
            // Return the result of the delegatecall
            return(ptr, returndatasize())
        }
    }

    /// @notice Gets the current implementation address
    function _getImplementation() internal view returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    /// @notice Sets the implementation address
    function _setImplementation(address newImplementation) internal {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)//在剛剛指定的slot存入state variable
        }
    }

    /// @notice Gets the current admin (owner) address
    function _getAdmin() internal view returns (address admin) {
        bytes32 slot = _ADMIN_SLOT;
        assembly {
            admin := sload(slot)
        }
    }

    /// @notice Sets the admin (owner) address
    function _setAdmin(address newAdmin) internal {
        bytes32 slot = _ADMIN_SLOT;
        assembly {
            sstore(slot, newAdmin)//在剛剛指定的slot存入state variable
        }
    }

    /// @notice Fallback function for receiving Ether
    receive() external payable {}
}

