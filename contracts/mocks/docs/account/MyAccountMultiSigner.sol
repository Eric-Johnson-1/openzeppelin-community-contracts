// contracts/MyAccountERC7913.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {Account} from "../../../account/Account.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {ERC7739} from "../../../utils/cryptography/signers/ERC7739.sol";
import {ERC7821} from "../../../account/extensions/ERC7821.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {MultiSignerERC7913} from "../../../utils/cryptography/signers/MultiSignerERC7913.sol";

contract MyAccountMultiSigner is
    Account,
    MultiSignerERC7913,
    ERC7739,
    ERC7821,
    ERC721Holder,
    ERC1155Holder,
    Initializable
{
    constructor() EIP712("MyAccountMultiSigner", "1") {}

    function initialize(bytes[] memory signers, uint256 threshold) public initializer {
        _addSigners(signers);
        _setThreshold(threshold);
    }

    function addSigners(bytes[] memory signers) public onlyEntryPointOrSelf {
        _addSigners(signers);
    }

    function removeSigners(bytes[] memory signers) public onlyEntryPointOrSelf {
        _removeSigners(signers);
    }

    function setThreshold(uint256 threshold) public onlyEntryPointOrSelf {
        _setThreshold(threshold);
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
