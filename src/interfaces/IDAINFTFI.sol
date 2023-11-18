// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

interface IDAINFTFI {
	enum LoanStatus{Listed, Given, PaidBack}
    struct Loan {
		address borrower;
		address nftCollection;
		uint256 tokenId;
		uint256 loanAmount;
		uint256 interest;
		address lender;
		LoanStatus status;
	}
	// // deposit DAI to the contract
	// function depositDAI(uint256 amount) external;

	// // borrow DAI from the contract
	// function borrowDAI(uint256 amount) external;

	// function depositNFT(address nftCollection, uint256 tokenId) external;

	function listLoan(address nftCollection, uint256 tokenId, uint256 loanAmount, uint256 interest) external;

	function giveLoan(uint256 loanId) external;

	function payBackLoan(uint256 loanId) external;

	function getLoans() external view returns (Loan[] memory);
}