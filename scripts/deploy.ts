import { ethers } from "hardhat";
// async function main() {
//   const currentTimestampInSeconds = Math.round(Date.now() / 1000);
//   const unlockTime = currentTimestampInSeconds + 60;

//   const lockedAmount = ethers.parseEther("0.001");

//   const lock = await ethers.deployContract("Game", [unlockTime], {
//     value: lockedAmount,
//   });

//   await lock.waitForDeployment();

//   console.log(
//     `Lock with ${ethers.formatEther(
//       lockedAmount
//     )}ETH and unlock timestamp ${unlockTime} deployed to ${lock.target}`
//   );
// }

// // We recommend this pattern to be able to use async/await everywhere
// // and properly handle errors.
// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });

async function main() {
  const  [deployer ] = await ethers.getSigners();
  const contract = await ethers.deployContract("Game");
  console.log("deployed");
  await contract.waitForDeployment();
  console.log(`Contract deployed to ${contract.target}`);
  console.log(`Contract deployed by ${deployer.address}`);
  // fs.writeFileSync("abi.json", JSON.stringify(contract.interface));
}

main().catch((error) => {
  console.error(error);
  console.log("efefef");
  process.exit(1);
})
