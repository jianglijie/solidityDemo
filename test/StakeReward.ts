import {loadFixture} from "ethereum-waffle";

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Stake Reward", function () {
    async function deployStakeRewardFixture() {
        const [owner, addr1, addr2] = await ethers.getSigners();

        const LpToken = await ethers.getContractFactory("LpToken");
        const lpToken = await LpToken.deploy();
        await lpToken.deployed();

        const RewardToken = await ethers.getContractFactory("RewardToken");
        const rewardToken = await RewardToken.deploy();
        await rewardToken.deployed();

        const StakeReward = await ethers.getContractFactory("StakeReward");
        const stakeReward = await StakeReward.deploy(rewardToken.address);
        await stakeReward.deployed();

        return {owner, addr1, addr2, rewardToken, lpToken, stakeReward}
    }

    it("deposit", async function() {
        const {lpToken, stakeReward, owner} = await loadFixture(deployStakeRewardFixture);

        await expect(stakeReward.connect(owner).add(100, lpToken.address)).to.emit(stakeReward, "LogPoolAddition").
        withArgs(0, 100, lpToken.address);

        await expect(lpToken.connect(owner).approve(stakeReward.address, 100)).to.emit(lpToken, "Approval").
        withArgs(owner.address, stakeReward.address, 100);

        await expect(stakeReward.connect(owner).deposit(0, 100, owner.address)).to.emit(stakeReward, "Deposit").
        withArgs(owner.address, 0, 100, owner.address);
    });
});