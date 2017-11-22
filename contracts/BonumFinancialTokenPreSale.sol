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

    function setNewInvestorsList(address investorsList) onlyOwner {
        require(investorsList != 0x0);
        investors = InvestorsList(investorsList);
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

    modifier minimumAmount(){
        require(msg.value.mul(ethUsdRate).mul(10**6 * 1 ether) > 1);
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
            if(investors.isPreWhiteList(sender)){
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


        return 0;
    }

    function calculateBonusForExternalCurrencies(bytes32 id, uint tokensCount) private constant returns(uint){
        return 0;
    }

    function purchase() private payable activePreSale isAllowedToBuy minimumAmount{
        if(calculateAmountInEuro(msg.value) >= 10000 && !investors.isFullVerified(msg.sender)){
            revert();
        }

        uint tokens = msg.value.mul(ethUsdRate).mul(10**6 * 1 ether);
        tokens.add(calculateBonus(msg.sender, tokens));
        NewContribution(msg.sender, tokens, msg.value);

        investors.addTokens(msg.sender, tokens);
    }

                                            //usd * 10^6
    function otherCoinsPurchase(bytes32 id, uint amountInUsd, bool isMoreThan10kEur) activePreSale onlyOwner{
        require(id.length > 0 && amountInUsd >= 1);
        if(isMoreThan10kEur && !investors.isFullVerified(id)){
            revert();
        }

        uint tokens = amountInUsd.mul(1 ether).div(10**6);
        tokens.add(calculateBonus(msg.sender, tokens));
        NewContribution(msg.sender, tokens, msg.value);

        investors.addTokens(id, tokens);
    }
}
