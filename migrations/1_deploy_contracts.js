const Insurace_Policy = artifacts.require("Insurance_Policy")
const Insurace_Factory = artifacts.require("Insurance_Factory")
const Simple_Storage = artifacts.require("SimpleStorage")

module.exports = function(deployer) {
  // deployer.deploy(Insurace_Policy, "0x91d1368fd9c618c0df8522f6f082c8a5c7794167",
  // 1, 1)
  deployer.deploy(Insurace_Factory, ["0x91d1368fd9c618c0df8522f6f082c8a5c7794167"], 8);
  deployer.deploy(Insurace_Policy, 1, "0x62B72B6dC51cD817B3Ea0f050bB4517ADeBACCC1", 31, "0x91d1368fd9c618c0df8522f6f082c8a5c7794167");

  deployer.deploy(Simple_Storage);
};
