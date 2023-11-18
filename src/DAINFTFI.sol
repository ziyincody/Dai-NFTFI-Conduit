// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.19;

import {IDAINFTFI} from "./interfaces/IDAINFTFI.sol";

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract DAINFTFI is IDAINFTFI {
    Loan[] public loans;
    ERC20 public DAI;

    constructor(address _DAI) {
        DAI = ERC20(_DAI);
    }

    // // deposit DAI to the contract
	// function depositDAI(uint256 amount) external {
    //     DAI.transferFrom(msg.sender, address(this), amount);
    // }

	// // borrow DAI from the contract
	// function borrowDAI(uint256 amount) external {
    //     DAI.transferFrom(address(this), msg.sender, amount);
    // }

	// function depositNFT(address nftCollection, uint256 tokenId) external {
    //     ERC721(nftCollection).transferFrom(msg.sender, address(this), tokenId);
    // }

	function listLoan(address nftCollection, uint256 tokenId, uint256 loanAmount, uint256 interest) external {
        // check if this contract has approval for the NFT
        require(ERC721(nftCollection).getApproved(tokenId) == address(this), "NFT not approved");
        
        loans.push(Loan({
            nftCollection: nftCollection,
            tokenId: tokenId,
            loanAmount: loanAmount,
            interest: interest,
            borrower: msg.sender,
            lender: address(0),
            status: LoanStatus.Listed
        }));
    }

	function giveLoan(uint256 loanId) external {
        Loan storage loan = loans[loanId];
        require(loan.status == LoanStatus.Listed, "Loan is not listed");
        // also check the owner if it is the borrower
        require(ERC721(loan.nftCollection).ownerOf(loan.tokenId) == address(loan.borrower), "NFT moved");
        loan.lender = msg.sender;
        loan.status = LoanStatus.Given;

        // deposit the NFT to this contract
        ERC721(loan.nftCollection).transferFrom(loan.borrower, address(this), loan.tokenId);

        // transfer DAI to the borrower
        DAI.transferFrom(msg.sender, loan.borrower, loan.loanAmount);
    }

	function payBackLoan(uint256 loanId) external {
        Loan storage loan = loans[loanId];
        require(loan.status == LoanStatus.Given, "Loan is not given");

        // transfer DAI from the borrower to the lender with interest
        DAI.transferFrom(loan.borrower, loan.lender, loan.loanAmount + loan.interest);

        loan.status = LoanStatus.PaidBack;
    }

    function getLoans() external view returns (Loan[] memory) {
        return loans;
    }
}


	
