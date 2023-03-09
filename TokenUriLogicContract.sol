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

    function generateCharacterSvg(uint16 tokenId) internal pure returns (bytes memory)
    {
        return bytes.concat(
            bytes("<path d=\"m238.6 527.04c40.159-28.728 44.752-57.666 67.86-85.91 15.266-18.659 29.303-28.496 46.75-55.184 0 0 16.018-33.15 32.278-33.394 22.309-0.3355 22.152 32.131 17.787 49.44-8.1548 32.334-20.443 49.152-44.696 79.753 36.455 46.381 84.4-27.994 126.85-3.8603 25.257 14.763 10.83 47.048-3.1209 57.152 18.09 19.656 16.829 34.498 6.579 53.655 7.4436 20.079-2.2659 45.793-11.066 55.468 22.836 25.115-8.737 52.997-32.669 60.559-63.072 25.535-96.072 5.4743-161.71-1.6449-102.6-25.49-94.89-140.25-44.84-176.05z\" stroke-width=\"2%\" stroke=\"black\" fill=\""),
            ((tokenId == 2) ? bytes("red") : bytes("green") ),
            bytes("\" />")
            );
    }

    function generateCharacter(uint16 tokenId) internal pure returns (bytes memory)
    {
        bytes memory svg = bytes.concat(
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<svg x="0px" y="0px" viewBox="0 150 800 800" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" preserveAspectRatio="xMinYMin meet"',
            ((tokenId == 2) ? bytes(" transform=\"scale(-1 -1)\"") : bytes(" ")),
            ' >',
            generateCharacterSvg(tokenId),
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
            " (BoB SBT)"
            //bytes(id256.toString()),
            //' owned: ',
            //bytes(MainContract.balanceOf(tokenOwner).toString()),
            '",'
            '"description": "BlessOrBlame SBT",'
            '"image": "',
            generateCharacter(tokenId),
            '"'
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
            '"description": "Bless Or Blame, a reputational SoulBoundToken"',
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
