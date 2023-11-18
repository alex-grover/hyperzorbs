// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/*
 _                                         _          ____
| |__  _   _ _ __   ___ _ __ _______  _ __| |__      / / /
| '_ \| | | | '_ \ / _ \ '__|_  / _ \| '__| '_ \    / / /
| | | | |_| | |_) |  __/ |   / / (_) | |  | |_) |  / / /
|_| |_|\__, | .__/ \___|_|  /___\___/|_|  |_.__/  /_/_/
       |___/|_|
*/

import {Base64} from "openzeppelin/utils/Base64.sol";
import {Strings} from "openzeppelin/utils/Strings.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";
import {IERC4906} from "./IERC4906.sol";

contract Hyperzorb is ERC721, IERC4906, Owned {
    string private constant _DESCRIPTION =
        "An experiment in community-driven Zorb development. Everyone's Zorb changes color with each mint.";
    uint256 public constant mintPrice = 0.000777 ether;
    uint256 public totalSupply;

    constructor() ERC721("hyperzorbs //", "HYPER") Owned(address(0xD6507fC98605eAb8775f851c25A5E09Dc12ab7A7)) {}

    function mint() public payable {
        require(msg.value >= mintPrice, "Insufficient ether");

        ++totalSupply;
        _mint(msg.sender, totalSupply);

        emit BatchMetadataUpdate(1, totalSupply);

        if (msg.value > mintPrice) {
            (bool sent,) = msg.sender.call{value: msg.value - mintPrice}("");
            require(sent, "Refund mint failed");
        }
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        require(id != 0 && id <= totalSupply, "Not minted");

        string memory image = render(totalSupply);

        return string.concat(
            "data:application/json;base64,",
            Base64.encode(
                bytes(
                    string.concat(
                        '{"name":"hyperzorb ',
                        Strings.toString(id),
                        ' //", "description":"',
                        _DESCRIPTION,
                        '", "image": "',
                        image,
                        '"}'
                    )
                )
            )
        );
    }

    function contractURI() external view returns (string memory) {
        string memory image = render(0);

        return string.concat(
            "data:application/json;base64,",
            Base64.encode(
                bytes(
                    string.concat('{"name":"', name, '", "description":"', _DESCRIPTION, '", "image": "', image, '"}')
                )
            )
        );
    }

    // Renders unique colors up to quantity 360
    function render(uint256 quantity) public pure returns (string memory svg) {
        return string.concat(
            "data:image/svg+xml;base64,",
            Base64.encode(
                bytes(
                    string.concat(
                        '<svg width="661" height="661" viewBox="0 0 661 661" fill="none" xmlns="http://www.w3.org/2000/svg">',
                        '<path d="M4.6343 275.446C-25.4958 454.922 95.9687 625.397 275.445 655.527C454.921 685.657 625.396 564.192 655.526 384.716C685.49 205.212 564.026 34.7375 384.715 4.63523C205.239 -25.4949 34.7644 95.9696 4.6343 275.446Z" fill="url(#paint0_radial_1467_0)" />',
                        "<defs>",
                        '<radialGradient id="paint0_radial_1467_0" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(452.155 193.511) rotate(138.09) scale(529.332 529.332)">',
                        '<stop offset="0.0267" stop-color="#FFFFFF" />',
                        '<stop offset="0.35" stop-color="hsl(',
                        Strings.toString(quantity),
                        ',100%,50%)" />',
                        "</radialGradient>",
                        "</defs>",
                        "</svg>"
                    )
                )
            )
        );
    }

    function withdraw() external onlyOwner {
        (bool sent,) = owner.call{value: address(this).balance}("");
        require(sent, "Withdraw failed");
    }
}
