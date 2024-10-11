// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import './interfaces/ICrates.sol';

contract Crates is ICrates {
    struct crates{
        uint size;
        uint strength;
    }
    mapping(uint=>crates) public crates_mapping;
    uint[] internal is_init;//用來記錄id存不存在

    //建立一個mapping把id對到他對應的index
    mapping(uint=>uint) internal id_index;

        // CODE HERE
    /// @notice Inserts a crate into the contract. Fails if id belongs to an existing crate.
    function insertCrate(
        uint id, 
        uint size, 
        uint strength
    ) external{
        //mapping(uint=>crates) storage temp = crates_mapping;
        
        require(size>=0 && strength>=0 && id>=0,"not valid input");
        require(crates_mapping[id].size==0&&crates_mapping[id].strength==0,"already existing");
        crates_mapping[id] = crates(size , strength);
        is_init.push(id);
        id_index[id] = is_init.length;
    }

   /// @notice Retrieves a crate based on id. Fails if id does not belong to an existing crate.
    function getCrate(uint id) external view returns (uint size, uint strength) {
        crates memory crate = crates_mapping[id];
        require(crate.size != 0 || crate.strength != 0, "Crate does not exist");
        
        return (crate.size, crate.strength);
    }

    /// @notice Retrieve the IDs of all existing crates.
    function getCrateIds() external view returns (uint[] memory) {
        return is_init;
    }
    /// @notice Delete a crate by id. Fails if id doesn't belong to an existing crate.
    function deleteCrate(uint id) external {
        require(crates_mapping[id].size != 0 || crates_mapping[id].strength != 0, "Crate does not exist");

        delete crates_mapping[id];
        is_init[id_index[id]] = is_init[is_init.length-1];
        is_init.pop;
        delete id_index[id];
        // // Remove id from crateIds array (not optimal, but simple)
        // for (uint i = 0; i < is_init.length; i++) {
        //     if (is_init[i] == id) {
        //         is_init[i] = is_init[is_init.length - 1];
        //         is_init.pop();
        //         break;
        //     }
        // }
    }
}