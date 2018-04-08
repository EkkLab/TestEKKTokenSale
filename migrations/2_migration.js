var EkkToken = artifacts.require("EkkToken.sol")
var CrowdSale = artifacts.require("CrowdSale")
var benificiary = web3.eth.accounts[1]

module.exports = function(deployer) {
	deployer.deploy(EkkToken,100000000,"EKK","☐").then(function () {
		return deployer.deploy(CrowdSale,
			benificiary,100,180,1,20,EkkToken.address);
		})
	}
