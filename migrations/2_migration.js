const EkkTokenv1 = artifacts.require("./EkkToken.sol")

module.exports = function(deployer) {
	deployer.deploy(EkkTokenv1,1,"EkkRewardToken","☐");
}
