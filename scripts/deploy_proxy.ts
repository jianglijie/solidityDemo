const { ethers, upgrades } = require("hardhat");

async function main() {
    const ProxyDemo = await ethers.getContractFactory("ProxyDemo");
    console.log("Deploying ProxyDemo...");
    const demo = await upgrades.deployProxy(ProxyDemo, [123], { initializer: 'initialize' });
    // 代理合约地址
    console.log("Demo deployed to:", demo.address);
}

main();