// SPDX-License-Identifier: MIT

pragma solidity >=0.6.00;

// Based on openzeppelin-solidity@2.5.0:  openzeppelin-solidity\contracts\access\roles\CapperRole.sol

import "../Roles.sol";

contract ManufacturerRole {
    using Roles for Roles.Role;

    event ManufacturerAdded(address indexed account);
    event ManufacturerRemoved(address indexed account);

    Roles.Role private _Manufacturers;

    constructor () public {
        _addManufacturer(msg.sender);
    }

    modifier onlyManufacturer() {
        require(isManufacturer(msg.sender), "ManufacturerRole: caller does not have the Manufacturer role");
        _;
    }

    function isManufacturer(address account) public view returns (bool) {
        return _Manufacturers.has(account);
    }

    function addManufacturer(address account) public onlyManufacturer {
        _addManufacturer(account);
    }

    function renounceManufacturer() public {
        _removeManufacturer(msg.sender);
    }

    function _addManufacturer(address account) internal {
        _Manufacturers.add(account);
        emit ManufacturerAdded(account);
    }

    function _removeManufacturer(address account) internal {
        _Manufacturers.remove(account);
        emit ManufacturerRemoved(account);
    }
}
