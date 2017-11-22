pragma solidity ^0.4.17;


import "zeppelin-solidity/contracts/ownership/Ownable.sol";


contract InvestorsList is Ownable {
    mapping (address => bytes32) public nativeInvestorsIds;
    mapping (bytes32 => Investor) public investorsList;

    function getInvestorId(address investorAddress) constant external returns (bytes32){
        require(investorAddress != 0x0);
        return nativeInvestorsIds[investorAddress];
    }

    function setInvestorId(address investorAddress, bytes32 id) external onlyOwner{
        require(investorAddress != 0x0 && id.length > 0);
        nativeInvestorsIds[investorAddress] = id;
    }

    enum  WhiteListStatus  {Usual, WhiteList, PreWhiteList}
    enum VerificationStatus {NotVerified, Usual, Full}

    struct Investor {
        bytes32 id;
        bool exists;
        uint tokensCount;
        address walletForTokens;
        WhiteListStatus whiteListStatus;
        VerificationStatus verificationStatus;
    }

    function addInvestor(
        bytes32 id,
        WhiteListStatus status,
        VerificationStatus verification
    ) external onlyOwner {
        require(id.length > 0);
        require(!investorsList[id].exists);
        investorsList[id] = Investor({
            id : id,
            exists : true,
            tokensCount: 0,
            walletForTokens: 0x0,
            whiteListStatus: status,
            verificationStatus : verification
        });
    }

    function removeInvestor(bytes32 id) external onlyOwner {
        require(id.length > 0);
        require(investorsList[id].exists);
        investorsList[id].exists = false;
    }

    function isAllowedToBuy(address investor) external onlyOwner constant returns(bool){
        require(investorAddress != 0x0);
        bytes32 id = getInvestorId(investor);
        require(id.length > 0);
        return investorsList[id].verificationStatus != VerificationStatus.NotVerified;
    }

    function isFullVerified(address investor){
        require(investorAddress != 0x0);
        bytes32 id = getInvestorId(investor);
        require(id.length > 0);
        return investorsList[id].verificationStatus == VerificationStatus.Full;
    }

    function isPreWhiteList(address investor){
        require(investorAddress != 0x0);
        bytes32 id = getInvestorId(investor);
        require(id.length > 0);
        return investorsList[id].status == WhiteListStatus.PreWhiteList;
    }

    function isWhiteList(address investor){
        require(investorAddress != 0x0);
        bytes32 id = getInvestorId(investor);
        require(id.length > 0);
        return investorsList[id].status == WhiteListStatus.WhiteList;
    }

    function setVerificationStatus(bytes32 id, VerificationStatus status) external onlyOwner{
        require(id.length > 0 && investorsList[id].exists);
        investorsList[id].verificationStatus = status;
    }

    function setWhiteListStatus(bytes32 id, WhiteListStatus status) external onlyOwner{
        require(id.length > 0 && investorsList[id].exists);
        investorsList[id].whiteListStatus = status;
    }

    function getInvestorFields(bytes32 investorId) external onlyOwner constant returns (
        bytes32 id,
        bool exists,
        uint tokensCount,
        address walletForTokens,
        uint whiteListStatus,
        uint verificationStatus
    ){
        id = investorsList[investorId].id;
        exists = investorsList[investorId].exists;
        tokensCount = investorsList[investorId].tokensCount;
        walletForTokens = investorsList[investorId].walletForTokens;
        whiteListStatus = uint(investorsList[investorId].whiteListStatus);
        verificationStatus = uint(investorsList[investorId].verificationStatus);
    }
}
