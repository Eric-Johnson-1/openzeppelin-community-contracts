// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {Account} from "../../account/Account.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {ERC7739} from "../../utils/cryptography/signers/ERC7739.sol";
import {ERC7821} from "../../account/extensions/ERC7821.sol";
import {MultiSignerERC7913Weighted} from "../../utils/cryptography/signers/MultiSignerERC7913Weighted.sol";

abstract contract AccountMultiSignerWeightedMock is
    Account,
    MultiSignerERC7913Weighted,
    ERC7739,
    ERC7821,
    ERC721Holder,
    ERC1155Holder
{
    constructor(bytes[] memory signers, uint256[] memory weights, uint256 threshold) {
        _addSigners(signers);
        _setSignerWeights(signers, weights);
        _setThreshold(threshold);
    }

    /// @inheritdoc ERC7821
    function _erc7821AuthorizedExecutor(
        address caller,
        bytes32 mode,
        bytes calldata executionData
    ) internal view virtual override returns (bool) {
        return caller == address(entryPoint()) || super._erc7821AuthorizedExecutor(caller, mode, executionData);
    }
}
