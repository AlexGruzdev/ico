pragma solidity ^0.4.11;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract Investors is Ownable {
    struct Investor {
        bool isPermitted;
    }

    mapping (address => Investor) public investorsList;

    function Investors(){
    }

    function addInvestor(address investor) external onlyOwner {
        require(investor != 0x0 && !investorWhiteList[investor].allowed);
        investorsList[investor].isPermitted = true;
    }

    function removeInvestorFromWhiteList(address investor) external onlyOwner {
        require(investor != 0x0 && investorWhiteList[investor].allowed);
        investorWhiteList[investor].allowed = false;
    }

    function isAllowed(address investor) external returns (bool result) {
        return investorsList[investor].allowed;
    }

    function isPermitted(address investor) external returns (bool result) {
        return investorWhiteList[investor].isPermitted;
    }

}
