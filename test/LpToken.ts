import {loadFixture} from "ethereum-waffle";

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LpToken Test", function () {
    const INITIAL_SUPPLY = 500000000000000000000n;

    async function deployLpTokenFixture() {// 可以多个状态
        const [owner] = await ethers.getSigners();
        const LpToken = await ethers.getContractFactory("LpToken");
        const lpToken = await LpToken.deploy();

        return {owner, lpToken}
    }

    it("name and symbol", async function() {
       const {lpToken} = await loadFixture(deployLpTokenFixture);

       expect(await lpToken.name()).to.equal("lp token demo");
       expect(await lpToken.symbol()).to.equal("LTD");
    });

    it("total supply", async function() {
        const {lpToken} = await loadFixture(deployLpTokenFixture);

        expect(await lpToken.totalSupply()).to.equal(INITIAL_SUPPLY);
    });
});