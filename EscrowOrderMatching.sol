// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EscrowOrderMatching {

    struct Order {
        uint256 orderId;
        address seller;
        address buyer;
        uint256 amount;
        uint256 price;
        bool fulfilled;
        bool sellerConfirmed;
        bool buyerConfirmed;
    }

    uint256 public orderCounter;
    mapping(uint256 => Order) public orders;
    mapping(address => uint256[]) public sellerOrders;
    mapping(address => uint256[]) public buyerOrders;

    event OrderCreated(uint256 orderId, address indexed seller, uint256 amount, uint256 price);
    event OrderMatched(uint256 orderId, address indexed buyer);
    event OrderConfirmed(uint256 orderId, address indexed confirmer);
    event OrderCompleted(uint256 orderId);

    modifier onlySeller(uint256 orderId) {
        require(orders[orderId].seller == msg.sender, "Only seller can call this function");
        _;
    }

    modifier onlyBuyer(uint256 orderId) {
        require(orders[orderId].buyer == msg.sender, "Only buyer can call this function");
        _;
    }

    function createOrder(uint256 amount, uint256 price) external {
        orderCounter++;
        uint256 orderId = orderCounter;
        orders[orderId] = Order(orderId, msg.sender, address(0), amount, price, false, false, false);
        sellerOrders[msg.sender].push(orderId);

        emit OrderCreated(orderId, msg.sender, amount, price);
    }

    function matchOrder(uint256 orderId) external payable {
        Order storage order = orders[orderId];
        require(order.seller != address(0), "Order does not exist");
        require(order.buyer == address(0), "Order already matched");
        require(msg.value == order.amount * order.price, "Incorrect value sent");

        order.buyer = msg.sender;
        buyerOrders[msg.sender].push(orderId);

        emit OrderMatched(orderId, msg.sender);
    }

    function confirmOrder(uint256 orderId) external {
        Order storage order = orders[orderId];
        require(order.buyer != address(0), "Order not matched yet");

        if (msg.sender == order.seller) {
            order.sellerConfirmed = true;
        } else if (msg.sender == order.buyer) {
            order.buyerConfirmed = true;
        } else {
            revert("Only buyer or seller can confirm");
        }

        emit OrderConfirmed(orderId, msg.sender);

        // If both parties confirmed, mark order as fulfilled and release funds
        if (order.sellerConfirmed && order.buyerConfirmed) {
            completeOrder(orderId);
        }
    }

    function completeOrder(uint256 orderId) internal {
        Order storage order = orders[orderId];
        require(order.sellerConfirmed && order.buyerConfirmed, "Both parties need to confirm");

        // Transfer funds to the seller
        payable(order.seller).transfer(order.amount * order.price);
        order.fulfilled = true;

        emit OrderCompleted(orderId);
    }

    function cancelOrder(uint256 orderId) external onlySeller(orderId) {
        Order storage order = orders[orderId];
        require(order.buyer == address(0), "Order has already been matched");

        delete orders[orderId];
    }

    function disputeOrder(uint256 orderId) external onlyBuyer(orderId) {
        Order storage order = orders[orderId];
        require(order.buyerConfirmed == false, "Order already confirmed by buyer");

        // Custom dispute resolution logic can be added here

        delete orders[orderId];
    }
}
