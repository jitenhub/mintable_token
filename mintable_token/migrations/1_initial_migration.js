const MintableToken = artifacts.require("./MintableToken.sol");

module.exports = function(deployer) {
  deployer.deploy(MintableToken);
};
