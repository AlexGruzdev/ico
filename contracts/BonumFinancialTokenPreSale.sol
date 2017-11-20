pragma solidity ^0.4.17;


import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "./BonumFinancialToken.sol";
import "./Burnable.sol";
import "./Investors.sol";
import "./rates/PriceReceiver.sol";

contract BonumFinancialTokenPreSale is Haltable, PriceReceiver {
    using SafeMath for uint;

    string public constant name = "Bonum Financial Token PreSale";

    uint start;
    uint duration;
    BonumFinancialToken public token;
    Investors public investors;
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
    address[] _wallets
    ){
        start = _start;
        duration = _duration;

        token = BonumFinancialToken(_token);
        investors = Investors(_investors);
        wallets = _wallets;
    }

    function receiveEthPrice(uint ethUsdPrice) external onlyEthUsdRateProvider {
        require(ethUsdPrice > 0);
        ethUsdRate = ethUsdPrice;
    }

    function receiveEurPrice(uint eurUsdPrice) external onlyEurUsdRateProvider{
        require(eurUsdPrice > 0);
        eurUsdRate = ethUsdPrice.div(10**6);
    }

    function setEthUsdRateProvider(address provider) external onlyOwner {
        require(provider != 0x0);
        ethUsdRateProvider = provider;
    }

    function setEurUsdRateProvider(address provider) external onlyOwner {
        require(provider != 0x0);
        eurUsdRateProvider = provider;
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
