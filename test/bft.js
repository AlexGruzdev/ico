const BFT = artifacts.require("./BFT.sol");

contract('BFT', function (accounts) {
    it("Create 75 000 000 tokens at the owner account", async function () {
        //Arrange
        const bft = await BFT.deployed();
        //Act
        const balance = await bft.balanceOf.call(accounts[0]);
        //Assert
        assert.equal(web3.toWei(balance.valueOf(), 'ether'), web3.toWei(75000000, 'ether'), "75 000 000 wasn't in the first account");
    });
});
