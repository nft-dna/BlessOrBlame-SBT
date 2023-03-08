// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract TokenUriLogicContract is Ownable {
    using Strings for uint256;

    uint16 private _maxTokenId = 2;

    constructor() {      
    }

    function setMaxTokenId(uint16 maxTokenId) external {
        require(msg.sender == owner(), "must be owner");
        _maxTokenId = maxTokenId;
    }

    function getMaxTokenId() external view returns (uint16) {
        return _maxTokenId;
    }

    function generateCharacter(uint16 /*tokenId*/) internal pure returns (bytes memory)
    {
        bytes memory svg = bytes.concat(
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<svg x="0px" y="0px" viewBox="0 0 480 480" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" preserveAspectRatio="xMinYMin meet">',
            '<rect x="0" y="0" width="480" height="480" fill="',
            bytes("rgb(238,238,238)"),
            '" />',
            //generateCharacterSvg(tokenId, isNight, ownedcount),
            "</svg>"
        );
        return
            bytes.concat(
                "data:image/svg+xml;base64,",
                bytes(Base64.encode(svg))
            );
    }


    function tokenURI(uint16 tokenId) external pure returns (string memory)
    {
        //uint256 id256 = tokenId;

        bytes memory dataURI = bytes.concat(
            "{"
            '"name": "',
            ((tokenId == 1) ? bytes("Bless")  : bytes("Blame")),
            " BoB"
            //bytes(id256.toString()),
            //' owned: ',
            //bytes(MainContract.balanceOf(tokenOwner).toString()),
            '",'
            '"description": "BlessOrBlame SBT",'
            '"image": "',
            generateCharacter(tokenId),
            '"'
            "]"
            "}"
        );
        return
            string(
                bytes.concat(
                    "data:application/json;base64,",
                    bytes(Base64.encode(dataURI))
                )
            );
    }

    // Opensea json metadata format interface
    function contractURI() external pure returns (string memory) {
        bytes memory dataURI = bytes.concat(
            "{",
            '"name": "BlessOrBlame",',
            '"description": "Bless Or Blame reputational SoulBoundToken"',
            "}"
        );
        return
            string(
                bytes.concat(
                    "data:application/json;base64,",
                    bytes(Base64.encode(dataURI))
                )
            );
    }
}
