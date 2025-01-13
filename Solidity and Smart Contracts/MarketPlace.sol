// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Event} from "./Event.sol";

error InvalidInput(string args);
error EventAlreadyListed();
error NotOrganizer();
error WithdrawFailed();

enum BuyingOption {
    FixedPrice,
    Bidding
}

struct EventData {
    uint256 ticketPrice;
    BuyingOption saleType;
    uint256 salesEnd;
}

contract MarketPalce {

    uint256 public constant MIN_SALE_PERIOD = 24 hours; 
    uint256 public constant SALE_FEE = 0.1 ether;
    address public immutable feeCollector;
    mapping(address => EventData) public events;
    mapping (address => uint256) public profits;
    mapping(address => mapping(uint256 => bool)) public secondaryMarketListings;

    event NewEvent(address indexed newEvent);

    constructor(address feeCollector_){
        feeCollector = feeCollector_;
    }

    function createEvent(
        string memory name, 
        uint256 date, 
        string memory location, 
        uint256 ticketAvailability,
        uint256 ticketPrice, 
        BuyingOption saleType,
        uint256 salesEnd,
        bool priceCapOn_, 
        address whitelisted_
    ) external {
        address newEvent = address(new Event(address(this),name, date, location,ticketAvailability, msg.sender,priceCapOn_, whitelisted_ ));
        _listEvent(newEvent, ticketPrice, saleType, salesEnd);
        emit NewEvent(newEvent);
    }

    function listEvent(
        address newEvent,
        uint256 ticketPrice, 
        BuyingOption saleType,
        uint256 salesEnd
    ) external { 
        if(msg.sender != Event(newEvent).organizer()) {
            revert NotOrganizer();
        }

        _listEvent(newEvent, ticketPrice,saleType, salesEnd);
    }


    function _listEvent(
        address newEvent,
        uint256 ticketPrice, 
        BuyingOption saleType,
        uint256 salesEnd
    ) internal { 

        if(salesEnd < block.timestamp + MIN_SALE_PERIOD) {
            revert InvalidInput("Invalid Value for Sales End");
        }

        if(events[newEvent].salesEnd == salesEnd) {
            revert EventAlreadyListed();
        }

        if(ticketPrice < SALE_FEE) {
            revert InvalidInput("Invalid Value for Ticket Price");
        }

        events[newEvent] = EventData({
            ticketPrice: ticketPrice,
            saleType: saleType,
            salesEnd: salesEnd
        });
    }

    function buyOnSecondMarket(address event_, uint256 ticketId, address owner) external payable {
        if(events[event_].saleType != BuyingOption.FixedPrice) {
            revert InvalidInput("Wrong Sale Type for Ticket");
        }

        if(msg.value != events[event_].ticketPrice) {
            revert InvalidInput("Invalid Ticket Price Value");
        }

        profits[Event(event_).organizer()]+= msg.value - SALE_FEE;
        profits[feeCollector] += SALE_FEE; 

        Event(event_).safeTransferFrom(owner, msg.sender, ticketId);
    }

    function buyTicket(address event_) payable external{
        if(events[event_].saleType != BuyingOption.FixedPrice) {
            revert InvalidInput("Wrong Sale Type for Ticket");
        }

        if(msg.value != events[event_].ticketPrice) {
            revert InvalidInput("Invalid Ticket Price Value");
        }

        profits[Event(event_).organizer()]+= msg.value - SALE_FEE;
        profits[feeCollector] += SALE_FEE;

        Event(event_).safeMint(msg.sender);
    }

    function withdraw(address to) external payable {
        uint256 profit = profits[msg.sender];
        profits[msg.sender] = 0;

        (bool success, ) = to.call{value:profit}("");

        if(!success) {
            revert WithdrawFailed();
        }
    }
}