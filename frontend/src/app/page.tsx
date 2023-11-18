"use client";

import { useEffect, useState } from "react";
import { ethers } from "ethers";

export function ConnectButton() {
  return <w3m-button />;
}

const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");
const wallet = new ethers.Wallet(
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
  provider
);

const tokenAbi = [
  "function mint(address to, uint256 amount) external",
  "function balanceOf(address account) external view returns (uint256)",
]; // Token contract ABI
const mockDai = new ethers.Contract(
  "0x5FbDB2315678afecb367f032d93F642f64180aa3",
  tokenAbi,
  wallet
);

const mockNFTAbi = [
  "function mint(address to, uint256 tokenId) external",
  "function balanceOf(address owner) public view returns (uint256 balance)",
  "function approve(address to, uint256 tokenId) public",
];
const mockNFT = new ethers.Contract(
  "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9",
  mockNFTAbi,
  wallet
);

const DAINFTFIABI = [
  "function listLoan(address nftCollection, uint256 tokenId, uint256 loanAmount, uint256 interest) external",
  "function getLoans() external view returns (tuple(address borrower, address nftCollection, uint256 tokenId, uint256 loanAmount, uint256 interest, address lender, uint8 status)[] memory)",
];

const DAINFTFI = new ethers.Contract(
  "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
  DAINFTFIABI,
  wallet
);

const conduitAbi = [
  "function setRegistry(address _registry) external",
  "function giveLoan(bytes32 ilk, address asset, uint256 loanId) external",
];
const conduitContract = new ethers.Contract(
  "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
  tokenAbi,
  wallet
);

const registryAbi = [
  "function setBuffer(address b) external",
  "function buffers(bytes32) external view",
];
const registryContract = new ethers.Contract(
  "0x8A791620dd6260079BF849Dc5567aDC3F2FdC318",
  registryAbi,
  wallet
);

const NFTID = 1;

export default function Home() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isLoanModalOpen, setIsLoanModalOpen] = useState(false);
  const [curDaiBalance, setDaiBalance] = useState("0");
  const [curNFTBalance, setNFTBalance] = useState("0");

  const toggleModal = () => {
    setIsModalOpen(!isModalOpen);
  };
  const toggleLoanModal = () => {
    setIsLoanModalOpen(!isLoanModalOpen);
  };

  const listLoan = async () => {
    const tx = await DAINFTFI.listLoan(
      "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9",
      NFTID,
      ethers.parseEther("100"),
      ethers.parseEther("0.1")
    );
    await tx.wait();

    await fetchBalance();
  };

  const giveLoan = async () => {
    const tx = await conduitContract.giveLoan(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      "0x5FbDB2315678afecb367f032d93F642f64180aa3",
      0
    );
    await tx.wait();

    await fetchBalance();
  };

  const setRegistryAndBuffer = async () => {
    const registryTx = await registryContract.setBuffer(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
    );
    await registryTx.wait();
    console.log(await registryContract.buffers());

    const conduitTx = await conduitContract.setRegistry(
      "0x8A791620dd6260079BF849Dc5567aDC3F2FdC318"
    );
    await conduitTx.wait();
  };

  const mintMockDai = async () => {
    const mintTx = await mockDai.mint(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      ethers.parseEther("100")
    );
    await mintTx.wait();

    await fetchBalance();
  };

  const mintMockNFT = async () => {
    const mintTx = await mockNFT.mint(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      NFTID
    );
    await mintTx.wait();

    await fetchNFTs();
  };

  async function fetchBalance() {
    const daiBalance = await mockDai.balanceOf(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
    );
    setDaiBalance(ethers.formatEther(daiBalance.toString()));
  }

  async function fetchNFTs() {
    const nftBalance = await mockNFT.balanceOf(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
    );
    console.log(`Balance is ${nftBalance}`);
    setNFTBalance(nftBalance.toString());
  }

  async function approveNFT() {
    const approveTx = await mockNFT.approve(
      "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
      NFTID
    );
    await approveTx.wait();
  }

  async function fetchLoans() {
    const loans = await DAINFTFI.getLoans();
    console.log(`Loans ${loans}`);
  }

  useEffect(() => {
    fetchBalance();
    fetchNFTs();
    fetchLoans();
  });

  return (
    <div>
      {isModalOpen && (
        <div className="fixed inset-0 flex items-center justify-center z-50">
          <div className="bg-white dark:bg-gray-900 p-8 rounded shadow w-full max-w-xl mx-auto">
            <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-gray-100">
              List Loan
            </h2>
            <input
              aria-label="Title"
              className="w-full p-2 rounded border border-gray-300 dark:border-gray-700 mb-4 text-black"
              placeholder="Loan Amount"
              type="text"
            />
            <input
              aria-label="Description"
              className="w-full p-2 rounded border border-gray-300 dark:border-gray-700 mb-4 text-black"
              placeholder="Interest Rate"
              type="text"
            />
            <div className="flex gap-5">
              <button
                className="w-full text-white bg-green-500 hover:bg-green-700 px-4 py-2 rounded"
                onClick={approveNFT}
              >
                Approve NFT
              </button>
              <button
                className="w-full text-white bg-green-500 hover:bg-green-700 px-4 py-2 rounded"
                onClick={listLoan}
              >
                Submit
              </button>
              <button
                className="w-full text-white bg-green-500 hover:bg-green-700 px-4 py-2 rounded"
                onClick={toggleModal}
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
      {isLoanModalOpen && (
        <div className="fixed inset-0 flex items-center justify-center z-50">
          <div className="bg-white dark:bg-gray-900 p-8 rounded shadow w-full max-w-xl mx-auto">
            <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-gray-100">
              Loan Info
            </h2>
            <h3>
              Loan Amount <span>100 DAI</span>
            </h3>
            <h3>
              Loan Interest Rate <span>10%</span>
            </h3>
            <div className="flex gap-5">
              <button
                className="w-full text-white bg-green-500 hover:bg-green-700 px-4 py-2 rounded"
                onClick={approveNFT}
              >
                Approve NFT
              </button>
              <button
                className="w-full text-white bg-green-500 hover:bg-green-700 px-4 py-2 rounded"
                onClick={giveLoan}
              >
                Loan
              </button>
              <button
                className="w-full text-white bg-green-500 hover:bg-green-700 px-4 py-2 rounded"
                onClick={toggleLoanModal}
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
      <div className="w-full py-12 md:py-24 lg:py-32 bg-gray-200 dark:bg-gray-800">
        <nav className="container flex justify-between items-center p-4 md:p-6 bg-white dark:bg-gray-900">
          <h1 className="text-lg font-bold tracking-tighter sm:text-xl xl:text-2xl text-gray-900 dark:text-gray-100">
            DAI-centric NFT Lending With Conduit
          </h1>
          <div className="flex items-center gap-4">
            <button
              className="text-white bg-green-500 hover:bg-green-700 px-4 py-2 rounded"
              onClick={setRegistryAndBuffer}
            >
              Init Registry
            </button>
            <button
              className="text-white bg-green-500 hover:bg-green-700 px-4 py-2 rounded"
              onClick={mintMockDai}
            >
              Mint Dai
            </button>
            <h1 className="text-white">{curDaiBalance}</h1>
            <button
              className="text-white bg-green-500 hover:bg-green-700 px-4 py-2 rounded"
              onClick={mintMockNFT}
            >
              Mint NFT
            </button>
            <h1 className="text-white">{curNFTBalance}</h1>
          </div>

          {/* <ConnectButton /> */}
        </nav>
        <div className="container flex flex-col gap-12 px-4 md:px-6">
          <div className="p-8">
            <h2 className="text-lg font-bold tracking-tighter text-left sm:text-xl xl:text-2xl">
              My NFTs
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 mt-8">
              <div className="p-4 bg-white dark:bg-gray-900 rounded shadow">
                <button
                  className="p-4 bg-white dark:bg-gray-900 rounded shadow cursor-pointer"
                  onClick={toggleModal}
                >
                  <img
                    alt="NFT Image"
                    height="200"
                    src="/y00t.jpeg"
                    style={{
                      aspectRatio: "200/200",
                      objectFit: "cover",
                    }}
                    width="200"
                  />
                </button>
                <h3 className="text-base sm:text-lg md:text-xl font-semibold text-gray-900 dark:text-gray-100 mt-4">
                  Y00t
                </h3>
              </div>
            </div>
          </div>
          <div className="p-8">
            <h2 className="text-lg font-bold tracking-tighter text-left sm:text-xl xl:text-2xl">
              Peer To Peer Loans
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 mt-8">
              <div className="p-4 bg-white dark:bg-gray-900 rounded shadow">
                <button
                  className="p-4 bg-white dark:bg-gray-900 rounded shadow cursor-pointer"
                  onClick={toggleLoanModal}
                >
                  <img
                    alt="NFT Image"
                    height="200"
                    src="/y00t.jpeg"
                    style={{
                      aspectRatio: "200/200",
                      objectFit: "cover",
                    }}
                    width="200"
                  />
                </button>
                <h3 className="text-base sm:text-lg md:text-xl font-semibold text-gray-900 dark:text-gray-100 mt-4">
                  Loan 1
                </h3>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
