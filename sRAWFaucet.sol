// SPDX-License-Identifier: NONE

pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract sRAWFaucet is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    address srawfaucet;
    
    sFUELFaucet sFuelFaucet;

    constructor() payable {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        srawfaucet = address(this);
    }
    
    bytes32 internal constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    function _payer() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _sender() internal view returns (address) {
        return msg.sender;
    }

    function sFUELAdd(address sfuelfaucet) external payable onlyRole(ADMIN_ROLE) {
        sFuelFaucet = sFUELFaucet(sfuelfaucet);
    }
    
    function sRawFaucet(address payable receiver) external payable onlyRole(ADMIN_ROLE) {
        sFuelFaucet.pay(receiver);
    }

    function setAdmin(address newAdmin) external payable onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(ADMIN_ROLE, newAdmin);
    }

    function deAdmin(address oldAdmin) external payable onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(ADMIN_ROLE, oldAdmin);
    }

    function setOwner(address newOwner) external payable onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        revokeRole(DEFAULT_ADMIN_ROLE, _payer());
    }

    function stuckTokens(address token) external payable onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20 ERC20token = IERC20(token);
        uint256 stuckBalance = ERC20token.balanceOf(srawfaucet);
        ERC20token.safeTransfer(_payer(), stuckBalance);
    }
}

interface sFUELFaucet{
  function pay(address payable receiver) external;
}