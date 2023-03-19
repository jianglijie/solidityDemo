const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log(
      "Deploying contracts with the account:",
      await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const StakeReward = await ethers.getContractFactory("StakeReward");
  const stakeReward = await StakeReward.deploy("0xF1059A66b397b674F9b23109A94f11a837e86bdB");

  await stakeReward.deployed();

  console.log("Token address:", stakeReward.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });