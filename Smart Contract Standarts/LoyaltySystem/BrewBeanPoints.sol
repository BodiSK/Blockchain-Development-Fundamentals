// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "Smart Contract Standarts/LoyaltySystem/BaseLoyaltyProgram.sol";

contract BrewBeanPoints is ERC20, BaseLoyaltyProgram {
    constructor() ERC20("BrewBeanPoints", "BBP") {
        owner = msg.sender;
    }

    function _authorizeReward(address _to, uint256 reward) internal override pure{
        require(_to != address(0), "Invalid customer address");
        require(reward > 0, "Amount must be greater than zero");
    }

    function _reward(address _to, uint256 reward) internal override {
        _mint(_to, reward);
        emit Rewarded(_to, reward);
    }

    function _redeem(address _to, uint256 reward) internal override {
        _burn(_to, reward);
        emit Redeemed(_to, reward);
    }

}