const EkkTokenv1 = artifacts.require("./EkkTokenv1.sol")

module.exports = function(deployer) {
	deployer.deploy(EkkTokenv1,5000000000,"BZCOIN","%BZ");
}
