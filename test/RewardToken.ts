import {loadFixture} from "ethereum-waffle";

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RewardToken Test", function () {
    async function deployRewardTokenFixture() {
        const [owner, addr1, addr2] = await ethers.getSigners();
        const RewardToken = await ethers.getContractFactory("RewardToken");
        const rewardToken = await RewardToken.deploy();

        return {owner, addr1, addr2, rewardToken}
    }

    it("name and symbol", async function() {
       const {rewardToken} = await loadFixture(deployRewardTokenFixture);

       expect(await rewardToken.name()).to.equal("reward token demo");
       expect(await rewardToken.symbol()).to.equal("RTD");
    });

    it("mint", async function() {
        const {rewardToken, owner, addr1} = await loadFixture(deployRewardTokenFixture);

        await expect(rewardToken.connect(owner).mint(addr1.address, 100)).to.emit(rewardToken, "Transfer").
        withArgs(ethers.constants.AddressZero, addr1.address, 100);

        expect(await rewardToken.balanceOf(addr1.address)).to.equal(100);
        expect(await rewardToken.totalSupply()).to.equal(100);
    });

    it("mint only owner", async function() {
        const {rewardToken, owner, addr1} = await loadFixture(deployRewardTokenFixture);

        await expect(rewardToken.connect(addr1).mint(addr1.address, 100)).to.revertedWith("Ownable: caller is not the owner");
    });
});