// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

struct Savings {
    uint256 balance;
    address owner;
    uint256 creationTime;
    uint256 lockPeriod;
}


contract SavingsAccount {

    mapping (address => Savings[]) public plans;

    function createSavingsPlan(uint256 _lockPeriod) external payable{
        plans[msg.sender].push(
            Savings ({
                balance: msg.value,
                owner: msg.sender,
                creationTime: block.timestamp,
                lockPeriod: block.timestamp + _lockPeriod* (1 seconds)
            })
        );
    }

    function createSavingsPlan() external view returns (Savings[] memory userSavings) {
        userSavings = plans[msg.sender];
    }

    function withdrawFunds(uint256 plan) external {
        if(plans[msg.sender][plan].lockPeriod < block.timestamp){
            revert ("Plan is currently locked, since lock period has notyet expired");
        }

        uint256 amount = plans[msg.sender][plan].balance;
        plans[msg.sender][plan].balance = 0;

        // Transfer funds to the owner
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");

    }

}