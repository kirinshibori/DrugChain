// SPDX-License-Identifier: MIT

pragma solidity >=0.6.00;

// Based on openzeppelin-solidity@2.5.0:  openzeppelin-solidity\contracts\access\roles\CapperRole.sol

import "../Roles.sol";

contract SupplierRole {
    using Roles for Roles.Role;

    event SupplierAdded(address indexed account);
    event SupplierRemoved(address indexed account);

    Roles.Role private _Suppliers;

    constructor () public {
        _addSupplier(msg.sender);
    }

    modifier onlySupplier() {
        require(isSupplier(msg.sender), "SupplierRole: caller does not have the Supplier role");
        _;
    }

    function isSupplier(address account) public view returns (bool) {
        return _Suppliers.has(account);
    }

    function addSupplier(address account) public onlySupplier {
        _addSupplier(account);
    }

    function renounceSupplier() public {
        _removeSupplier(msg.sender);
    }

    function _addSupplier(address account) internal {
        _Suppliers.add(account);
        emit SupplierAdded(account);
    }

    function _removeSupplier(address account) internal {
        _Suppliers.remove(account);
        emit SupplierRemoved(account);
    }
}
