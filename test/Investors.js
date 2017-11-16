const Investors = artifacts.require("Investors");
require('chai').use(require('chai-as-promised')).should();


contract("Investors", accounts => {
    let investorsList;
    beforeEach(async function () {
        investorsList = await Investors.new();
    });

    describe("addInvestor", () => {
        it("Owner can add investor", async () => {
            await investorsList.addInvestor(accounts[1]);
            const result = await investorsList.getIsVerified(accounts[1]);
            assert.equal(true, result);
        });

        it("Only owner can add investor", async () => {
            await investorsList.addInvestor(accounts[1], {from: accounts[1]}).should.be.rejectedWith('revert');
        });

        it("Investor can't be added twice", async() =>{
            await investorsList.addInvestor(accounts[1]);
            await investorsList.addInvestor(accounts[1]).should.be.rejectedWith('revert');
        });

        it("getIsVerified works properly", async() =>{
            await investorsList.addInvestor(accounts[1]);
            await investorsList.removeInvestor(accounts[1]);
            await investorsList.addInvestor(accounts[1]);
            const result = await investorsList.getIsVerified(accounts[1]);
            assert.equal(true, result);
        });

        it("getIsVerified works properly with calls from another account", async() =>{
            await investorsList.addInvestor(accounts[1]);
            await investorsList.removeInvestor(accounts[1]);
            await investorsList.addInvestor(accounts[1]);
            const result = await investorsList.getIsVerified(accounts[1], {from: accounts[1]});
            assert.equal(true, result);
        });
    });

    describe("removeInvestor", () => {
        it("Owner can removeInvestor investor", async () => {
            await investorsList.addInvestor(accounts[1]);
            await investorsList.removeInvestor(accounts[1]);
            const result = await investorsList.getIsVerified(accounts[1]);
            assert.equal(false, result);
        });

        it("Only owner can add investor", async () => {
            await investorsList.addInvestor(accounts[2]);
            await investorsList.removeInvestor(accounts[2], {from: accounts[1]}).should.be.rejectedWith('revert');
        });

        it("Investor can't be added twice", async() =>{
            await investorsList.addInvestor(accounts[1]);
            await investorsList.removeInvestor(accounts[1]);
            await investorsList.removeInvestor(accounts[1]).should.be.rejectedWith('revert');
        });
    });

    describe("white list", () => {
        let investorsList;
        beforeEach(async function () {
            investorsList = await Investors.new();
            await investorsList.addInvestor(accounts[1]);
        });


        it("Owner can setIsInWhiteList", async () => {
            await investorsList.setIsInWhiteList(accounts[1], true);
            const result = await investorsList.getIsInWhiteList(accounts[1]);
            assert.equal(true, result);
        });

        it("Owner can remove from setIsInWhiteList", async () => {
            await investorsList.setIsInWhiteList(accounts[1], false);
            const result = await investorsList.getIsInWhiteList(accounts[1]);
            assert.equal(false, result);
        });

        it("Only owner can setIsInWhiteList", async () => {
            await investorsList.setIsInWhiteList(accounts[1], true, {from: accounts[1]}).should.be.rejectedWith('revert');
        });

        it("Setting for not verified user should fail", async () => {
            await investorsList.removeInvestor(accounts[1]);
            await investorsList.setIsInWhiteList(accounts[1], true).should.be.rejectedWith('revert');
        });
    });

    describe("pre white list", () => {
        let investorsList;
        beforeEach(async function () {
            investorsList = await Investors.new();
            await investorsList.addInvestor(accounts[1]);
        });


        it("Owner can setIsInPreWhiteList", async () => {
            await investorsList.setIsInPreWhiteList(accounts[1], true);
            const result = await investorsList.getIsInPreWhiteList(accounts[1]);
            assert.equal(true, result);
        });

        it("Owner can remove from setIsInPreWhiteList", async () => {
            await investorsList.setIsInPreWhiteList(accounts[1], false);
            const result = await investorsList.getIsInPreWhiteList(accounts[1]);
            assert.equal(false, result);
        });

        it("Only owner can setIsInPreWhiteList", async () => {
            await investorsList.setIsInPreWhiteList(accounts[1], true, {from: accounts[1]}).should.be.rejectedWith('revert');
        });

        it("Setting for not verified user should fail", async () => {
            await investorsList.removeInvestor(accounts[1]);
            await investorsList.setIsInPreWhiteList(accounts[1], true).should.be.rejectedWith('revert');
        });
    });
});