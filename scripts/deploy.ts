const hre = require("hardhat");

async function main() {

    const token = await hre.ethers.deployContract("STMToken");
    await token.waitForDeployment();
    const tokenAddress = await token.getAddress();
    console.log(`Token contract deployed on: ${tokenAddress}`);

    const bridge = await hre.ethers.deployContract("Bridge", [tokenAddress]);
    await bridge.waitForDeployment();
    const bridgeAddress = await bridge.getAddress();
    console.log(`Bridge contract deployed on: ${bridgeAddress}`);

    await token.transfer(bridgeAddress, hre.ethers.parseEther('1000'));
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});