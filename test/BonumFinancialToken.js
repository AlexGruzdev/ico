const BonumFinancialToken = artifacts.require("BonumFinancialToken");
const expect = require('chai').use(require('chai-as-promised')).expect;
require('chai').use(require('chai-as-promised')).should();


contract('BonumFinancialToken', function(accounts) {
    it("should create 75000000 BFT", async function () {
        const instance = await BonumFinancialToken.new();
        const supply = await instance.totalSupply();
        assert.equal(supply.valueOf(), 75000000 * 10 ** 18, "Supply must be 75000000");
    });

    it("should create 75000000 BFT and put them to the first account", async function () {
        const instance = await BonumFinancialToken.new();
        const balance = await instance.balanceOf(accounts[0]);
        assert.equal(balance.valueOf(), 75000000 * 10 ** 18, "Balance must be 75000000");
    });

    it("shouldn't give an opportunity to call setReleaseAgent for another persons", async function () {
        const instance = await BonumFinancialToken.new();
        instance.setReleaseAgent(accounts[1], {from: accounts[1]}).then(
            function () {
                assert.fail();
            },
            function (err) {
                err.message.should.includes("VM Exception while processing transaction: revert");
            }
        );
    });

    it("shouldn't allow to set releaseAgent by owner when token is released", async function () {
        const instance = await BonumFinancialToken.new();
        await instance.setReleaseAgent(accounts[0]);
        await instance.releaseTokens();
        instance.setReleaseAgent(accounts[1], {from: accounts[1]}).then(
            function () {
                assert.fail();
            },
            function (err) {
                err.message.should.includes("VM Exception while processing transaction: revert");
            }
        );
    });
});