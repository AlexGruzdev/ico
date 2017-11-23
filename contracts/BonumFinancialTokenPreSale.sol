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
    //23x13
    uint[][] bonusTable;
    //row numbers
    mapping (uint => uint) bonusRows;


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
    //uint[][] _bonusTable
    ) public {
        start = _start;
        duration = _duration;

        token = BonumFinancialToken(_token);
        investors = InvestorsList(_investors);
        wallets = _wallets;

        ethUsdRate = _baseEthUsdRate;
        ethEurRate = _baseEthEurRate;
        //bonusTable = _bonusTable;
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

    function() payable public activePreSale isAllowedToBuy minimumAmount {
        bytes32 id = investors.getInvestorId(msg.sender);
        if (calculateAmountInEuro(msg.value) >= 10000 && !investors.isFullVerified(id)) {
            revert();
        }

        uint tokens = msg.value.mul(ethUsdRate).mul(bftUsdRate * 1 ether);
        tokens.add(calculateBonus(id, tokens));
        NewContribution(msg.sender, tokens, msg.value);

        investors.addTokens(id, tokens);
        collected.add(msg.value);
        tokensSold.add(tokens);
    }

    //usd * 10^6
    function otherCoinsPurchase(bytes32 id, uint amountInUsd, bool isMoreThan10kEur) external activePreSale onlyOwner {
        require(id.length > 0 && amountInUsd >= 1 && investors.isAllowedToBuy(id));
        if (isMoreThan10kEur && !investors.isFullVerified(id)) {
            revert();
        }

        uint tokens = amountInUsd.mul(1 ether).div(bftUsdRate);
        tokens.add(calculateBonus(id, tokens));
        NewContribution(msg.sender, tokens, 0);

        investors.addTokens(id, tokens);
        tokensSold.add(tokens);
    }

    function calculateAmountInEuro(uint value) private constant returns (uint){
        return value.mul(ethEurRate).div(bftUsdRate * 1 ether);
    }

    function calculateBonus(bytes32 id, uint tokensCount) private constant returns (uint){
        if (now < start + whiteListPreSaleDuration) {
            if (investors.isPreWhiteList(id)) {
                return tokensCount.div(100).mul(35);
            }
            return tokensCount.div(100).mul(25);
        }

        uint column = ((now - start)/86400) - 1;
        if(table < 0 ){
            revert();
        }

        //1 token == 1$
        if (tokensCount < 100) {
            return bonusTable[0][column];
        }
        if (tokensCount > 50000) {
            return bonusTable[22][column];
        }

        int bottomLine = (tokensCount / 100) * 100;
        if(bottomLine == tokensCount){
            return bonusTable[bonusRows[bottomLine]][column];
        }

        int topLine = bonusTable[bonusRows[bottomLine] + 1][0];

        uint b1 = bonusTable[bonusRows[bottomLine]][column];
        uint b2 = bonusTable[bonusRows[topLine]][column];
        int bonus = ((tokens - bottomLine) * (topLine - bottomLine)) / ((bottomLine  - topLine) + b1);
        bonus = bonus / bftUsdRate;


        return bonus;
    }
}
