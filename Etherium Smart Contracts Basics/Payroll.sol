// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

error InvalidSalary();
error InvalidRating();

contract Payroll {
    int bonus = 10;

    function calculatePaycheck(int256 salary, int256 rating) view external returns (int256 paycheck){
        if (salary <=0) revert InvalidSalary();
        if (! (rating>0 && rating<=10) ) revert InvalidRating();

        paycheck = salary;

        if(rating >=8) paycheck+=(bonus*paycheck)/100;
    }
}