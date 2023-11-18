// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.19;

import { IERC20, ERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/ERC20.sol';
import { SafeERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';

import { UpgradeableProxied } from 'upgradeable-proxy/UpgradeableProxied.sol';

import { INFTFiConduit } from './interfaces/INFTFIConduit.sol';
import { IDAINFTFI } from './interfaces/IDAINFTFI.sol';
import "forge-std/console.sol";

interface RolesLike {
    function canCall(bytes32, address, address, bytes4) external view returns (bool);
}

interface RegistryLike {
    function buffers(bytes32 ilk) external view returns (address buffer);
}

contract NFTFIConduit is UpgradeableProxied, INFTFiConduit {
    using SafeERC20 for address;

    IDAINFTFI public immutable protocol;

    address public roles;
    address public registry;

    modifier auth() {
        require(wards[msg.sender] == 1, "NFTFIConduit/not-authorized");
        _;
    }

    modifier ilkAuth(bytes32 ilk) {
        require(
            RolesLike(roles).canCall(ilk, msg.sender, address(this), msg.sig),
            "NFTFIConduit/ilk-not-authorized"
        );
        _;
    }

    constructor(address _protocol) {
        protocol = IDAINFTFI(_protocol);
    }

    function setRegistry(address _registry) external override auth {
        registry = _registry;
    }

    function deposit(bytes32 ilk, address asset, uint256 amount) external override ilkAuth(ilk) {
        
    }

    function withdraw(bytes32 ilk, address asset, uint256 maxAmount)
        external override ilkAuth(ilk) returns (uint256 amount)
    {
    }

    function giveLoan(bytes32 ilk, address asset, uint256 loanId) external override {
        address source = RegistryLike(registry).buffers(ilk);
        require(source != address(0), "NFTFIConduit/no-buffer-registered");

        // conduit gives the loan to the protocol
        IDAINFTFI.Loan memory loan = protocol.getLoans()[loanId];

        // transfer DAI to conduit first
        console.log(source);
        IERC20(asset).transferFrom(source, address(this), loan.loanAmount);
        console.log("successful transfer from source");

        // conduit gives the loan to the protocol
        protocol.giveLoan(loanId);
        console.log("successful transfer from conduit");
    }

    function maxDeposit(bytes32, address asset) public view override returns (uint256 maxDeposit_) {
    }

    function maxWithdraw(bytes32 ilk, address asset)
        public view override returns (uint256 maxWithdraw_)
    {
    }
}