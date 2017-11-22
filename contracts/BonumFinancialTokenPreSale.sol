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
    uint bftUsdRate = 10**6;
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

    function receiveEthUsdRate(uint rate) external onlyOwner {
        require(rate > 0);
        ethUsdRate = rate;
    }

    function receiveEthEurRate(uint rate) external onlyOwner {
        require(rate > 0);
        ethEurRate = rate;
    }

    function setNewInvestorsList(address investorsList) external onlyOwner {
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
        require(msg.value.mul(ethUsdRate).mul(bftUsdRate * 1 ether) > 1);
        _;
    }

    function() payable public activePreSale isAllowedToBuy minimumAmount{
        bytes32 id = investors.getInvestorId(msg.sender);
        if(calculateAmountInEuro(msg.value) >= 10000 && !investors.isFullVerified(id)){
            revert();
        }

        uint tokens = msg.value.mul(ethUsdRate).mul(bftUsdRate * 1 ether);
        tokens.add(calculateBonus(id, tokens));
        NewContribution(msg.sender, tokens, msg.value);

        investors.addTokens(id, tokens);
    }

    //usd * 10^6
    function otherCoinsPurchase(bytes32 id, uint amountInUsd, bool isMoreThan10kEur) external activePreSale onlyOwner{
        require(id.length > 0 && amountInUsd >= 1 && investors.isAllowedToBuy(id));
        if(isMoreThan10kEur && !investors.isFullVerified(id)){
            revert();
        }

        uint tokens = amountInUsd.mul(1 ether).div(bftUsdRate);
        tokens.add(calculateBonus(id, tokens));
        NewContribution(msg.sender, tokens, 0);

        investors.addTokens(id, tokens);
    }

    function calculateAmountInEuro(uint value) private constant returns(uint){
        return value.mul(ethEurRate).div(bftUsdRate * 1 ether);
    }

    function calculateBonus(bytes32 id, uint tokensCount) private constant returns(uint){
        if(now < start + whiteListPreSaleDuration){
            if(investors.isPreWhiteList(id)){
                return tokensCount.div(100).mul(35);
            }
            return tokensCount.div(100).mul(25);
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
}
