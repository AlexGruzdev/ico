const BonumFinancialToken = artifacts.require("BonumFinancialToken");
const assertJump = require("zeppelin-solidity/test/helpers/assertJump.js");

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
});