// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ProxyDemoUpgrade is Initializable {
    uint256 public a;
    uint256 public b;

    function initialize(uint256 _a) public initializer {
        a = _a;
    }

    function increaseA() external {
        a += 20;
    }

    function increaseB() external {
        b = a + 1;
    }
}