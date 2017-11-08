var SafeMath = artifacts.require('./SafeMath.sol');
var BonumFinancialToken = artifacts.require("./BonumFinancialToken.sol");

module.exports = function(deployer) {
    deployer.deploy(SafeMath);
    deployer.link(SafeMath, BonumFinancialToken);
    deployer.deploy(BonumFinancialToken);
};
