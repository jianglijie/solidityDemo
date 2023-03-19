const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log(
      "Deploying contracts with the account:",
      await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const LpToken = await ethers.getContractFactory("LpToken");
  const lpToken = await LpToken.deploy();

  await lpToken.deployed();

  console.log("Token address:", lpToken.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });