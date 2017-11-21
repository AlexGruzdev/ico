pragma solidity ^0.4.17;


import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "./BonumFinancialToken.sol";
import "./Haltable.sol";
import "./InvestorsList.sol";

contract BonumFinancialTokenPreSale is Haltable{
    using SafeMath for uint;

    string public constant name = "Bonum Financial Token PreSale";

    uint start;
    uint duration;
    BonumFinancialToken public token;
    InvestorsList public investors;
    address[] public wallets;
    mapping (address => uint) tokenHolders;
    uint ethUsdRate;
    uint eurUsdRate;

    bool public crowdsaleFinished = false;
    event NewContribution(address indexed holder, uint tokenAmount, uint etherAmount);

    function BonumFinancialTokenPreSale(
    uint _start,
    uint _duration,
    address _token,
    address _investors,
    address[] _wallets,
    uint _baseEthUsdRate,
    uint _baseEurUsdRate
    ) public {
        start = _start;
        duration = _duration;

        token = BonumFinancialToken(_token);
        investors = InvestorsList(_investors);
        wallets = _wallets;

        ethUsdRate = _baseEthUsdRate;
        eurUsdRate = _baseEurUsdRate;
    }

   /* function receiveEthRate(uint rate) onlyOwner {
        require(rate > 0);
        ethUsdRate = rate;
    }

    function receiveEurRate(uint rate) onlyOwner{
        require(rate > 0);
        eurUsdRate = rate;
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

    }*/
}
