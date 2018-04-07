const CrowdSale = artifacts.require("./CrowdSale.sol")

module.exports = function(deployer) {
deployer.deploy(CrowdSale,
	'0xf25EE62883EC073CeBf881e8c4939Bc75D324FeD',
	100,180,1,
	'0xf75b5485ee6784332b308cc3c3077935537f21be');
}
