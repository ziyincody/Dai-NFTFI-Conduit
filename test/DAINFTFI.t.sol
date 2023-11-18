// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {IDAINFTFI} from "../src/interfaces/IDAINFTFI.sol";
import {DAINFTFI} from "../src/DAINFTFI.sol";
import {DaiMock, ERC721Mock} from "./mock/Mocks.sol";
import "forge-std/console.sol";

contract DAINFTFITest is Test {
    DAINFTFI public protocol;
    DaiMock DAIMock;
    ERC721Mock erc721Mock;
    address borrower;
    address lender;

    function setUp() public {
        DAIMock = new DaiMock("MockDai", "DAI");
        erc721Mock = new ERC721Mock("MockERC721", "ERC721");
        protocol = new DAINFTFI(address(DAIMock));
        borrower = address(1);
        lender = address(2);
        DAIMock.mint(lender, 1000);
        erc721Mock.mint(borrower, 1);
    }

    // function test_depositAndBorrowDAI() public {
    //     vm.prank(depositor);
    //     DAIMock.approve(address(protocol), 100);

    //     vm.prank(depositor);
    //     protocol.depositDAI(100);

    //     assertEq(DAIMock.balanceOf(depositor), 900, "Owner balance should decrease by 100");
    // }

    function test_listAndGiveAndPaybackLoan() public {

        console.log(erc721Mock.balanceOf(borrower));

        vm.prank(borrower);
        erc721Mock.approve(address(protocol), 1);
        vm.prank(borrower);
        protocol.listLoan(address(erc721Mock), 1, 100, 10);
        IDAINFTFI.Loan memory loan = protocol.getLoans()[0];
        assertEq(loan.nftCollection, address(erc721Mock), "NFT collection should be ERC721Mock");
        assertEq(loan.tokenId, 1, "Token ID should be 1");
        assertEq(loan.loanAmount, 100, "Loan amount should be 100");
        assertEq(loan.interest, 10, "Interest should be 10");
        assertEq(loan.borrower, address(borrower), "Borrower should be borrower");
        assertEq(loan.lender, address(0), "Lender should be 0");

        console.log("HERE");

        
        vm.prank(lender);
        DAIMock.approve(address(protocol), 100);
        vm.prank(lender);
        protocol.giveLoan(0);
        IDAINFTFI.Loan memory updatedLoan = protocol.getLoans()[0];
        assertEq(updatedLoan.lender, address(lender), "Lender address should be updated to the lender");
    }
}
