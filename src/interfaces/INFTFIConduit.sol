// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

import { IAllocatorConduit } from 'dss-allocator/IAllocatorConduit.sol';

interface INFTFiConduit is IAllocatorConduit {
    function registry() external view returns (address);
    function setRegistry(address _registry) external;
    function giveLoan(bytes32 ilk, address asset, uint256 loanId) external;

    /**********************************************************************************************/
    /*** View Functions                                                                         ***/
    /**********************************************************************************************/

    // /**
    //  *  @notice Returns the amount of available liquidity in the SparkLend pool for a given asset.
    //  *  @return The balance of tokens in the asset's reserve's aToken address.
    //  */
    // function getAvailableLiquidity(address asset) external view returns (uint256);

    // /**
    //  *  @notice Gets the total deposits of an asset.
    //  *  @param  asset The address of the asset.
    //  *  @return The total amount of deposits for the asset.
    //  */
    // function getTotalDeposits(address asset) external view returns (uint256);

    // /**
    //  *  @notice Gets the deposits for a given ilk and asset.
    //  *  @param  asset The asset to get the deposits for.
    //  *  @param  ilk   The ilk to get the deposits for.
    //  *  @return The total amount of deposits for the given ilk and asset.
    //  */
    // function getDeposits(address asset, bytes32 ilk) external view returns (uint256);
}
