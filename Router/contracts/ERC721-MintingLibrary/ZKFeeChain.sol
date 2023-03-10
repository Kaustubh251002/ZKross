// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FeeChain.sol";

contract ZKFeeChain is OnFeeChain {
  using SafeERC20 for IERC20;
  address public owner;

  constructor(
    string memory name_,
    string memory symbol_,
    uint256 mintingChainID_,
    address genericHandler_
  ) OnFeeChain(name_, symbol_, mintingChainID_, genericHandler_) {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner");
    _;
  }

  /// @notice Function to set the linker address
  /// @dev Only owner can call this function
  /// @param _linker Address of the linker
  function setLinker(address _linker) external onlyOwner {
    setLink(_linker);
  }

  /// @notice Function to set the fee token address
  /// @dev Only owner can call this function
  /// @param _feeToken Address of the fee token
  function setFeesToken(address _feeToken) external onlyOwner {
    setFeeToken(_feeToken);
  }

  /// @notice Function to approve the generic handler to cut fees from this contract
  /// @dev Only owner can call this function
  /// @param _feeToken Address of the fee token
  /// @param _amount Amount of approval
  function _approveFees(address _feeToken, uint256 _amount) external onlyOwner {
    approveFees(_feeToken, _amount);
  }

  /// @notice Function to set the cross-chain gas limit
  /// @dev Only owner can call this function
  /// @param _gasLimit amount of gas limit to be set
  function setCrossChainGasLimit(uint256 _gasLimit) external onlyOwner {
    _setCrossChainGasLimit(_gasLimit);
  }

  /// @notice Function to set the fee token for minting NFT
  /// @dev Only owner can call this function
  /// @param _feeToken address  of the fee token
  function setFeeTokenForNFT(address _feeToken) external onlyOwner {
    _setFeeTokenForNFT(_feeToken);
  }

  /// @notice Function to set the amount of fee token for minting one NFT
  /// @dev Only owner can call this function
  /// @param _price price of NFT in fee tokens
  function setFeeInTokenForNFT(uint256 _price) external onlyOwner {
    _setFeeInTokenForNFT(_price);
  }

  /// @notice Function to mint NFTs cross-chain
  /// @param _recipient address  of the recipient on the minting chain
  /// @param _refundAddress address of the wallet to which refund is to be processed
  /// in case NFT is not available on destination chain
  /// @param _crossChainGasPrice gas price that you are willing to pay to execute the
  /// transaction on the minting chain
  /// @dev If the _crossChainGasPrice is less than required, the transaction can get stuck
  /// on the bridge and you may need to replay the transaction.
  function mintCrossChain(
    address _recipient,
    address _refundAddress,
    uint256 _crossChainGasPrice
  ) external returns (bytes32) {
    (bool sent, bytes32 hash) = _mintCrossChain(
      _recipient,
      _refundAddress,
      _crossChainGasPrice
    );
    require(sent == true, "Unsuccessful");
    return hash;
  }

  /// @notice function to create a cross-chain request to transfer NFT cross-chain
  /// @dev The contract burns the NFT into the contract and creates a cross-chain request
  /// to mint (on fee chains) /unlock (on minting chain) the NFT on the destination chain
  /// @param destChainId chainId of the destination chain(router specs - https://dev.routerprotocol.com/important-parameters/supported-chains)
  /// @param recipient address of the recipient on the destination chain
  /// @param tokenId of the token user is willing to transfer cross-chain
  /// @param crossChainGasPrice gas price that you are willing to pay to execute the
  /// transaction on the minting chain
  /// @dev If the crossChainGasPrice is less than required, the transaction can get stuck
  /// on the bridge and you may need to replay the transaction.
  function transferCrossChain(
    uint8 destChainId,
    address recipient,
    uint256 tokenId,
    uint256 crossChainGasPrice
  ) external returns (bytes32) {
    (bool sent, bytes32 hash) = _transferCrossChain(
      destChainId,
      recipient,
      tokenId,
      crossChainGasPrice
    );

    require(sent == true, "Unsuccessful");
    return hash;
  }

  /// @notice function to replay a transaction stuck on the bridge due to insufficient
  /// cross-chain gas limit or gas price passed in _mintCrossChain function
  /// @dev gasLimit and gasPrice passed in this function should be greater than what was passed earlier
  /// @param hash hash returned from RouterSend function should be used to replay a tx
  /// @param gasLimit gas limit to be passed for executing the tx on destination chain
  /// @param gasPrice gas price to be passed for executing the tx on destination chain
  function relpayTransaction(
    bytes32 hash,
    uint256 gasLimit,
    uint256 gasPrice
  ) external onlyOwner {
    replayTx(hash, gasLimit, gasPrice);
  }

  /// @notice function to withdraw fee tokens used for payment to the bridge
  function recoverFeeTokens() external onlyOwner {
    address feeToken = this.fetchFeeToken();
    uint256 amount = IERC20(feeToken).balanceOf(address(this));
    IERC20(feeToken).safeTransfer(owner, amount);
  }

  /// @notice function to withdraw fee tokens received as payment for NFT
  function withdrawFeeTokenForNFT() external override onlyOwner {
    address feeToken = this.fetchFeeTokenForNFT();
    uint256 amount = IERC20(feeToken).balanceOf(address(this));
    IERC20(feeToken).safeTransfer(owner, amount);
  }
}
