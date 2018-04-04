const EkkTokenv1 = artifacts.require("./EkkTokenv1.sol")

module.exports = function(deployer) {
	deployer.deploy(EkkTokenv1,1,"BZCOIN2","%BZ",{from:web3.eth.accounts[0], value:1000000000000000000000});
}
