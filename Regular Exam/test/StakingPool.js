const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("StakingPool", function () {
  const REWARD_RATE = 5;
  
  async function initialDeploymentFixture() {
    const [deployer, stakingPoolOwner, stakingTokenOwner, staker] =
      await ethers.getSigners();

    const stakingTokenFactory = await ethers.getContractFactory("StakingToken");
    const stakingToken = await stakingTokenFactory
      .connect(deployer)
      .deploy(stakingTokenOwner.address);

    const stakingPoolFactory = await ethers.getContractFactory("StakingPool");
    const stakingPool = await stakingPoolFactory
      .connect(deployer)
      .deploy(await stakingToken.getAddress(), stakingPoolOwner.address);

    // Granting minter role to staking pool
    await stakingToken
      .connect(stakingTokenOwner)
      .grantMinterRole(await stakingPool.getAddress());

    return {
      deployer,
      stakingPoolOwner,
      stakingTokenOwner,
      staker,
      stakingToken,
      stakingPool,
    };
  }

  describe("Stake", function () {
    it("Should check if stake function reverts if staked amount is zero", async function () {
      const { staker, stakingPool } = await loadFixture(
        initialDeploymentFixture
      );

      await expect(
        stakingPool.connect(staker).stake(0)
      ).to.be.revertedWithCustomError(stakingPool, "InsufficientStakeAmount");
    });

    it("Should check if stake function reverts if staker does not have enough token balance", async function () {
      const { stakingTokenOwner, staker, stakingToken, stakingPool } =
        await loadFixture(initialDeploymentFixture);

      const stakerBalance = ethers.parseUnits("2", 8);
      const stakerStake = ethers.parseUnits("3", 8);

      await stakingToken
        .connect(stakingTokenOwner)
        .transfer(staker.address, stakerBalance);

      await expect(
        stakingPool.connect(staker).stake(stakerStake)
      ).to.be.revertedWithCustomError(stakingPool, "InsufficientTokenBalance");
    });

    it("Should check if stake function reverts if staking pool does not have sufficient allowance", async function () {
      const { stakingTokenOwner, staker, stakingToken, stakingPool } =
        await loadFixture(initialDeploymentFixture);

      const stakerBalance = ethers.parseUnits("2", 8);
      await stakingToken
        .connect(stakingTokenOwner)
        .transfer(staker.address, stakerBalance);

      await expect(
        stakingPool.connect(staker).stake(stakerBalance)
      ).to.be.revertedWithCustomError(stakingPool, "InsufficientAllowance");
    });

    it("Should check if stake function passes if setup is correct", async function () {
      const { stakingTokenOwner, staker, stakingToken, stakingPool } =
        await loadFixture(initialDeploymentFixture);

      const stakerBalance = ethers.parseUnits("2", 8);
      await stakingToken
        .connect(stakingTokenOwner)
        .transfer(staker.address, stakerBalance);

      await stakingToken
        .connect(staker)
        .approve(await stakingPool.getAddress(), stakerBalance);

      await expect(stakingPool.connect(staker).stake(stakerBalance)).to.not.be
        .reverted;
    });

    it("Should check if event is emiited when stake is placed successfully", async function () {
      const { stakingTokenOwner, staker, stakingToken, stakingPool } =
        await loadFixture(initialDeploymentFixture);

      const stakerBalance = ethers.parseUnits("2", 8);
      await stakingToken
        .connect(stakingTokenOwner)
        .transfer(staker.address, stakerBalance);

      await stakingToken
        .connect(staker)
        .approve(await stakingPool.getAddress(), stakerBalance);

      await expect(stakingPool.connect(staker).stake(stakerBalance))
        .to.emit(stakingPool, "StakePlaced")
        .withArgs(staker.address, stakerBalance);
    });

    it("Should check if stake is made successfully when staker stakes for first time", async function () {
      const { stakingTokenOwner, staker, stakingToken, stakingPool } =
        await loadFixture(initialDeploymentFixture);

      const stakerBalance = ethers.parseUnits("2", 8);
      await stakingToken
        .connect(stakingTokenOwner)
        .transfer(staker.address, stakerBalance);

      await stakingToken
        .connect(staker)
        .approve(await stakingPool.getAddress(), stakerBalance);

      await stakingPool.connect(staker).stake(stakerBalance);
      const stake = await stakingPool.stakers(staker.address);

      expect(await stake.stakedBalance).to.equal(stakerBalance);
      expect(await stake.rewardBalance).to.equal(0);
      expect(await stake.stakingStartTime).to.equal(await time.latest());
    });

    it("Should check if balances are updated successfully when another stake is placed", async function () {
      const { stakingTokenOwner, staker, stakingToken, stakingPool } =
        await loadFixture(initialDeploymentFixture);

      const stakerBalance = ethers.parseUnits("5", 8);
      const firstStake = ethers.parseUnits("2", 8);
      const secondStake = ethers.parseUnits("3", 8);

      await stakingToken
        .connect(stakingTokenOwner)
        .transfer(staker.address, stakerBalance);

      await stakingToken
        .connect(staker)
        .approve(await stakingPool.getAddress(), firstStake);

      const firstStakeTime = await time.latest();
      await stakingPool.connect(staker).stake(firstStake);

      const secondStakeDelay = 1000;
      await time.increase(secondStakeDelay);

      await stakingToken
        .connect(staker)
        .approve(await stakingPool.getAddress(), secondStake);
      const secondStakeTime = await time.latest();
      await stakingPool.connect(staker).stake(secondStake);

      const timeElapsed = secondStakeTime - firstStakeTime;
      const expectedStakedBalance = firstStake + secondStake;
      const expectedRewardBalance =
        (firstStake *
          BigInt(REWARD_RATE) *
          BigInt(timeElapsed) *
          BigInt(10 ** 8)) /
        BigInt(365 * 24 * 60 * 60 * 100);

      const stake = await stakingPool.stakers(staker.address);
      expect(await stake.stakedBalance).to.equal(expectedStakedBalance);
      expect(await stake.rewardBalance).to.equal(expectedRewardBalance);
    });

    it("Should check if tokens are transfered upon successfull stake", async function () {
      const { stakingTokenOwner, staker, stakingToken, stakingPool } =
        await loadFixture(initialDeploymentFixture);

      const stakeAmount = ethers.parseUnits("2", 8);

      await stakingToken
        .connect(stakingTokenOwner)
        .transfer(staker.address, stakeAmount);

      await stakingToken
        .connect(staker)
        .approve(await stakingPool.getAddress(), stakeAmount);

      await expect(
        stakingPool.connect(staker).stake(stakeAmount)
      ).to.changeTokenBalances(
        stakingToken,
        [staker, stakingPool],
        [stakeAmount * -1n, stakeAmount]
      );
    });
  });
});
