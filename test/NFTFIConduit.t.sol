// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {IDAINFTFI} from "../src/interfaces/IDAINFTFI.sol";
import {DAINFTFI} from "../src/DAINFTFI.sol";
import {NFTFIConduit} from "../src/NFTFIConduit.sol";
import {DaiMock, ERC721Mock, RegistryMock} from "./mock/Mocks.sol";
import { UpgradeableProxy } from 'upgradeable-proxy/UpgradeableProxy.sol';
import "forge-std/console.sol";

contract NFTFIConduitTest is Test {
    DAINFTFI public protocol;
    DaiMock DAIMock;
    ERC721Mock erc721Mock;
    NFTFIConduit conduit;
    RegistryMock registry;

    address borrower;

    bytes32 constant ILK  = 'some-ilk';
    address buffer = makeAddr("buffer");

    function setUp() public {
        DAIMock = new DaiMock("MockDai", "DAI");
        erc721Mock = new ERC721Mock("MockERC721", "ERC721");
        protocol = new DAINFTFI(address(DAIMock));
        borrower = address(1);
        erc721Mock.mint(borrower, 1);

        registry = new RegistryMock();

        registry.setBuffer(buffer);  // TODO: Update this, make buffer per ilk

        UpgradeableProxy proxy = new UpgradeableProxy();
        NFTFIConduit impl  = new NFTFIConduit(address(protocol));

        proxy.setImplementation(address(impl));

        conduit = NFTFIConduit(address(proxy));

        conduit.setRegistry(address(registry));

        DAIMock.mint(buffer, 1000);
        vm.prank(buffer);
        console.log(buffer);
        DAIMock.approve(address(conduit), type(uint256).max);
    }

    function test_giveLoan() public {
        vm.prank(borrower);
        erc721Mock.approve(address(protocol), 1);
        vm.prank(borrower);
        protocol.listLoan(address(erc721Mock), 1, 100, 10);

        vm.prank(address(conduit));
        DAIMock.approve(address(protocol), 100);
        conduit.giveLoan(ILK, address(DAIMock), 0);
        IDAINFTFI.Loan memory updatedLoan = protocol.getLoans()[0];
        assertEq(updatedLoan.lender, address(conduit), "Lender address should be updated to the lender");
    }
}
