const SafeMath = artifacts.require('./SafeMath.sol');
const BonumFinancialToken = artifacts.require("./BonumFinancialToken.sol");
const Investors = artifacts.require("./Investors.sol");
const EthRateProvider = artifacts.require("./EthRateProvider.sol");
const EurRateProvider = artifacts.require("./EurRateProvider.sol");
const BonumFinancialTokenPreSale = artifacts.require("./BonumFinancialTokenPreSale.sol");

module.exports = function (deployer) {
    deployer.deploy(SafeMath);
    deployer.link(SafeMath, BonumFinancialToken);
    deployer.deploy(BonumFinancialToken).then(async function () {
        await deployer.deploy(Investors);
        await deployer.deploy(EthRateProvider);
        await deployer.deploy(EurRateProvider);

        const startDate = 1512950400;
        const endDate = 1514073600;
        await deployer.deploy(BonumFinancialTokenPreSale, startDate, endDate, JincorToken.address, Investors.address, []);

        const preSale = web3.eth.contract(BonumFinancialTokenPreSale.abi).at(BonumFinancialTokenPreSale.address);
        const ethProvider = web3.eth.contract(EthRateProvider.abi).at(EthRateProvider.address);
        const eurProvider = web3.eth.contract(EurRateProvider.abi).at(EurRateProvider.address);

        preSale.setEthUsdRateProvider(ethProvider.address, { from: web3.eth.accounts[0] });
        preSale.setEurUsdRateProvider(eurProvider.address, { from: web3.eth.accounts[0] });
        ethProvider.setWatcher(preSale.address, { from: web3.eth.accounts[0] });
        eurProvider.setWatcher(preSale.address, { from: web3.eth.accounts[0] });

        ethProvider.startUpdate(30000, { value: web3.toWei(1000), from: web3.eth.accounts[0], gas: 200000 });
        eurProvider.startUpdate(650000, { value: web3.toWei(1000), from: web3.eth.accounts[0], gas: 200000 });
    });

};
