pragma solidity ^0.5.0;
import './ERC20Detailed.sol';

contract MintableToken is ERC20Detailed {
    mapping (address => uint256) private mintersMap;
    struct Minter{
        address minter;
        bool isActive;
    }
    
    Minter[] private mintersArray;
    address private owner;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    constructor () public ERC20Detailed("JMintableToken", "JMT", 18){
        _mint(msg.sender, 10000 * (10 ** uint256(decimals())));
        owner = msg.sender;
    }
    
    modifier onlyOwner () {
        require(msg.sender == owner);
        _;
    }
    
    function addMinter(address minterAddress)  public onlyOwner {
        uint256 minterIndex = mintersMap[minterAddress];
        
        if(mintersArray.length == 0 || mintersArray[minterIndex].minter != minterAddress) {
            Minter memory minter = Minter(minterAddress, true);
            uint256 minterArrayIndex = mintersArray.length;
            mintersArray.push(minter);
            mintersMap[minterAddress] = minterArrayIndex;
        } else {
            mintersArray[minterIndex].isActive = true;
        }
        emit MinterAdded(minterAddress);
    }
    
    function removeMinter(address minterAddress)  public onlyOwner{
        uint256 minterIndex = mintersMap[minterAddress];
        require(mintersArray[minterIndex].minter == minterAddress);
        mintersArray[minterIndex].isActive = false;
        emit MinterRemoved(minterAddress);
    }
    
    function canMint(address minterAddress) public view returns (bool){
        return mintersArray[mintersMap[minterAddress]].minter == minterAddress && mintersArray[mintersMap[minterAddress]].isActive == true;
    }
    
    /*function remove(uint index)  returns(uint[]) {
        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        array.length--;
        return array;
    }*/
    
    modifier onlyMinter() {
        address minterAddress = msg.sender;
        require(minterAddress == owner || canMint(minterAddress) == true);
        uint256 approvedMintersCount = 0;
        for(uint256 index=0; index<mintersArray.length; index++){
            if(mintersArray[index].isActive == true){
                approvedMintersCount = approvedMintersCount.add(1);
            }
        }
        require(approvedMintersCount>=20);
        _;
    }
    /**
     * @dev See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the {MinterRole}.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }

}