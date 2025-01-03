
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error InvalidRate();
error InvalidYear();

contract CompoundInterestCalculator {
    function calculateCompoundInterest(
        int256 principal,
        int256 rate,
        int256 year
    ) external pure returns (int256 balance) {
        // Validate inputs
        if (rate < 0 || rate > 100) revert InvalidRate();
        if (year < 1) revert InvalidYear();

        balance = principal;

        // Scale rate to avoid division errors
        for (int256 i = 0; i < year; i++) {
            balance = (balance * (100 + rate)) / 100;
        }
    }
}