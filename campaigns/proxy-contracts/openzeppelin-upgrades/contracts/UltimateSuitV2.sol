// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";


contract UltimateSuitV2 is ERC721Upgradeable {
    enum Status {
        CONFIRMED_BY_A,
        CONFIRMED_BY_B,
        LAUNCHED
        //DETONATED
    }

    struct BombStats {
        address target;
        uint256 damage;
        //uint8 transfersLeft;  // Transfers before bomb detonates
        Status status;
    }
    address private pilotA;
    address private pilotB;
    uint256 public bombCount;
    mapping (uint => BombStats) private bombStats;
    string _name;
    string _symbol;
    bool is_initialize;
    uint8 constant TRANSFERS = 3;
    mapping(uint256=>bool)detonated;
    mapping(uint256=>uint8)transfersLeft;
    event Detonate(uint256 bombId);
    

    modifier isPilot(address _address) {
        require(_address == pilotA || _address == pilotB, "Not a pilot");
        _; 
    }

    modifier isUnconfirmed(uint256 _bombId, address _pilot) {
        require(_bombId < bombCount, "Bomb not initialized");

        Status expectedStatus = msg.sender == pilotA 
            ? Status.CONFIRMED_BY_B 
            : Status.CONFIRMED_BY_A;
        require(bombStats[_bombId].status == expectedStatus, "msg.sender already confirmed bomb");

        _; 
    }

    //constructor() ERC721("Ultimate Suit", "SUIT") {}
    function initialize(address _pilotA, address _pilotB)external{
        require(!is_initialize , "already init");
        _name = "Ultimate Suit";
        _symbol = "SUIT";
        pilotA = _pilotA;
        pilotB = _pilotB;
        is_initialize = true;
    }
    function createBomb(
        address _initialTarget, 
        uint256 _damage
    ) public isPilot(msg.sender) returns (uint256 bombId) {
        _mint(address(this), bombCount);
        BombStats storage stats = bombStats[bombCount];
        stats.target = _initialTarget;
        stats.damage = _damage;
        stats.status = msg.sender == pilotA
            ? Status.CONFIRMED_BY_A
            : Status.CONFIRMED_BY_B;

        return bombCount++;
    }

    function confirmBomb(uint256 bombId) public 
        isPilot(msg.sender) 
        isUnconfirmed(bombId, msg.sender)
    {
        bombStats[bombId].status = Status.LAUNCHED;
        transfersLeft[bombId] = TRANSFERS;
        _transfer(
            address(this), 
            bombStats[bombId].target,
            bombId
        );
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */

    function symbol() public view override returns (string memory) {
        return _symbol;
    }
    function getPilots() external view returns (address, address) {
        return (pilotA, pilotB);
    }
    
    function _transfer(
        address from, 
        address to, 
        uint256 bombId
    ) internal override {
        //require(bombStats[bombId].status != Status.DETONATED, "Bomb already detonated");
        require(!detonated[bombId], "Bomb already detonated");

        //bombStats[bombId].transfersLeft--;
        transfersLeft[bombId]--;
        // if (bombStats[bombId].transfersLeft == 0) {
        //     emit Detonate(bombId);
        //     bombStats[bombId].status = Status.DETONATED;
        // }
        if (transfersLeft[bombId] == 0) {
            emit Detonate(bombId);
            //bombStats[bombId].status = Status.DETONATED;
            detonated[bombId] = true;
        }
        super._transfer(from, to, bombId);
    }

}