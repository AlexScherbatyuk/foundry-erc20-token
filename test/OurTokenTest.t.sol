// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";
import {OurToken} from "src/OurToken.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployOurToken;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTIN_BALANCE = 100 ether;
    uint256 public constant ALLOWANCE_AMOUNT = 50 ether;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        deployOurToken = new DeployOurToken();
        ourToken = deployOurToken.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTIN_BALANCE);
    }

    /*//////////////////////////////////////////////////////////////
                              BASIC TESTS
    //////////////////////////////////////////////////////////////*/

    function testInitialSupply() public view {
        assertEq(ourToken.totalSupply(), deployOurToken.INITIAL_SUPPLAY());
    }

    function testBobBalance() public view {
        assertEq(ourToken.balanceOf(bob), STARTIN_BALANCE);
    }

    /*//////////////////////////////////////////////////////////////
                             TRANSFER TESTS
    //////////////////////////////////////////////////////////////*/
    function testTransfer() public {
        uint256 balanceABefore = ourToken.balanceOf(bob);
        uint256 balanceBBefore = ourToken.balanceOf(alice);

        vm.prank(bob);
        ourToken.transfer(alice, STARTIN_BALANCE);

        assertEq(ourToken.balanceOf(bob), balanceABefore - STARTIN_BALANCE);
        assertEq(ourToken.balanceOf(alice), balanceBBefore + STARTIN_BALANCE);
    }

    function testTransferFailsInsufficientBalance() public {
        uint256 balanceA = ourToken.balanceOf(bob);
        vm.prank(bob);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, bob, balanceA, balanceA + 1)
        );
        ourToken.transfer(alice, balanceA + 1);
    }

    function testTransferZeroAmount() public {
        uint256 balanceABefore = ourToken.balanceOf(bob);
        uint256 balanceBBefore = ourToken.balanceOf(alice);

        vm.prank(bob);
        ourToken.transfer(alice, 0);

        assertEq(ourToken.balanceOf(bob), balanceABefore);
        assertEq(ourToken.balanceOf(alice), balanceBBefore);
    }

    function testTransferEmitsEvent() public {
        vm.prank(bob);
        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, STARTIN_BALANCE);
        ourToken.transfer(alice, STARTIN_BALANCE);
    }

    /*//////////////////////////////////////////////////////////////
                            ALLOWANCE TESTS
    //////////////////////////////////////////////////////////////*/

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;
        // Bob apprvoves Alice to spend tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTIN_BALANCE - transferAmount);
    }

    function testApproveAndAllowance() public {
        vm.prank(bob);
        ourToken.approve(alice, ALLOWANCE_AMOUNT);

        assertEq(ourToken.allowance(bob, alice), ALLOWANCE_AMOUNT);
    }

    function testTransferFrom() public {
        vm.prank(bob);
        ourToken.approve(alice, ALLOWANCE_AMOUNT);

        uint256 balanceABefore = ourToken.balanceOf(bob);
        uint256 balanceBBefore = ourToken.balanceOf(alice);

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, ALLOWANCE_AMOUNT);

        assertEq(ourToken.balanceOf(bob), balanceABefore - ALLOWANCE_AMOUNT);
        assertEq(ourToken.balanceOf(alice), balanceBBefore + ALLOWANCE_AMOUNT);
        assertEq(ourToken.allowance(bob, alice), 0);
    }

    function testTransferFromFailsInsufficientAllowance() public {
        vm.prank(bob);
        ourToken.approve(alice, ALLOWANCE_AMOUNT);

        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientAllowance.selector, alice, ALLOWANCE_AMOUNT, ALLOWANCE_AMOUNT + 1
            )
        );
        ourToken.transferFrom(bob, alice, ALLOWANCE_AMOUNT + 1);
    }

    function testTransferFromEmitsEvent() public {
        vm.prank(bob);
        ourToken.approve(alice, ALLOWANCE_AMOUNT);

        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, ALLOWANCE_AMOUNT);
        ourToken.transferFrom(bob, alice, ALLOWANCE_AMOUNT);
    }

    /*//////////////////////////////////////////////////////////////
                            ADDITIONAL TESTS
    //////////////////////////////////////////////////////////////*/
    function testTokenMetadata() public view {
        assertEq(ourToken.name(), "OurToken");
        assertEq(ourToken.symbol(), "OT");
        assertEq(ourToken.decimals(), 18);
    }

    function testTransferToZeroAddressFails() public {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        ourToken.transfer(address(0), STARTIN_BALANCE);
    }

    function testApproveToZeroAddressFails() public {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidSpender.selector, address(0)));
        ourToken.approve(address(0), ALLOWANCE_AMOUNT);
    }

    function testTransferFromZeroAddressFails() public {
        vm.prank(bob);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, bob, 0, STARTIN_BALANCE)
        );
        ourToken.transferFrom(address(0), alice, STARTIN_BALANCE);
    }

    function testBalanceOfZeroAddress() public view {
        assertEq(ourToken.balanceOf(address(0)), 0);
    }
}
