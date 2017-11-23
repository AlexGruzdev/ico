const InvestorsList = artifacts.require("InvestorsList");
require('chai').use(require('chai-as-promised')).should();


contract("InvestorsList", accounts => {
    let investorsList;
    beforeEach(async function () {
        investorsList = await InvestorsList.new();
    });

    describe("addInvestor", () => {
        it("Owner can add investor, make him whitelisted and verified completely", async () => {
            await investorsList.addInvestor("testId", 1, 2);
            const result = await investorsList.getInvestorFields("testId");

            assertInvestorData(result);
            assert.equal("1", result[4].toString());
            assert.equal("2", result[5].toString());
        });

        it("Only owner can add investor", () => {
            investorsList.addInvestor("testId", 1, 2, {from: accounts[2]}).should.be.rejectedWith('revert');
        });

        it("Owner can add investor, make him usual", async () => {
            await investorsList.addInvestor("testId", 0, 1);
            const result = await investorsList.getInvestorFields("testId");
            assertInvestorData(result);
            assert.equal("0", result[4].toString());
            assert.equal("1", result[5].toString());
        });


        it("Owner can add investor, make him prewhitelisted usual and verified completely", async () => {
            await investorsList.addInvestor("testId", 2, 2);
            const result = await investorsList.getInvestorFields("testId");
            assertInvestorData(result);
            assert.equal("2", result[4].toString());
            assert.equal("2", result[5].toString());
        });

        it("Only owner can't add existing investor", async () => {
            await investorsList.addInvestor("testId", 1, 2);
            investorsList.addInvestor("testId", 1, 2).should.be.rejectedWith('revert');
        });

        it("Only owner can't add investor with empty id", () => {
            investorsList.addInvestor(0, 1, 2).should.be.rejectedWith('revert');
        });

        function assertInvestorData(investorData){
            assert.equal("testId", web3.toUtf8(investorData[0]));
            assert.equal(true, investorData[1]);
            assert.equal("0", investorData[2].toString());
            assert.equal(0, investorData[3].toString());
        }
    });

    describe("get/set InvestorId", () =>{
        it("Owner can set investor id ", async ()=>{
            await investorsList.setInvestorId(accounts[5], "my test id");
            const result = await investorsList.getInvestorId(accounts[5]);
            assert.equal("my test id", web3.toUtf8(result));
        });

        it("Only owner can set investor id ", async ()=>{
            investorsList.setInvestorId(accounts[5], "my test id", {from: accounts[2]}).should.be.rejectedWith('revert');
        });

        it("Owner cannot set empty address", () => {
            investorsList.setInvestorId(0, "my test id").should.be.rejectedWith('revert');
        });

        it("Owner cannot set empty id", () => {
            investorsList.setInvestorId(accounts[5], 0).should.be.rejectedWith('revert');
        });

        it("Can't get doesn't exist address", () => {
            investorsList.setInvestorId(accounts[5]).should.be.rejectedWith('revert');
        });

        it("Can't get empty address", () => {
            investorsList.getInvestorId(0).should.be.rejectedWith('revert');
        });
    });

    describe("removeInvestor", () =>{
        beforeEach(async function () {
            await investorsList.addInvestor("testId", 2, 2);
        });

        it("Owner can remove investor", async () => {
            await investorsList.removeInvestor("testId");
            const result = await investorsList.getInvestorFields("testId");
            assert.equal(false, result[1]);
        });

        it("Only owner can remove investor", async () => {
            investorsList.removeInvestor("testId", {from: accounts[2]}).should.be.rejectedWith('revert');
        });
    });

    describe("isAllowedToBuy", () =>{
        it("NotVerified isn't allowed to buy tokens. Address", async () => {
            await investorsList.setInvestorId(accounts[5], "testId");
            await investorsList.addInvestor("testId", 0, 0);
            const result = await investorsList.isAllowedToBuyByAddress(accounts[5]);
            assert.equal(false, result);
        });

        it("NotVerified isn't allowed to buy tokens. Id", async () => {
            await investorsList.addInvestor("testId", 0, 0);
            const result = await investorsList.isAllowedToBuy("testId");
            assert.equal(false, result);
        });
    });
});