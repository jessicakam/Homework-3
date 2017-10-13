pragma solidity ^0.4.15;

import "./AuctionInterface.sol";

/** @title BadAuction */
contract BadAuction is AuctionInterface {
	/* Bid function, vulnerable to attack
	 * Must return true on successful send and/or bid,
	 * bidder reassignment
	 * Must return false on failure and send people
	 * their funds back
	 */
	function bid() payable external returns (bool) {
		address potentialHighestBidder = msg.sender;
		uint potentialHighestBid = msg.value;

		if (potentialHighestBid <= highestBid) {
			potentialHighestBidder.transfer(potentialHighestBid);
			return false;
		}

		//attempt to give back funds to previous highest bidder
		if (highestBidder != 0) {
			if (!highestBidder.send(highestBid)) {
				potentialHighestBidder.transfer(potentialHighestBid);
				revert();
			}
		}

		highestBidder = potentialHighestBidder;
		highestBid = potentialHighestBid;
		return true;
	}

	/* Give people their funds back */
	function () payable {}
}
