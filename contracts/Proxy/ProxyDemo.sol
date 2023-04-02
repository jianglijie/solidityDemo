// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ProxyDemo is Initializable {
    uint256 public a;

    function initialize(uint256 _a) public initializer {
        a = _a;
    }

    function increaseA() external {
        ++a;
    }
}