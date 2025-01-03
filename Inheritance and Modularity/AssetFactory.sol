// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;


contract Asset {
    string public symbol;
    uint256 public totalSupply;
    string public name;
    mapping(address => uint256) public balances;

    constructor(string memory _symbol, uint256 _initialSupply, string memory _name) {
        symbol = _symbol;
        totalSupply = _initialSupply;
        name = _name;
        balances[msg.sender]= _initialSupply;
    }

    function transfer(address to, uint256 amount) external payable{
        balances[msg.sender] -= amount;
        balances[to] += amount;
        (bool success, ) = payable(to).call{value:amount}("");
        require(success, "Unsuccessful transfer");
    }
}

contract AssetFactory{
    mapping(string => address) public assets;

    function createAsset(string calldata _symbol, uint256 _initialSupply, string calldata _name) external{
        Asset asset = new Asset(_symbol, _initialSupply, _name);
        assets[_symbol] = address(asset);
    }

    function retreiveAsset(string calldata symbol) external view returns (address) {
        return assets[symbol];
    }

    function transferAssets(address receiver, string calldata assetSymbol, uint256 amount) external payable{
        address asset = assets[assetSymbol];
        Asset(asset).transfer(receiver, amount);
    }
} 