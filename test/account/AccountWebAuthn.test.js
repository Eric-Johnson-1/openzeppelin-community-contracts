const { ethers, predeploy } = require('hardhat');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');

const { getDomain } = require('@openzeppelin/contracts/test/helpers/eip712');
const { ERC4337Helper } = require('@openzeppelin/contracts/test/helpers/erc4337');
const { NonNativeSigner, P256SigningKey } = require('@openzeppelin/contracts/test/helpers/signers');
const { WebAuthnSigningKey } = require('../helpers/signers');
const { PackedUserOperation } = require('@openzeppelin/contracts/test/helpers/eip712-types');

const {
  shouldBehaveLikeAccountCore,
  shouldBehaveLikeAccountHolder,
} = require('@openzeppelin/contracts/test/account/Account.behavior');
const { shouldBehaveLikeERC1271 } = require('@openzeppelin/contracts/test/utils/cryptography/ERC1271.behavior');
const { shouldBehaveLikeERC7821 } = require('@openzeppelin/contracts/test/account/extensions/ERC7821.behavior');

const webAuthnSigner = new NonNativeSigner(WebAuthnSigningKey.random());
const p256Signer = new NonNativeSigner(P256SigningKey.random());

async function fixture() {
  // EOAs and environment
  const [beneficiary, other] = await ethers.getSigners();
  const target = await ethers.deployContract('CallReceiverMock');

  // ERC-4337 account
  const helper = new ERC4337Helper();

  // ERC-4337 Entrypoint domain
  const entrypointDomain = await getDomain(predeploy.entrypoint.v08);

  // domain cannot be fetched using getDomain(mock) before the mock is deployed
  const domain = {
    name: 'AccountWebAuthn',
    version: '1',
    chainId: entrypointDomain.chainId,
  };

  const webAuthnMock = await helper.newAccount('$AccountWebAuthnMock', [
    webAuthnSigner.signingKey.publicKey.qx,
    webAuthnSigner.signingKey.publicKey.qy,
    'AccountWebAuthn',
    '1',
  ]);
  const p256Mock = await helper.newAccount('$AccountWebAuthnMock', [
    p256Signer.signingKey.publicKey.qx,
    p256Signer.signingKey.publicKey.qy,
    'AccountWebAuthn',
    '1',
  ]);

  // This function signs using P256 signature for fallback testing
  const signUserOp = function (userOp) {
    return this.signer
      .signTypedData(entrypointDomain, { PackedUserOperation }, userOp.packed)
      .then(signature => Object.assign(userOp, { signature }));
  };

  return { helper, domain, webAuthnMock, p256Mock, target, beneficiary, other, signUserOp };
}

describe('AccountWebAuthn', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture));
  });

  describe('WebAuthn Assertions', function () {
    beforeEach(async function () {
      this.signer = webAuthnSigner;
      this.mock = this.webAuthnMock;
      this.domain.verifyingContract = this.mock.address;
    });

    shouldBehaveLikeAccountCore();
    shouldBehaveLikeAccountHolder();
    shouldBehaveLikeERC1271({ erc7739: true });
    shouldBehaveLikeERC7821();
  });

  describe('as regular P256 validator', function () {
    beforeEach(async function () {
      this.signer = p256Signer;
      this.mock = this.p256Mock;
      this.domain.verifyingContract = this.mock.address;
    });

    shouldBehaveLikeAccountCore();
    shouldBehaveLikeAccountHolder();
    shouldBehaveLikeERC1271({ erc7739: true });
    shouldBehaveLikeERC7821();
  });
});
