// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenVesting is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    address public beneficiary;
    uint256 public start;
    uint256 public cliff;
    uint256 public duration;
    uint256 public totalAmount;
    uint256 public released;
    bool public revocable;
    bool public revoked;

    event TokensReleased(address token, uint256 amount);
    event VestingRevoked(address token);

    constructor(address token_, address beneficiary_, uint256 start_, uint256 cliffDuration, uint256 duration_, uint256 amount, bool revocable_)
        Ownable(msg.sender) {
        token = IERC20(token_);
        beneficiary = beneficiary_;
        start = start_;
        cliff = start_ + cliffDuration;
        duration = duration_;
        totalAmount = amount;
        revocable = revocable_;
    }

    function release() external {
        uint256 vested = vestedAmount() - released;
        require(vested > 0, "Nothing to release");
        released += vested;
        token.safeTransfer(beneficiary, vested);
        emit TokensReleased(address(token), vested);
    }

    function revoke() external onlyOwner {
        require(revocable, "Not revocable");
        require(!revoked, "Already revoked");
        uint256 vested = vestedAmount();
        uint256 refund = totalAmount - vested;
        revoked = true;
        if (refund > 0) token.safeTransfer(owner(), refund);
        emit VestingRevoked(address(token));
    }

    function vestedAmount() public view returns (uint256) {
        if (revoked) return released;
        if (block.timestamp < cliff) return 0;
        if (block.timestamp >= start + duration) return totalAmount;
        return (totalAmount * (block.timestamp - start)) / duration;
    }
}

contract VestingFactory {
    event VestingCreated(address indexed vesting, address indexed beneficiary, address indexed token);

    function createVesting(address token, address beneficiary, uint256 amount, uint256 start, uint256 cliffDuration, uint256 duration, bool revocable) external returns (address) {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        TokenVesting vesting = new TokenVesting(token, beneficiary, start, cliffDuration, duration, amount, revocable);
        IERC20(token).transfer(address(vesting), amount);
        emit VestingCreated(address(vesting), beneficiary, token);
        return address(vesting);
    }
}