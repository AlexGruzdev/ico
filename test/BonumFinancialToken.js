const BonumFinancialToken = artifacts.require("BonumFinancialToken");
const expect = require('chai').use(require('chai-as-promised')).expect;
require('chai').use(require('chai-as-promised')).should();


contract('BonumFinancialToken', function (accounts) {

    describe('initialisation test', function () {
        it("should create 75000000 BFT", async () => {
            const instance = await BonumFinancialToken.new();

            const supply = await instance.totalSupply();

            assert.equal(supply.valueOf(), 75000000 * 10 ** 18, "Supply must be 75000000");
        });

        it("should create 75000000 BFT and put them to the first account", async () => {
            const instance = await BonumFinancialToken.new();
            const balance = await instance.balanceOf(accounts[0]);
            assert.equal(balance.valueOf(), 75000000 * 10 ** 18, "Balance must be 75000000");
        });
    });

    describe('setReleaseAgent', function () {
        it("shouldn't give an opportunity to call setReleaseAgent for another persons", async () => {
            const instance = await BonumFinancialToken.new();
            instance.setReleaseAgent(accounts[1], {from: accounts[1]}).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });


        it("shouldn't allow to set releaseAgent by owner when token is in the release state", async () => {
            const instance = await BonumFinancialToken.new();
            await instance.setReleaseAgent(accounts[0]);
            await instance.releaseTokens();
            instance.setReleaseAgent(accounts[1], {from: accounts[1]}).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });

        it("should allow to set releaseAgent by owner", async () => {
            const instance = await BonumFinancialToken.new();
            await instance.setReleaseAgent(accounts[1]);
            const releaseAgent = await instance.releaseAgent();
            assert.equal(releaseAgent, accounts[1])
        });
    });

    describe('setTransferAgent', function () {
        it("should allow to set transferAgents by owner", async () => {
            const instance = await BonumFinancialToken.new();
            await instance.setTransferAgent(accounts[1], true);
            const value = await instance.transferAgents(accounts[1]);
            assert.equal(value, true)
        });

        it("shouldn't allow to set transferAgents by not an owner", async () => {
            const instance = await BonumFinancialToken.new();
            instance.setTransferAgent(accounts[1], true, {from: accounts[1]}).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });

        it("shouldn't allow to set transferAgents in releaseState by owner", async () => {
            const instance = await BonumFinancialToken.new();
            await instance.setReleaseAgent(accounts[0]);
            instance.releaseTokens();

            instance.setTransferAgent(accounts[1], true).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });
    });

    describe('release', function () {
        it("shouldn't allow to release by not release agent", async () => {
            const instance = await BonumFinancialToken.new();
            await instance.setReleaseAgent(accounts[0]);
            instance.releaseTokens({from: accounts[1]}).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });

        it("should allow to release by release agent", async () => {
            const instance = await BonumFinancialToken.new();
            await instance.setReleaseAgent(accounts[1]);
            await instance.releaseTokens({from: accounts[1]});
            const result = await instance.released();
            assert.equal(result, true);
        });

        it("should't release if released", async () => {
            const instance = await BonumFinancialToken.new();
            await instance.setReleaseAgent(accounts[1]);
            await instance.releaseTokens({from: accounts[1]});
            instance.releaseTokens({from: accounts[1]}).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });
    });

    describe('transfer', async () => {

        it("should't transfer, when not in transfer list and not released", async () => {
            const instance = await BonumFinancialToken.new();
            instance.transfer(accounts[1], 100).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });

        it("allow transfer, when released", async () => {
            //arrange
            let instance = await BonumFinancialToken.new();
            await instance.setReleaseAgent(accounts[0]);
            await instance.releaseTokens();

            //act
            await instance.transfer(accounts[1], 200 * 10 ** 18);

            //assert
            const balance0 = await instance.balanceOf(accounts[0]);
            const balance1 = await instance.balanceOf(accounts[1]);
            assert.equal(balance0.valueOf(), 74999800 * 10 ** 18);
            assert.equal(balance1.valueOf(), 200 * 10 ** 18);
        });

        it("allow transfer, when released. not round numbers", async () => {
            //arrange
            let instance = await BonumFinancialToken.new();
            await instance.setReleaseAgent(accounts[0]);
            await instance.releaseTokens();

            //act
            await instance.transfer(accounts[1], 0.0009 * 10 ** 18);

            //assert
            const balance0 = await instance.balanceOf(accounts[0]);
            const balance1 = await instance.balanceOf(accounts[1]);
            assert.equal(balance0.valueOf(), 74999999.9991 * 10 ** 18);
            assert.equal(balance1.valueOf(), 0.0009 * 10 ** 18);
        });

        it("allow transfer for transfer agent", async () => {
            //arrange
            let instance = await BonumFinancialToken.new();
            await instance.setTransferAgent(accounts[0], true);

            //act
            await instance.transfer(accounts[1], 200 * 10 ** 18);

            //assert
            const balance0 = await instance.balanceOf(accounts[0]);
            const balance1 = await instance.balanceOf(accounts[1]);
            assert.equal(balance0.valueOf(), 74999800 * 10 ** 18);
            assert.equal(balance1.valueOf(), 200 * 10 ** 18);
        });

        it("should not allow transfer to 0x0", async function() {
            let instance = await BonumFinancialToken.new();
            await instance.setTransferAgent(accounts[0], true);
            instance.transfer(0x0, 100 * 10 ** 18).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });

        it("should not allow transfer from to 0x0", async function() {
            let instance = await BonumFinancialToken.new();
            await instance.setTransferAgent(accounts[0], true);
            await instance.approve(accounts[1], 100 * 10 ** 18);
            instance.transferFrom(accounts[0], 0x0, 100 * 10 ** 18, {from: accounts[1]}).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });

        it("should not allow transferFrom when token is not released and 'from' is not added to transferAgents map", async function() {
            let instance = await BonumFinancialToken.new();
            await instance.approve(accounts[1], 100 * 10 ** 18);
            instance.transferFrom(accounts[0], accounts[2], 100 * 10 ** 18, {from: accounts[1]}).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });

        it("should allow transferFrom when token is released", async function() {
            let instance = await BonumFinancialToken.new();
            await instance.setReleaseAgent(accounts[0]);
            await instance.releaseTokens();

            await instance.approve(accounts[1], 100 * 10 ** 18);
            await instance.transferFrom(accounts[0], accounts[2], 100 * 10 ** 18, {from: accounts[1]});

            const balance0 = await instance.balanceOf(accounts[0]);
            assert.equal(balance0.valueOf(), 74999900 * 10 ** 18);

            const balance1 = await instance.balanceOf(accounts[2]);
            assert.equal(balance1.valueOf(), 100 * 10 ** 18);

            const balance2 = await instance.balanceOf(accounts[1]);
            assert.equal(balance2.valueOf(), 0);
        });

        it("shouldn't allow transferFrom when token is released and isn't approved", async function() {
            let instance = await BonumFinancialToken.new();
            await instance.setReleaseAgent(accounts[0]);
            await instance.releaseTokens();
            instance.transferFrom(accounts[0], accounts[2], 100 * 10 ** 18, {from: accounts[1]}).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: invalid opcode")
            );


        });

        it("should allow transferFrom for transferAgent when token is not released", async function() {
            let instance = await BonumFinancialToken.new();
            await instance.setTransferAgent(accounts[0], true);

            await instance.approve(accounts[1], 100 * 10 ** 18);
            await instance.transferFrom(accounts[0], accounts[2], 100 * 10 ** 18, {from: accounts[1]});

            const balance0 = await instance.balanceOf(accounts[0]);
            assert.equal(balance0.valueOf(), 74999900 * 10 ** 18);

            const balance1 = await instance.balanceOf(accounts[2]);
            assert.equal(balance1.valueOf(), 100 * 10 ** 18);

            const balance2 = await instance.balanceOf(accounts[1]);
            assert.equal(balance2.valueOf(), 0);
        });
    });

    describe('burn', async () => {
        it("should allow to burn by owner", async function() {
            let instance = await BonumFinancialToken.new();
            await instance.burn(1000000 * 10 ** 18);

            const balance = await instance.balanceOf(accounts[0]).valueOf();
            assert.equal(balance, 74000000 * 10 ** 18);

            const supply = await instance.totalSupply().valueOf();
            assert.equal(supply, 74000000 * 10 ** 18);
        });

        it("should not allow to burn by not owner", async function () {
            let instance = await BonumFinancialToken.new();
            await instance.setTransferAgent(accounts[0], true);
            await instance.transfer(accounts[1], 1000000 * 10 ** 18);

            instance.burn(1000000 * 10 ** 18, {from: accounts[1]}).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });

        it("should not allow to burn more than balance", async function() {
            let instance = await BonumFinancialToken.new();
            instance.burn(75000001 * 10 ** 18).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });

        it("should allow to burn from by owner", async function() {
            let instance = await BonumFinancialToken.new();
            await instance.setTransferAgent(accounts[0], true);
            await instance.transfer(accounts[1], 1000000 * 10 ** 18);
            await instance.approve(accounts[0], 500000 * 10 ** 18, {from: accounts[1]});
            await instance.burnFrom(accounts[1], 500000 * 10 ** 18);

            const balance = await instance.balanceOf(accounts[1]).valueOf();
            assert.equal(balance, 500000 * 10 ** 18);

            const supply = await instance.totalSupply().valueOf();
            assert.equal(supply, 74500000 * 10 ** 18);

            //should not allow to burn more
            instance.burnFrom(accounts[1], 1).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });

        it("should not allow to burn from by not owner", async function() {
            let instance = await BonumFinancialToken.new();
            await instance.setTransferAgent(accounts[0], true);
            await instance.transfer(accounts[1], 1000000 * 10 ** 18);
            await instance.approve(accounts[2], 500000 * 10 ** 18, {from: accounts[1]});

            instance.burnFrom(accounts[1], 500000 * 10 ** 18, {from: accounts[2]}).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });

        it("should not allow to burn from more than balance", async function() {
            let instance = await BonumFinancialToken.new();
            await instance.setTransferAgent(accounts[0], true);
            await instance.transfer(accounts[1], 500000 * 10 ** 18);
            await instance.approve(accounts[0], 1000000 * 10 ** 18, {from: accounts[1]});

            instance.burnFrom(accounts[1], 500001 * 10 ** 18).then(
                () => assert.fail(),
                (err) => err.message.should.includes("VM Exception while processing transaction: revert")
            );
        });
    });
});