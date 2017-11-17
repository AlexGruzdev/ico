pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./oraclizeAPI.sol";
import "./PriceReceiver.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

contract CurrencyRateProvider is Ownable, usingOraclize  {
    using SafeMath for uint;

    uint public currentRate;

    string public url;

    mapping (bytes32 => bool) validIds;


    event RateUpdated(string rate);
    event FundsExhausted();


    PriceReceiver public watcher;

    enum State { Stopped, Active }
    State public state = State.Stopped;


    function notifyWatcher() internal;

    modifier inActiveState() {
        require(state == State.Active);
        _;
    }

    modifier inStoppedState() {
        require(state == State.Stopped);
        _;
    }

    function PriceProvider(string _url) {
        url = _url;
        updateRate(0);
    }

    function startListening(uint initialPrice) payable onlyOwner inStoppedState {
        state = State.Active;
        currentPrice = initialPrice;
        update(updateInterval);
    }

    function stopListening() external onlyOwner inActiveState {
        state = State.Stopped;
    }

    function setWatcher(address newWatcher) external onlyOwner {
        require(newWatcher != 0x0);
        watcher = PriceReceiver(newWatcher);
    }

    function setUpdateInterval(uint newInterval) external onlyOwner {
        require(newInterval > 0);
        updateInterval = newInterval;
    }

    function setUrl(string newUrl) external onlyOwner {
        require(bytes(newUrl).length > 0);
        url = newUrl;
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        require(msg.sender == oraclize_cbAddress() && validIds[myid]);
        delete validIds[myid];

        uint newRate = parseInt(result, 3);
        require(newRate > 0);
        currentRate = newRate;
        RateUpdated(result);

        if (state == State.Active) {
            notifyWatcher();
            updateRate(updateInterval);
        }
    }

    function updateRate(uint delay) private {
        if (oraclize_getPrice("URL") > this.balance) {
            state = State.Stopped;
            FundsExhausted();
        } else {
            bytes32 queryId = oraclize_query(delay, "URL", url);
            validIds[queryId] = true;
        }
    }

    function destroy(address receiver) external onlyOwner inStoppedState {
        require(receiver != 0x0);
        receiver.transfer(this.balance);
    }
}
