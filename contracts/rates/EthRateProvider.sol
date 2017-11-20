pragma solidity ^0.4.17;
import "./CurrencyRateProvider.sol";

contract EthRateProvider is CurrencyRateProvider {
    function EthRateProvider() CurrencyRateProvider("json(https://api.bitfinex.com/v1/pubticker/ethusd).mid") {

    }

    function notifyWatcher() internal {
        watcher.receiveEthPrice(currentRate);
    }
}
