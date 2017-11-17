pragma solidity ^0.4.17;
import "./CurrencyRateProvider.sol";

contract EthRateProvider is CurrencyRateProvider {
    function EthRateProvider() PriceProvider("/////") {

    }

    function notifyWatcher() internal {
        watcher.receiveEthPrice(currentRate);
    }
}
