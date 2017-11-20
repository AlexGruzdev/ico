pragma solidity ^0.4.17;
import "./CurrencyRateProvider.sol";

contract EurRateProvider is CurrencyRateProvider{
    function EurRateProvider() CurrencyRateProvider("json(http://api.fixer.io/latest?symbols=USD).rates.USD") {
    }

    function notifyWatcher() internal {
        watcher.receiveEurPrice(currentRate);
    }
}
