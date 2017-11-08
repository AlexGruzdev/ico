pragma solidity ^0.4.18;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract Investors is Ownable {
    struct Investor {

    }

    mapping (address => Investor) public investorsList;

    function Investors(){
    }

    function addInvestor(address investor) external onlyOwner {
        require(investor != 0x0 && !investorWhiteList[investor]);
        investorsList[investor]= Investor();
    }
}
