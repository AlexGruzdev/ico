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
    uint whiteListPreSaleDuration = 1 days;
    BonumFinancialToken public token;
    InvestorsList public investors;
    address[] public wallets;
    mapping (address => uint) tokenHolders;
    uint ethUsdRate;
    uint ethEurRate;
    uint public collected = 0;
    uint public tokensSold = 0;

    bool public crowdsaleFinished = false;
    event NewContribution(address indexed holder, uint tokenAmount, uint etherAmount);

    function BonumFinancialTokenPreSale(
    uint _start,
    uint _duration,
    address _token,
    address _investors,
    address[] _wallets,
    uint _baseEthUsdRate,
    uint _baseEthEurRate
    ) public {
        start = _start;
        duration = _duration;

        token = BonumFinancialToken(_token);
        investors = InvestorsList(_investors);
        wallets = _wallets;

        ethUsdRate = _baseEthUsdRate;
        ethEurRate = _baseEthEurRate;
    }

    function receiveEthUsdRate(uint rate) onlyOwner {
        require(rate > 0);
        ethUsdRate = rate;
    }

    function receiveEthEurRate(uint rate) onlyOwner {
        require(rate > 0);
        ethEurRate = rate;
    }

    modifier activePreSale(){
        require(now >= start && now <= start + duration * 1 days);
        _;
    }

    modifier endedPreSale(){
        require(now > start + duration * 1 days);
        _;
    }

    modifier isAllowedToBuy(){
        require(investors.isAllowedToBuy(msg.sender));
        _;
    }

    function() payable {
        purchase();
    }

    function calculateAmountInEuro(uint value) private constant returns(uint){
        return value.mul(ethEurRate).div(10**6 * 1 ether);
    }

    function calculateBonus(address sender, uint tokensCount) private constant returns(uint){
        if(now < start + whiteListPreSaleDuration){
            if(investors.isFullVerified(sender)){
                return value.div(100).mul(35);
            }
            return value.div(100).mul(25);
        }

        //1 token == 1$
        uint baseForBonus = 0;
        if (tokensCount < 75) {
            baseForBonus = 75;
        }
        if (tokensCount > 5000) {
            baseForBonus = 5000;
        }


    }

    function purchase() private payable activePreSale isAllowedToBuy{
        if(calculateAmountInEuro(msg.value) > 10000 && !investors.isFullVerified(msg.sender)){
            revert();
        }

        uint tokens = msg.value.mul(ethUsdRate).div(10**6);
    }
}
