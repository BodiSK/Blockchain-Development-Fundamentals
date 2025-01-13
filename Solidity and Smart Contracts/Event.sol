// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

error TicketsAlreadySold();

contract Event is ERC721, Ownable {
    uint256 private _nextTokenId;
    uint256 public immutable date;
    string public location;

    bool public immutable priceCapOn;
    address public whitelisted;
    uint256 public immutable ticketAvailability;
    address public immutable organizer;

    constructor(
        address minter,
        string memory name_, 
        uint256 date_, 
        string memory location_, 
        uint256 ticketAvailability_,
        address organizer_, 
        bool priceCapOn_, 
        address whitelisted_)
    ERC721(name_, "")
    Ownable(minter)
    {
        date = date_;
        location = location_;
        ticketAvailability = ticketAvailability_;
        organizer = organizer_;
        priceCapOn = priceCapOn_;
        if(priceCapOn) {
            whitelisted = whitelisted_;
        }
    }

    function safeMint(address to) public onlyOwner {
        if(_nextTokenId == ticketAvailability) {
            revert TicketsAlreadySold();
        }

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

     function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        if(priceCapOn && (msg.sender != owner() || to != whitelisted)) {
            revert ("Cannot transfer to given address due to Price Cap");
        }

        return super._update(to, tokenId, auth);
     }
}
