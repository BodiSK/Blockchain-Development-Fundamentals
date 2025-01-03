// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;



contract Crowdfunding {
    uint256 public goalAmount; 
    uint256 public endTime; 
    uint256 public totalContributed; 
    bool public goalReached; 
    mapping (address => uint256) public contributions;

    constructor(uint256 _goalAmount, uint256 _campaignDurationInDays) {
        require(_goalAmount > 0, "Goal amount must be greater than zero.");
        require(_campaignDurationInDays > 0, "Campaign duration must be positive.");

        goalAmount = _goalAmount;
        endTime = block.timestamp + (_campaignDurationInDays * 1 days);
        goalReached = false;
    }


    function contribute(uint256 baseUnits) external {
        if (block.timestamp > endTime) revert ("Campaign ended.");
        if (goalReached) revert ("Goal already reached");

        contributions[msg.sender] += baseUnits;
        totalContributed += baseUnits;

        if (totalContributed >= goalAmount) {
            goalReached = true;
        }
    }

    function checkGoalReached() external view returns (bool) {
        return goalReached;
    }


    function withdraw() external {
        if(goalReached) {
            revert ("Cannot withdraw when goal has been reached");
        }

        if(block.timestamp<endTime) {
            revert ("Fund has not yet expired");
        }

        contributions[msg.sender] =0;
        totalContributed = 0;
    }
}