// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;


interface  ILoyaltyPoints {
    function rewardPoints(address customer, uint256 amount) external;
    function redeemPoints(address customer, uint256 amount) external;
    
}