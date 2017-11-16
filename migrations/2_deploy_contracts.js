const SafeMath = artifacts.require('./SafeMath.sol');
const BonumFinancialToken = artifacts.require("./BonumFinancialToken.sol");
const Investors = artifacts.require("./Investors.sol");

module.exports = function(deployer) {
    deployer.deploy(SafeMath);
    deployer.link(SafeMath, BonumFinancialToken);
    deployer.deploy(BonumFinancialToken);
    deployer.deploy(Investors);
};
