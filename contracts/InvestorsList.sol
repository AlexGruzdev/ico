pragma solidity ^0.4.17;


import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


contract InvestorsList is Ownable {
    using SafeMath for uint;

    mapping (address => bytes32) public nativeInvestorsIds;
    mapping (bytes32 => Investor) public investorsList;

    function getInvestorId(address investorAddress) constant public returns (bytes32){
        require(investorAddress != 0x0 && nativeInvestorsIds[investorAddress].length > 0);
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
        require(id.length > 0 && investorsList[id].exists);
        investorsList[id].exists = false;
    }

    function isAllowedToBuy(address investor) external onlyOwner constant returns(bool){
        require(investor != 0x0);
        bytes32 id = getInvestorId(investor);
        require(id.length > 0 && investorsList[id].exists);
        return investorsList[id].verificationStatus != VerificationStatus.NotVerified;
    }

    function isAllowedToBuy(bytes32 id) external onlyOwner constant returns(bool){
        require(id.length > 0 && investorsList[id].exists);
        return investorsList[id].verificationStatus != VerificationStatus.NotVerified;
    }


    function isFullVerified(bytes32 id) external onlyOwner constant returns(bool){
        require(id.length > 0 && investorsList[id].exists);
        return investorsList[id].verificationStatus == VerificationStatus.Full;
    }

    function isPreWhiteList(bytes32 id) external onlyOwner constant returns(bool){
        require(id.length > 0 && investorsList[id].exists);
        return investorsList[id].whiteListStatus == WhiteListStatus.PreWhiteList;
    }

    function isWhiteList(bytes32 id) external onlyOwner constant returns(bool){
        require(id.length > 0 && investorsList[id].exists);
        return investorsList[id].whiteListStatus == WhiteListStatus.WhiteList;
    }

    function setVerificationStatus(bytes32 id, VerificationStatus status) external onlyOwner{
        require(id.length > 0 && investorsList[id].exists);
        investorsList[id].verificationStatus = status;
    }

    function setWhiteListStatus(bytes32 id, WhiteListStatus status) external onlyOwner{
        require(id.length > 0 && investorsList[id].exists);
        investorsList[id].whiteListStatus = status;
    }

    function addTokens(bytes32 id, uint tokens) external onlyOwner{
        require(id.length > 0 && investorsList[id].exists);
        investorsList[id].tokensCount.add(tokens);
    }

    function subTokens(bytes32 id, uint tokens) external onlyOwner{
        require(id.length > 0 && investorsList[id].exists);
        investorsList[id].tokensCount.sub(tokens);
    }

    function setWalletForTokens(bytes32 id, address wallet) external onlyOwner{
        require(id.length > 0 && investorsList[id].exists);
        investorsList[id].walletForTokens = wallet;
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
