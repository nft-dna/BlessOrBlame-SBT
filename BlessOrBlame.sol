// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
//import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./TokenUriLogicContract.sol";

contract SoulBoundBlessOrBlame is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;
    address public constant RewardContract =  address(0xE8aF6d7e77f5D9953d99822812DCe227551df1D7);
	mapping(uint16 => mapping(address => uint256)) private _balances;
	mapping(address => mapping(address => uint16 )) private _issuer;	

	TokenUriLogicContract public TokenUriLogic;
    uint256 public MintTokenPrice = 50000000000000000; // 0.050
    address private _creator;

    constructor() {
		_creator = _msgSender();
    }
	
    function setTokenUriLogic(address tokenUriLogic) external {
		require(_creator == _msgSender(), "must be owner");
        TokenUriLogic = TokenUriLogicContract(tokenUriLogic);
    }

    function setMintTokenPrice(uint256 price) external {
		require(_creator == _msgSender(), "must be owner");
        MintTokenPrice = price;
    }    
	
    // Opensea json metadata format interface
    function contractURI() external view returns (string memory) {
        return TokenUriLogic.contractURI();
    }	

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256 tokenId) external view override returns (string memory) {
        return TokenUriLogic.tokenURI((uint16)(tokenId));
    }

    function balanceOf(address account, uint256 id) public view override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        uint16 id16 = (uint16)(id);
        return _balances[id16][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    ) external view override returns (uint256[] memory) {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(
        address ,//operator, 
        bool //approved
        ) external pure override {
       }

    function isApprovedForAll(
        address ,//account, 
        address //operator
        ) external pure override returns (bool) {
        return false;
    }

    function isIssuerForAll(address issuer, address owner, uint16 id) internal view returns (bool) {
        return _issuer[issuer][owner] == id;
    }    

	function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint16  id
    ) internal view {
        require(from == address(0) || (to == address(0) && isIssuerForAll(operator, from, id)), "This a Soulbound token. It cannot be transferred. It can only be burned by the token issuer.");
	}

    function safeTransferFrom(
        address ,//from,
        address ,//to,
        uint256 ,//id,
        uint256 ,//amount,
        bytes memory //data
    ) public pure override { require(false, "not allowed on SBT"); }

   function safeBatchTransferFrom(
        address, //from,
        address, //to,
        uint256[] memory, //ids,
        uint256[] memory, //amounts,
        bytes memory //data
    ) public pure override { require(false, "not allowed on SBT"); }

    function isContract(address addr) public view returns (bool) {
        return addr.code.length > 0;
    }

    function mint(address to, uint16 id) external payable {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(id > 0, "min id");
        require(isContract(to) == false, "vote for the contract creator address instead");
        require(id <= TokenUriLogic.getMaxTokenId(), "max id");
        require(msg.value == MintTokenPrice, "wrong price");
        address operator = _msgSender();
        require(_issuer[operator][to] == 0, "already judged");

        _balances[id][to] += 1;
        _issuer[operator][to] = id;

        emit TransferSingle(operator, address(0), to, id, 1);
    }


    function burn(address from, uint16 id/*, uint256 amount*/) external {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        //uint256[] memory ids = _asSingletonArray(id);
        //uint256[] memory amounts = _asSingletonArray(amount);
        //_beforeTokenTransfer(operator, from, address(0), ids, amounts, "");
        _beforeTokenTransfer(operator, from, address(0), id);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= /*amount*/ 1, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - 1/*amount*/;
            _issuer[operator][from] = 0;
        }

        emit TransferSingle(operator, from, address(0), id, 1/*amount*/);

        //_afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    function setApprovalForAll(address owner, address operator, bool approved) external {
    }

    function withdraw(uint256 amount)
        external
        //onlyOwner
    {
        uint256 balance = address(this).balance;
        require(amount < balance);
        (bool success, ) = payable(RewardContract).call{value: amount}("");
        require(success, "Failed to send Ether");
    }    


}
