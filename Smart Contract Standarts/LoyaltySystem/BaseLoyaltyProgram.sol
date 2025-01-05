// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "Smart Contract Standarts/LoyaltySystem/ILoyaltyPoints.sol";

error UanthorizedAccess();

abstract contract BaseLoyaltyProgram is ILoyaltyPoints{

    mapping(address=>bool) public partners;
    address public owner;

    event Rewarded(address indexed customer, uint256 reward);
    event Redeemed(address indexed customer, uint256 reward);

    modifier onlyPartner() {
        require(partners[msg.sender], "Not an authorized partner");
        _;
    }

    function addPrtner(address partner) external{
        if(msg.sender != owner) {
            revert UanthorizedAccess();
        }

        partners[partner] = true;
    }

    function removePartner(address partner) external{
        if(msg.sender != owner) {
            revert UanthorizedAccess();
        }

        partners[partner] = false;
    }

    function _authorizeReward(address _to, uint256 reward) internal virtual;

    function rewardPoints(address _to, uint256 reward) external onlyPartner{
        _authorizeReward(_to, reward);
        _reward(_to, reward);
    }

    function redeemPoints(address _to, uint256 reward) external onlyPartner{
        _authorizeReward(_to, reward);
        _redeem(_to, reward);
    }


    function _reward(address _to, uint256 reward) internal virtual;

    function _redeem(address _to, uint256 reward) internal virtual;
}