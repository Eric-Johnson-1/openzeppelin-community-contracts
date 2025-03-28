// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Account} from "../../account/Account.sol";
import {ERC7821} from "../../account/extensions/ERC7821.sol";
import {SignerECDSA} from "../../utils/cryptography/SignerECDSA.sol";

abstract contract AccountECDSAMock is Account, SignerECDSA, ERC7821 {
    constructor(address signerAddr) {
        _setSigner(signerAddr);
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
