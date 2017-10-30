pragma solidity ^0.4.11;
import "zeppelin-solidity/contracts/token/MintableToken.sol";

contract BFT is MintableToken {
    string public name = "Bonum Financial Token";
    string public symbol = "BFT";
    uint public decimals = 18;

    function BFT(uint256 _amount){
        owner = msg.sender;
        mint(owner, _amount);
    }
}
