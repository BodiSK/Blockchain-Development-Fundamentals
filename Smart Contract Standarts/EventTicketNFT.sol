// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error UnauthorizedAccess();
error InvalidID();
error InvalidTokenOwner();

contract EventTicketNFT is ERC721 {

    struct TicketMetadata {
        string eventName;
        string eventDate;
        string seatNumber;
    }

    mapping(uint256 => TicketMetadata) public tickets;
    uint256 private ticketIDCounter; // will start from 0 - e.g the first sold ticket will be with ID 0
    address public owner;

    constructor() ERC721("EventTicketNFT", "ETN") {
        owner = msg.sender;
    }

    function mintTicket(
        address buyer,
        string memory _eventName,
        string memory _eventDate,
        string memory _seatNumber
    ) external {
        if(msg.sender != owner) {
            revert UnauthorizedAccess();
        }

        uint256 ticketID = ticketIDCounter++;
        
        _mint(buyer, ticketID);

        tickets[ticketID] = TicketMetadata(_eventName, _eventDate, _seatNumber);
    }

    function transferTicket(address _from, address _to, uint256 _tickedId) external{
        if(msg.sender != owner) {
            revert UnauthorizedAccess();
        }

        if(_ownerOf(_tickedId) == address(0)) {
            revert InvalidID();
        }

        if(_ownerOf(_tickedId) != _from) {
            revert InvalidTokenOwner();
        }

        _safeTransfer(_from, _to, _tickedId);

    }

}
