const SafeMath = artifacts.require('./SafeMath.sol');
const BonumFinancialToken = artifacts.require("./BonumFinancialToken.sol");
const Investors = artifacts.require("./InvestorsList.sol");
const BonumFinancialTokenPreSale = artifacts.require("./BonumFinancialTokenPreSale.sol");

module.exports = function (deployer) {
    deployer.deploy(SafeMath);
    deployer.link(SafeMath, BonumFinancialToken);
    deployer.deploy(BonumFinancialToken).then(async function () {
        await deployer.deploy(Investors);
        const startDate = 1512950400;
        const endDate = 1514073600;
        await deployer.deploy(BonumFinancialTokenPreSale, startDate, endDate, BonumFinancialToken.address, Investors.address, [], 1, 1);
    });

};
