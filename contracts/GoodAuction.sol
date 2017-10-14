pragma solidity ^0.4.15;

import "./AuctionInterface.sol";

/** @title GoodAuction */
contract GoodAuction is AuctionInterface {
	/* New data structure, keeps track of refunds owed to ex-highest bidders */
	mapping(address => uint) refunds;

	/* Bid function, shifts to push paradigm
	 * Must return true on successful send and/or bid, bidder
	 * reassignment
	 * Must return false on failure and allow people to
	 * retrieve their funds
	 */
	function bid() payable external returns(bool) {
		address potentialHighestBidder = msg.sender;
		uint potentialHighestBid = msg.value;

		if (potentialHighestBid <= highestBid) {
			refunds[potentialHighestBidder] += potentialHighestBid;
			return false;
		}

		//previous highest bidder get refund
		if (highestBidder != 0) {
			refunds[highestBidder] += highestBid;
		}

		highestBidder = potentialHighestBidder;
		highestBid = potentialHighestBid;

		return this.withdrawRefund();
	}

	/* New withdraw function, shifts to push paradigm */
	function withdrawRefund() external returns(bool) {
		uint refund = refunds[msg.sender];
		refunds[msg.sender] = 0;
		if (!msg.sender.send(refund)) {
			refunds[msg.sender] = refund;
			return false;
		}
		return true;

	}

	/* Allow users to check the amount they can withdraw */
	function getMyBalance() constant external returns(uint) {
		return refunds[msg.sender];
	}

	/* Give people their funds back */
	function () payable {
		revert();
	}
}
