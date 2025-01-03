// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;


abstract contract PaymentProcessor {
    mapping(address=>uint256) internal  balance;
    mapping(address=>bool) internal isLoyal;

    function receivePayment() external payable {
        require(msg.value > 0, "No Ether sent");
        balance[msg.sender] += msg.value;
    }

    function checkBalance() external view returns (uint256){
        return balance[msg.sender];
    }

    function refundPayment() public virtual {
        uint256 funds = balance[msg.sender];
        balance[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value:funds}("");
        require(success, "Unable to perform refund");
    } 
} 

contract Merchant is PaymentProcessor {
    function setLoyalty(address user, bool status) external {
        isLoyal[user] = status;
    }

    function refundPayment() public override {
        uint256 funds = balance[msg.sender];
        balance[msg.sender] = 0;

        if(isLoyal[msg.sender]) {
            funds+=funds/100;
        }

        (bool success, )=payable(msg.sender).call{value:funds}("");
            require(success, "Unable to perform refund");
    }
}