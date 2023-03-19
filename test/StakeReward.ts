const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Transactions", function () {

    it("deposit", async function() {
        const [owner, addr1, addr2] = await ethers.getSigners();

        const LpToken = await ethers.getContractFactory("LpToken");
        const lpToken = await LpToken.deploy();
        await lpToken.deployed();
        console.log("lpToken address:", lpToken.address);

        const RewardToken = await ethers.getContractFactory("RewardToken");
        const rewardToken = await RewardToken.deploy();
        await rewardToken.deployed();
        console.log("rewardToken address:", rewardToken.address);

        const StakeReward = await ethers.getContractFactory("StakeReward");
        const stakeReward = await StakeReward.deploy(rewardToken.address);
        await stakeReward.deployed();
        console.log("stakeReward address:", stakeReward.address);

        const tx1 = await stakeReward.add(100, lpToken.address)
        await tx1.wait();


        const tx2 = await stakeReward.deposit(0, 12, owner.address)
        await tx2.wait();
    });
});