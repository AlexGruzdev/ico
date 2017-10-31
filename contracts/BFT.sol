pragma solidity ^0.4.11;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract BFT is Ownable {
    string public name = "Bonum Financial Token";
    string public symbol = "BFT";
    uint public decimals = 18;
    uint public constant INITIAL_SUPPLY = 75000000 * 1 ether;

    function BFT(){
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}
