const InvestorsList = artifacts.require("InvestorsList");
require('chai').use(require('chai-as-promised')).should();


contract("Investors", accounts => {
    let investorsList;
    beforeEach(async function () {
        investorsList = await InvestorsList.new();
    });

    describe("addInvestor", () => {

        function assertInvestorData(investorData){
            assert.equal("testId", web3.toUtf8(investorData[0]));
            assert.equal(true, investorData[1]);
            assert.equal("0", investorData[2].toString());
            assert.equal(0, investorData[3].toString());
        }

        it("Owner can add investor, make him whitelisted and verified completely", async () => {
            await investorsList.addInvestor("testId", 1, 1);
            const result = await investorsList.getInvestorFields("testId");

            assertInvestorData(result);
            assert.equal("1", result[4].toString());
            assert.equal("1", result[5].toString());
        });

        it("Owner can add investor, make him usual", async () => {
            await investorsList.addInvestor("testId", 0, 0);
            const result = await investorsList.getInvestorFields("testId");
            assertInvestorData(result);
            assert.equal("0", result[4].toString());
            assert.equal("0", result[5].toString());
        });


        it("Owner can add investor, make him prewhitelisted usual and verified completely", async () => {
            await investorsList.addInvestor("testId", 2, 1);
            const result = await investorsList.getInvestorFields("testId");
            assertInvestorData(result);
            assert.equal("2", result[4].toString());
            assert.equal("1", result[5].toString());
        });
    });
});