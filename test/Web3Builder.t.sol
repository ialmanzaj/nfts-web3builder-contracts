// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {Web3Builder} from "../src/Web3Builder.sol";

contract Web3BuilderTest is Test {
    //1. Max Supply
    //2. Successful mint
    //3. Failed mint due to insufficient balance
    //4. Withdraw (by owner)

    address owner = address(0x1223);
    address alice = address(0x1889);
    address bob = address(0x1778);
    address jake = address(0x42910);

    address[] allowList = new address[](2);

    Web3Builder public builder;

    function setUp() public {
        vm.startPrank(owner);
        builder = new Web3Builder();
        builder.editMintWindows(true, true);
        vm.stopPrank();
    }

    function testMaxSupply() public {
        assertEq(builder.MAX_SUPPLY(), 999);
    }

    // test for unsuccesfull mint due to insuffucient funds
    function testCannotPublicMint() public {
        // switch account
        vm.startPrank(bob);
        //and give it some money
        vm.deal(bob, 0.001 ether);
        vm.expectRevert();
        builder.publicMint{value: 0.001 ether}();
    }

    // test for a succesfull mint
    function testPublicMintOpened() public {
        // switch account
        vm.startPrank(alice);
        //and give it some money
        vm.deal(alice, 1 ether);
        builder.publicMint{value: 0.01 ether}();
        vm.stopPrank();
        assertEq(builder.balanceOf(alice), 1);
    }

    // test to succesfull set allowlist
    function testSetAllowList() public {
        // switch account
        vm.startPrank(owner);
        allowList[0] = bob;
        allowList[1] = alice;
        builder.setAllowList(allowList);
        assertEq(builder.isAddressReserved(bob), true);
    }

    // test to succesfull set allowlist
    function testWhiteListMint() public {
        // switch account
        vm.startPrank(owner);
        allowList[0] = bob;
        builder.setAllowList(allowList);
        vm.stopPrank();
        assertEq(builder.isAddressReserved(bob), true);
        vm.startPrank(bob);
        vm.deal(bob, 0.01 ether);
        builder.allowListMint{value: 0.01 ether}();
        assertEq(builder.balanceOf(bob), 1);
        vm.stopPrank();
    }

    // test to unsuccesfull  allowlist mint
    function testWhiteListMintFail() public {
        // switch account
        vm.startPrank(owner);
        allowList[0] = bob;
        builder.setAllowList(allowList);
        vm.stopPrank();
        assertEq(builder.isAddressReserved(bob), true);
        vm.startPrank(jake);
        vm.deal(jake, 0.01 ether);
        vm.expectRevert();
        builder.allowListMint{value: 0.01 ether}();
        vm.stopPrank();
    }

    // test to unsuccesfull set allowlist unauthorized
    function testSetAllowListFail() public {
        // switch account
        vm.startPrank(alice);
        allowList[0] = bob;
        allowList[1] = alice;
        vm.expectRevert();
        builder.setAllowList(allowList);
    }
}
