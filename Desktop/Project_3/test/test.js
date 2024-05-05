const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
//import abi from "../abi.json";
//const { ethers, upgrades } = require("hardhat");
// require("dotenv").config();
//import abi from "../abi.json"
async function main() {
  const contract = await ethers.getContractFactory("IOU");
  const rd = await contract.attach("0xDCC31Ed2ae75B872c745861a59B9029f10C012Db");
  let alice = "0x1044C2b2547F7e4fAF95FdfC2bDB16f0cBE38199";
  let bob = "0xf36C2c821E3e8f62eB1189453126b0b5D601F143";
  let cim = "0x22bB87DB41bAFC3D826a699cFb80513D1d07b140";
  //const tx1 = await rd.add_IOU(alice,"240");
  //await tx1.wait();
  const tx2 = await rd.lookup(bob,cim);
  console.log(tx2);
}

  main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })