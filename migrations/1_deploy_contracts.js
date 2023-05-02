const Insurace_Policy = artifacts.require("./insurance_policy.sol")
const Insurace_Factory = artifacts.require("./insurance_factory.sol")

module.exports = function(deployer) {
  // deployer.deploy(Insurace_Policy, "0x91d1368fd9c618c0df8522f6f082c8a5c7794167",
  // 1, 1)
  deployer.deploy(Insurace_Factory, ["0x91d1368fd9c618c0df8522f6f082c8a5c7794167"])
};
