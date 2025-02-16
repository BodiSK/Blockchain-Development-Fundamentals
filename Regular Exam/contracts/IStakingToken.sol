// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;


import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

interface IStakingToken is IERC20, IAccessControl {
    function mint(address to, uint256 amount) external;
    function grantMinterRole(address account) external;
    function revokeMinterRole(address account) external;
    function decimals() external view returns (uint8);
}