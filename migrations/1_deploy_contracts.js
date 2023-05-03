const Insurace_Policy = artifacts.require("Insurance_Policy")
const Insurace_Factory = artifacts.require("Insurance_Factory")

const owner_account = "0xbdb103a000430744e9104d62019E3dC34315c812";

module.exports = function(deployer) {
  // deployer.deploy(Insurace_Policy, "0x91d1368fd9c618c0df8522f6f082c8a5c7794167",
  // 1, 1)
  deployer.deploy(Insurace_Factory, [owner_account])
  deployer.deploy(Insurace_Policy, 20, 31)
};