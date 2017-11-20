pragma solidity ^0.4.11;


import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Burnable.sol";


contract BonumFinancialToken is Burnable, Ownable {
    string public name = "Bonum Financial Token";

    string public symbol = "BFT";

    uint public decimals = 18;

    uint public constant INITIAL_SUPPLY = 75000000 * 1 ether;

    /*
        The finalizer contract that allows unlift the transfer limits on this token
    */
    address public releaseAgent;

    /**
        A crowdsale contract can release us to the wild if ICO success.
        If false we are are in transfer lock up period.
    */
    bool public released = false;

    /**
        Map of agents that are allowed to transfer tokens regardless of the lock down period.
        These are crowdsale contracts and possible the team multisig itself.
    */
    mapping (address => bool) public transferAgents;


    function BonumFinancialToken(){
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }


    /**
     * Limit token transfer until the crowdsale is over.
     *
     */
    modifier canTransfer(address _sender) {
        if (!released) {
            if (!transferAgents[_sender]) {
                throw;
            }
        }
        _;
    }

    /**
     * Set the contract that can call release and make the token transferable.
     *
     * Design choice. Allow reset the release agent to fix fat finger mistakes.
     */
    function setReleaseAgent(address addr) onlyOwner inReleaseState(false) public {

        // We don't do interface check here as we might want to a normal wallet address to act as a release agent
        releaseAgent = addr;
    }

    /**
     * Owner can allow a particular address (a crowdsale contract) to transfer tokens despite the lock up period.
     */
    function setTransferAgent(address addr, bool state) onlyOwner inReleaseState(false) public {
        transferAgents[addr] = state;
    }

    /**
     * One way function to release the tokens to the wild.
     *
     * Can be called only from the release agent that is the final ICO contract.
     * It is only called if the crowdsale has been success (first milestone reached).
     */
    function releaseTokens() public onlyReleaseAgent inReleaseState(false) {
        released = true;
    }

    /** The function can be called only before or after the tokens have been releasesd */
    modifier inReleaseState(bool releaseState) {
        if (releaseState != released) {
            throw;
        }
        _;
    }

    /** The function can be called only by a whitelisted release agent. */
    modifier onlyReleaseAgent() {
        if (msg.sender != releaseAgent) {
            throw;
        }
        _;
    }

    function transfer(address _to, uint _value) canTransfer(msg.sender) returns (bool success) {
        // Call Burnable.transfer()
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) canTransfer(_from) returns (bool success) {
        // Call Burnable.transferForm()
        return super.transferFrom(_from, _to, _value);
    }

    function burn(uint256 _value) onlyOwner returns (bool success) {
        return super.burn(_value);
    }

    function burnFrom(address _from, uint256 _value) onlyOwner returns (bool success) {
        return super.burnFrom(_from, _value);
    }
}
