pragma solidity ^0.4.0;


contract PriceReceiver {
    address public ethUsdRateProvider;
    address public eurUsdRateProvider;


    modifier onlyEthUsdRateProvider() {
        require(msg.sender == ethUsdRateProvider);
        _;
    }

    modifier onlyEurUsdRateProvider() {
        require(msg.sender == eurUsdRateProvider);
        _;
    }

    function receiveEthPrice(uint ethUsdPrice) external;

    function receiveEurPrice(uint eurUsdPrice) external;

    function setEthPriceProvider(address provider) external;

    function setEurPriceProvider(address provider) external;
}

