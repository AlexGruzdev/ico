pragma solidity ^0.4.17;


import "zeppelin-solidity/contracts/ownership/Ownable.sol";


contract Investors is Ownable {

    struct Investor {
        bool isVerified;
        bool isInWhiteList;
        bool isInPreWhiteList;
    }

    mapping(address => Investor) public investors;


    function Investors(){

    }

    function addInvestor(address investor) external onlyOwner {
        require(investor != 0x0 && !investors[investor].isVerified);
        investors[investor].isVerified = true;
    }

    function removeInvestorFromPreWhiteList(address investor) external onlyOwner {
        require(investor != 0x0 && investors[investor].isVerified);
        investors[investor].isVerified = false;
    }

    function getIsVerified(address investor) constant external returns (address result){
        return investors[investor].isVerified;
    }


    function setIsInWhiteList(address investor, bool result) external onlyOwner {
        require(investor != 0x0 && investors[investor].isVerified);
        investors[investor].isInWhiteList = result;
    }

    function getIsInWhiteList(address investor) constant external returns (address result){
        return investors[investor].isInWhiteList;
    }

    function setIsInPreWhiteList(address investor, bool result) external onlyOwner {
        require(investor != 0x0 && investors[investor].isVerified);
        investors[investor].isInPreWhiteList = result;
    }

    function getIsInPreWhiteList(address investor) constant external returns (address result){
        return investors[investor].isInPreWhiteList;
    }
}
