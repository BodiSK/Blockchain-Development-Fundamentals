const { task } = require("hardhat/config");

task("deploy", "Deploys the Staking Pool and Staking Token contracts")
  .addOptionalParam("stakingTokenOwner", "The owner of the staking token")
  .addOptionalParam("stakingPoolOwner", "The owner of the staking pool")
  .setAction(async (taskArguments, hre) => {
    const [deployer] = await hre.ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const stakingTokenOwner =
      taskArguments.stakingTokenOwner || deployer;
    const stakingPoolOwner = taskArguments.stakingPoolOwner || deployer;

    console.log("Deploying Staking Token...");
    const stakingTokenFactory = await hre.ethers.getContractFactory(
      "StakingToken"
    );
    const stakingToken = await stakingTokenFactory
      .connect(deployer)
      .deploy(stakingTokenOwner);
    await stakingToken.waitForDeployment();
    console.log("Staking Token deployed to:", await stakingToken.getAddress());

    console.log("Deploying Staking Pool...");
    const stakingPoolFactory = await hre.ethers.getContractFactory(
      "StakingPool"
    );
    const stakingPool = await stakingPoolFactory
      .connect(deployer)
      .deploy(await stakingToken.getAddress(), stakingPoolOwner);
    await stakingPool.waitForDeployment();
    console.log("Staking Pool deployed to:", await stakingPool.getAddress());

    console.log("Granting minter role to Staking Pool");
    await stakingToken.deploymentTransaction().wait(1);
    await stakingPool.deploymentTransaction().wait(1);

    await stakingToken
      .connect(stakingTokenOwner)
      .grantMinterRole(await stakingPool.getAddress());
    console.log("Minter role granted to Staking Pool");
  });
