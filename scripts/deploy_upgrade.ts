const { ethers, upgrades } = require("hardhat");

async function main() {
    // 这里的地址为前面部署的代理合约地址
    const proxyAddress = '0x0BC2Ac46F3B0C428D1eDC78Aa440C239cec91F8E';

    const ProxyDemoUpgrade = await ethers.getContractFactory("ProxyDemoUpgrade");
    console.log("Preparing upgrade...");
    await upgrades.upgradeProxy(proxyAddress, ProxyDemoUpgrade);
}

main();