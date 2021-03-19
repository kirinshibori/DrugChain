// SPDX-License-Identifier: MIT

pragma solidity >=0.6.00;

// Based on openzeppelin-solidity@2.5.0:  openzeppelin-solidity\contracts\access\roles\CapperRole.sol

import "../Roles.sol";

contract RetailerRole {
    using Roles for Roles.Role;

    event RetailerAdded(address indexed account);
    event RetailerRemoved(address indexed account);

    Roles.Role private _Retailers;

    constructor () public {
        _addRetailer(msg.sender);
    }

    modifier onlyRetailer() {
        require(isRetailer(msg.sender), "RetailerRole: caller does not have the Retailer role");
        _;
    }

    function isRetailer(address account) public view returns (bool) {
        return _Retailers.has(account);
    }

    function addRetailer(address account) public onlyRetailer {
        _addRetailer(account);
    }

    function renounceRetailer() public {
        _removeRetailer(msg.sender);
    }

    function _addRetailer(address account) internal {
        _Retailers.add(account);
        emit RetailerAdded(account);
    }

    function _removeRetailer(address account) internal {
        _Retailers.remove(account);
        emit RetailerRemoved(account);
    }
}
