// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {Hyperzorb} from "src/hyperzorb.sol";

contract HyperzorbTest is Test {
    address constant _OWNER = address(0xD6507fC98605eAb8775f851c25A5E09Dc12ab7A7);

    function test_constructor() external {
        Hyperzorb zorb = new Hyperzorb();
        assertEq(zorb.name(), "hyperzorbs //");
        assertEq(zorb.symbol(), "HYPER");
        assertEq(zorb.owner(), _OWNER);
    }

    function test_mint() external {
        Hyperzorb zorb = new Hyperzorb();

        zorb.mint{value: 0.000777 ether}();

        assertEq(zorb.balanceOf(address(this)), 1);
    }

    function test_mintRefundsExtraEther() external {
        Hyperzorb zorb = new Hyperzorb();
        zorb.mint{value: 1 ether}();

        assertEq(address(zorb).balance, 0.000777 ether);
    }

    function test_cannotMintWithInsufficientEther() external {
        Hyperzorb zorb = new Hyperzorb();

        vm.expectRevert();
        zorb.mint{value: 0.0001 ether}();
    }

    function test_tokenUri() external {
        Hyperzorb zorb = new Hyperzorb();
        zorb.mint{value: 0.000777 ether}();

        zorb.tokenURI(1);
    }

    function test_cannotCallTokenUriWithUnmintedToken() external {
        Hyperzorb zorb = new Hyperzorb();

        vm.expectRevert();
        zorb.tokenURI(1);
    }

    function test_withdraw() external {
        Hyperzorb zorb = new Hyperzorb();

        vm.prank(_OWNER);
        zorb.withdraw();

        assertEq(address(zorb).balance, 0);
    }

    function test_cannotWithdrawAsNonOwner(address nonOwner) external {
        vm.assume(nonOwner != _OWNER);
        Hyperzorb zorb = new Hyperzorb();

        vm.prank(nonOwner);
        vm.expectRevert();
        zorb.withdraw();
    }

    receive() external payable {}
}
