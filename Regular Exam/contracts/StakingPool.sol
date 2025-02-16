// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IStakingToken} from "./IStakingToken.sol";

error InsufficientStakeAmount();
error InsufficientTokenBalance();
error InsufficientAllowance();
error NoRewardsToClaim();
error CannotUnstakeZeroAmount();
error AmountExceedsStakedBalance();
error MinterRoleNotGranted();

struct Staker {
    uint256 stakedBalance;
    uint256 rewardBalance;
    uint256 stakingStartTime;
}

contract StakingPool is Ownable {
    address public token;
    uint256 public constant REWARD_RATE = 5;

    mapping(address => Staker) public stakers;

    event StakePlaced(
        address indexed staker,
        uint256 indexed amount
    );

    event RewardClaimed(
        address indexed staker,
        uint256 indexed reward
    );

    event TokensUnstaked(
        address indexed staker,
        uint256 indexed reward
    );

    constructor(address _token, address owner) Ownable(owner) {
        token = _token;
    }

    function stake(uint256 amount) external {
        if (amount == 0) {
            revert InsufficientStakeAmount();
        }

        if (IStakingToken(token).balanceOf(msg.sender) < amount) {
            revert InsufficientTokenBalance();
        }

        if (
            IStakingToken(token).allowance(msg.sender, address(this)) < amount
        ) {
            revert InsufficientAllowance();
        }

        if(!IStakingToken(token).hasRole(keccak256("MINTER_ROLE"), address(this))) {
            //prevent user to lock tokens in contract if minter role is not granted
            revert MinterRoleNotGranted();
        }

        if (stakers[msg.sender].stakedBalance == 0) {
            stakers[msg.sender] = Staker({
                stakedBalance: amount,
                rewardBalance: 0,
                stakingStartTime: block.timestamp
            });
        } else {
            updateRewardBalance(msg.sender);
            stakers[msg.sender].stakedBalance += amount;
        }

        IStakingToken(token).transferFrom(msg.sender, address(this), amount);

        emit StakePlaced(msg.sender, amount);
    }

    function claimRewards() external {
        if (stakers[msg.sender].stakedBalance == 0) {
            revert NoRewardsToClaim();
        }

        updateRewardBalance(msg.sender);

        uint256 reward = stakers[msg.sender].rewardBalance;

        stakers[msg.sender].rewardBalance = 0;
        IStakingToken(token).mint(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }

    function unstake(uint256 amount) external {
        if (amount == 0) {
            revert CannotUnstakeZeroAmount();
        }

        if (stakers[msg.sender].stakedBalance < amount) {
            revert AmountExceedsStakedBalance();
        }

        updateRewardBalance(msg.sender);

        stakers[msg.sender].stakedBalance -= amount;
        IStakingToken(token).transfer(msg.sender, amount);

        emit TokensUnstaked(msg.sender, amount);
    }

    function updateRewardBalance(address user) internal {
        uint256 currentTimestamp = block.timestamp;
        Staker storage staker = stakers[user];
        uint256 timeElapsed = currentTimestamp - staker.stakingStartTime;
        uint256 reward = (staker.stakedBalance *
            REWARD_RATE *
            timeElapsed *
            10 ** IStakingToken(token).decimals()) / (365 days * 100);
        staker.rewardBalance += reward;
        staker.stakingStartTime = currentTimestamp;
    }
}
