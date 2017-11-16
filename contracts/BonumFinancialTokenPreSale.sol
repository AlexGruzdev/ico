pragma solidity ^0.4.17;


import "./Haltable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./BonumFinancialToken.sol";
import "./Investors.sol";


contract BonumFinancialTokenPreSale is Haltable {
    using SafeMath for uint;

    string public constant name = "Bonum Financial Token PreSale";

    uint start;
    uint duration;
    BonumFinancialToken public token;
    Investors public investors;
    address[] public wallets;
    mapping (address => uint) tokenHolders;

    bool public crowdsaleFinished = false;
    event NewContribution(address indexed holder, uint tokenAmount, uint etherAmount);

    function BonumFinancialTokenPreSale(
    uint _start,
    uint _duration,
    address _token,
    address _investors,
    address[] _wallets
    ){
        start = _start;
        duration = _duration;

        token = BonumFinancialToken(_token);
        investors = Investors(_investors);
        wallets = _wallets;
    }



    modifier activePreSale(){
        require(now >= start && now <= start + duration * 1 days);
        _;
    }

    modifier endedPreSale(){
        require(now > start + duration * 1 days);
        _;
    }

    modifier verifiedInvestor(){
        require(investors.getIsVerified(msg.sender));
        _;
    }

    function() payable {
    }
}
