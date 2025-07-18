// contracts/MyAccountERC7913.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {Account} from "@openzeppelin/contracts/account/Account.sol";
import {ERC7821} from "@openzeppelin/contracts/account/extensions/draft-ERC7821.sol";
import {ERC7739} from "@openzeppelin/contracts/utils/cryptography/signers/draft-ERC7739.sol";
import {
    MultiSignerERC7913Weighted
} from "@openzeppelin/contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract MyAccountMultiSignerWeighted is
    Account,
    MultiSignerERC7913Weighted,
    ERC7739,
    ERC7821,
    ERC721Holder,
    ERC1155Holder,
    Initializable
{
    constructor(
        bytes[] memory signers,
        uint64[] memory weights,
        uint64 threshold
    ) EIP712("MyAccountMultiSignerWeighted", "1") MultiSignerERC7913Weighted(signers, weights, threshold) {}

    function initialize(bytes[] memory signers, uint64[] memory weights, uint64 threshold) public initializer {
        _addSigners(signers);
        _setSignerWeights(signers, weights);
        _setThreshold(threshold);
    }

    function addSigners(bytes[] memory signers) public onlyEntryPointOrSelf {
        _addSigners(signers);
    }

    function removeSigners(bytes[] memory signers) public onlyEntryPointOrSelf {
        _removeSigners(signers);
    }

    function setThreshold(uint64 threshold) public onlyEntryPointOrSelf {
        _setThreshold(threshold);
    }

    function setSignerWeights(bytes[] memory signers, uint64[] memory weights) public onlyEntryPointOrSelf {
        _setSignerWeights(signers, weights);
    }

    /// @dev Allows the entry point as an authorized executor.
    function _erc7821AuthorizedExecutor(
        address caller,
        bytes32 mode,
        bytes calldata executionData
    ) internal view virtual override returns (bool) {
        return caller == address(entryPoint()) || super._erc7821AuthorizedExecutor(caller, mode, executionData);
    }
}
