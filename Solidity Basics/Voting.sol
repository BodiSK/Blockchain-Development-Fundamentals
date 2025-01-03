// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;


struct Voter {
    bool hasVoted;
    uint256 choice;
}

contract Voting {
    mapping (address => Voter) public voters;

    function registerVote (uint256 _choice) external {
        require(voters[msg.sender].hasVoted != true, "Voter already gave vote");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].choice = _choice;
    }

    function getVoterStatus () external view returns (bool voteStatus, uint256 voterChoice) {
        voteStatus = voters[msg.sender].hasVoted;
        voterChoice = voters[msg.sender].choice;
    }


}