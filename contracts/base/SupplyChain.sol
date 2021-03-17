// SPDX-License-Identifier: MIT

pragma solidity >=0.6.00;

// Importing the necessary sol files
import "../core/Ownable.sol";
import "../access/roles/ConsumerRole.sol";
import "../access/roles/DistributorRole.sol";
import "../access/roles/FarmerRole.sol";
import "../access/roles/ProducerRole.sol";
import "../access/roles/InspectorRole.sol";

// Define a contract 'Supplychain'
contract SupplyChain is
    Ownable,
    FarmerRole,
    InspectorRole,
    DistributorRole,
    ConsumerRole,
    ProducerRole
{
    // Define a variable called 'sku' for Stock Keeping Unit (SKU)
    uint256 sku_cnt;

    // grape_upc -> grapeItem
    mapping(uint256 => GrapeItem) grapeItems;
    // juice_upc -> juiceItems
    mapping(uint256 => JuiceItem) juiceItems;
    // juice_upc -> grape_upc[]
    mapping(uint256 => uint256[]) juiceGrapes;

    // Define enum 'State' with the following values:
    enum GrapeState {
		Planted,
		Harvested,
		Audited,
		Processed
	}
    GrapeState constant defaultGrapeState = GrapeState.Planted;

    enum JuiceState {
        Created,
        Blended,
        Produced,
        Certified,
        Packed,
        ForSale,
        Purchased
    }
    JuiceState constant defaultJuiceState = JuiceState.Created;

    // Define a struct 'GrapeItem' with the following fields:
    struct GrapeItem {
        uint256 sku; // Stock Keeping Unit (SKU)
        uint256 upc; // Universal Product Code (UPC), generated by the Farmer, goes on the package, can be verified by the Consumer
        address ownerID; // Metamask-Ethereum address of the current owner as the product moves through stages
        address originFarmerID; // Metamask-Ethereum address of the Farmer
        string originFarmName; // Farmer Name
        string originFarmInformation; // Farmer Information
        string originFarmLatitude; // Farm Latitude
        string originFarmLongitude; // Farm Longitude
        string harvestNotes; // Harvest Notes
        string auditNotes; // Audit Notes
        GrapeState itemState; // Product State as represented in the enum above
    }

    // Define a struct 'JuiceItem' with the following fields:
    struct JuiceItem {
        uint256 sku; // Stock Keeping Unit (SKU)
        uint256 upc; // Universal Product Code (UPC), generated by the Producer, goes on the package, can be verified by the Consumer
        address ownerID; // Metamask-Ethereum address of the current owner as the product moves through stages
        uint256 productID; // Product ID potentially a combination of upc + sku
        string productNotes; // Product Notes
        uint256 productPrice; // Product Price
        address producerID; // Metamask-Ethereum address of the Producer
        address distributorID; // Metamask-Ethereum address of the Distributor
        address consumerID; // Metamask-Ethereum address of the Consumer
        string certifyNotes; // Certify Notes
        JuiceState itemState; // Product State as represented in the enum above
    }

    // Define events of Grapes
    event GrapePlanted(uint256 grapeUpc);
    event GrapeHarvested(uint256 grapeUpc);
    event GrapeAudited(uint256 grapeUpc);
    event GrapeProcessed(uint256 grapeUpc);

    // Define events of Juices
    event JuiceCreated(uint256 juiceUpc);
    event JuiceBlended(uint256 juiceUpc, uint256 grapeUpc);
    event JuiceProduced(uint256 juiceUpc);
    event JuicePacked(uint256 juiceUpc);
    event JuiceCertified(uint256 juiceUpc);
    event JuiceForSale(uint256 juiceUpc);
    event JuicePurchased(uint256 juiceUpc);

    // Define a modifer that verifies the Caller
    modifier verifyCaller(address _address) {
        require(msg.sender == _address, "verifyCaller: unexpected caller");
        _;
    }

    // Define a modifier that checks if the paid amount is sufficient to cover the price
    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price, "paidEnough");
        _;
    }

    // Define a modifier that checks the price and refunds the remaining balance
    modifier checkValue(uint256 _juiceUpc) {
        _;
        uint256 _price = juiceItems[_juiceUpc].productPrice;
        uint256 amountToReturn = msg.value - _price;
        payable(juiceItems[_juiceUpc].consumerID).transfer(amountToReturn);
    }

    // Define a modifier that checks if an grapeItem.state of a upc is Planted
    modifier isPlanted(uint256 _grapeUpc) {
        require(grapeItems[_grapeUpc].itemState == GrapeState.Planted, "not Planted");
        _;
    }

    // Define a modifier that checks if an grapeItem.state of a upc is Harvested
    modifier isHarvested(uint256 _grapeUpc) {
        require(grapeItems[_grapeUpc].itemState == GrapeState.Harvested, "not Harvested");
        _;
    }

    // Define a modifier that checks if an grapeItem.state of a upc is Audited
    modifier isAudited(uint256 _grapeUpc) {
        require(grapeItems[_grapeUpc].itemState == GrapeState.Audited, "not Audited");
        _;
    }

    // Define a modifier that checks if an grapeItem.state of a upc is Processed
    modifier isProcessed(uint256 _grapeUpc) {
        require(grapeItems[_grapeUpc].itemState == GrapeState.Processed, "not Processed");
        _;
    }

    // Define a modifier that checks if an juiceItem.state of a upc is Created
    modifier isCreated(uint256 _juiceUpc) {
        require(juiceItems[_juiceUpc].itemState == JuiceState.Created, "not Created");
        _;
    }

    // Define a modifier that checks if an juiceItem.state of a upc is Blended
    modifier isBlended(uint256 _juiceUpc) {
        require(juiceItems[_juiceUpc].itemState == JuiceState.Blended, "not Blended");
        _;
    }

    // Define a modifier that checks if an juiceItem.state of a upc is Produced
    modifier isProduced(uint256 _juiceUpc) {
        require(juiceItems[_juiceUpc].itemState == JuiceState.Produced, "not Produced");
        _;
    }

    // Define a modifier that checks if an juiceItem.state of a upc is Packed
    modifier isPacked(uint256 _juiceUpc) {
        require(juiceItems[_juiceUpc].itemState == JuiceState.Packed, "not Packed");
        _;
    }

    // Define a modifier that checks if an juiceItem.state of a upc is Certified
    modifier isCertified(uint256 _juiceUpc) {
        require(juiceItems[_juiceUpc].itemState == JuiceState.Certified, "not Certified");
        _;
    }

    // Define a modifier that checks if an juiceItem.state of a upc is ForSale
    modifier isForSale(uint256 _juiceUpc) {
        require(juiceItems[_juiceUpc].itemState == JuiceState.ForSale, "not ForSale");
        _;
    }

    // Define a modifier that checks if an juiceItem.state of a upc is Purchased
    modifier isPurchased(uint256 _juiceUpc) {
        require(juiceItems[_juiceUpc].itemState == JuiceState.Purchased, "not Purchased");
        _;
    }

    // In the constructor
    // set 'sku' to 1
    // set 'upc' to 1
    constructor() public payable {
        sku_cnt = 1;
    }

    // Transfer Eth to owner and terminate contract
    function kill() public onlyOwner {
        selfdestruct(payable(owner()));
    }

    // Define a function 'grapePlantItem' that allows a farmer to mark an item 'Planted'
    function grapePlantItem(
        uint256 _grapeUpc,
        address _originFarmerID,
        string calldata _originFarmName,
        string calldata _originFarmInformation,
        string calldata _originFarmLatitude,
        string calldata _originFarmLongitude
    ) public onlyFarmer {
        // Add the new item as part of Harvest
        grapeItems[_grapeUpc].sku = sku_cnt;
        grapeItems[_grapeUpc].upc = _grapeUpc;
        grapeItems[_grapeUpc].ownerID = msg.sender;
        grapeItems[_grapeUpc].originFarmerID = _originFarmerID;
        grapeItems[_grapeUpc].originFarmName = _originFarmName;
        grapeItems[_grapeUpc].originFarmInformation = _originFarmInformation;
        grapeItems[_grapeUpc].originFarmLatitude = _originFarmLatitude;
        grapeItems[_grapeUpc].originFarmLongitude = _originFarmLongitude;
        // Update state
        grapeItems[_grapeUpc].itemState = GrapeState.Planted;
        // Increment sku
        sku_cnt = sku_cnt + 1;
        // Emit the appropriate event
        emit GrapePlanted(_grapeUpc);
    }

    // Define a function 'grapeHarvestItem' that allows a farmer to mark an item 'Harvested'
    function grapeHarvestItem(uint256 _grapeUpc, string calldata _harvestNotes)
        public
        onlyFarmer
        isPlanted(_grapeUpc)
    {
        // Add the new item as part of Harvest
        grapeItems[_grapeUpc].ownerID = msg.sender;
        grapeItems[_grapeUpc].harvestNotes = _harvestNotes;
        // Update state
        grapeItems[_grapeUpc].itemState = GrapeState.Harvested;
        // Emit the appropriate event
        emit GrapeHarvested(_grapeUpc);
    }

    // Define a function 'grapeAuditItem' that allows a Inspector to mark an item 'Audited'
    function grapeAuditItem(uint256 _grapeUpc, string calldata _auditNotes)
        public
        onlyInspector
        isHarvested(_grapeUpc)
    {
        // Add the new item as part of Harvest
        grapeItems[_grapeUpc].auditNotes = _auditNotes;
        // Update state
        grapeItems[_grapeUpc].itemState = GrapeState.Audited;
        // Emit the appropriate event
        emit GrapeAudited(_grapeUpc);
    }

    // Define a function 'grapeProcessItem' that allows a farmer to mark an item 'Processed'
    function grapeProcessItem(uint256 _grapeUpc)
        public
        onlyFarmer
        isAudited(_grapeUpc)
        // verifyCaller(grapeItems[_grapeUpc].ownerID) // Call modifier to verify caller of this function
    {
        // Update the appropriate fields
        grapeItems[_grapeUpc].itemState = GrapeState.Processed;
        // Emit the appropriate event
        emit GrapeProcessed(_grapeUpc);
    }

    function juiceCreateItem(
        uint256 _grapeUpc,
        uint256 _productID
    ) public onlyProducer {
        // Add the new item as part of Harvest
        juiceItems[_grapeUpc].sku = sku_cnt;
        juiceItems[_grapeUpc].upc = _grapeUpc;
        juiceItems[_grapeUpc].productID = _productID;
        juiceItems[_grapeUpc].ownerID = msg.sender;
		// Update state
        juiceItems[_grapeUpc].itemState = JuiceState.Created;
        // Increment sku
        sku_cnt = sku_cnt + 1;
        // Emit the appropriate event
        emit JuiceCreated(_grapeUpc);
    }

    function juiceBlendItem(uint256 _juiceUpc, uint256 _grapeUpc)
        public
        onlyProducer
		verifyCaller(juiceItems[_juiceUpc].ownerID)
    {
		// Take ownership of grape
		grapeItems[_juiceUpc].ownerID = msg.sender;
		// Blend the '_juiceUpc' juice with '_grapeUpc' grape
		juiceGrapes[_juiceUpc].push(_grapeUpc);
		// Update state
        juiceItems[_juiceUpc].itemState = JuiceState.Blended;
        // Emit the appropriate event
        emit JuiceBlended(_juiceUpc, _grapeUpc);
    }

	function juiceProduceItem(uint256 _juiceUpc, string calldata _productNotes, uint256 _productPrice)
        public
        onlyProducer
		verifyCaller(juiceItems[_juiceUpc].ownerID)
		isBlended(_juiceUpc)
    {
        juiceItems[_juiceUpc].producerID = msg.sender;
        juiceItems[_juiceUpc].productNotes = _productNotes;
        juiceItems[_juiceUpc].productPrice = _productPrice;
		// Update state
        juiceItems[_juiceUpc].itemState = JuiceState.Produced;
        // Emit the appropriate event
        emit JuiceProduced(_juiceUpc);
    }

	function juiceCertifyItem(uint256 _juiceUpc, string calldata _certifyNotes)
        public
        onlyInspector
		isProduced(_juiceUpc)
    {
		juiceItems[_juiceUpc].certifyNotes = _certifyNotes;
		// Update state
        juiceItems[_juiceUpc].itemState = JuiceState.Certified;
        // Emit the appropriate event
        emit JuiceCertified(_juiceUpc);
    }

	function juicePackItem(uint256 _juiceUpc)
        public
        onlyProducer
		verifyCaller(grapeItems[_juiceUpc].ownerID)
		isCertified(_juiceUpc)
    {
		// Update state
        juiceItems[_juiceUpc].itemState = JuiceState.Packed;
        // Emit the appropriate event
        emit JuicePacked(_juiceUpc);
    }

	function juiceSellItem(uint256 _juiceUpc)
        public
        onlyDistributor
		isPacked(_juiceUpc)
    {
        juiceItems[_juiceUpc].distributorID = msg.sender;
		// Update state
        juiceItems[_juiceUpc].itemState = JuiceState.ForSale;
        // Emit the appropriate event
        emit JuiceForSale(_juiceUpc);
    }

	function juiceBuyItem(uint256 _juiceUpc)
        public
		payable
        onlyConsumer
		isForSale(_juiceUpc)
		paidEnough(juiceItems[_juiceUpc].productPrice)
		checkValue(_juiceUpc)
    {
		juiceItems[_juiceUpc].ownerID = msg.sender;
        juiceItems[_juiceUpc].consumerID = msg.sender;
		// Update state
        juiceItems[_juiceUpc].itemState = JuiceState.Purchased;
        // Transfer money to producer
        uint256 price = juiceItems[_juiceUpc].productPrice;
        payable(juiceItems[_juiceUpc].producerID).transfer(price);
        // Emit the appropriate event
	    emit JuicePurchased(_juiceUpc);
    }

    // Functions to fetch data
    function fetchJuiceItemBufferOne(uint256 _juiceUpc)
        external
        view
        returns (
			uint256 sku,
			uint256 upc,
			address ownerID,
			uint256 productID,
			string memory productNotes,
			uint256 productPrice,
			address producerID,
			address distributorID,
			address consumerID,
			string memory certifyNotes,
			uint256[] memory grapes,
			uint256 itemState
        )
    {
			sku			= juiceItems[_juiceUpc].sku;
			upc			= juiceItems[_juiceUpc].upc;
			ownerID		= juiceItems[_juiceUpc].ownerID;
			productID		= juiceItems[_juiceUpc].productID;
			productNotes	= juiceItems[_juiceUpc].productNotes;
			productPrice	= juiceItems[_juiceUpc].productPrice;
			producerID		= juiceItems[_juiceUpc].producerID;
			distributorID	= juiceItems[_juiceUpc].distributorID;
			consumerID		= juiceItems[_juiceUpc].consumerID;
			certifyNotes	= juiceItems[_juiceUpc].certifyNotes;
			grapes			= juiceGrapes[_juiceUpc];
			itemState		= uint256(juiceItems[_juiceUpc].itemState);
        return (
			sku,
			upc,
			ownerID,
			productID,
			productNotes,
			productPrice,
			producerID,
			distributorID,
			consumerID,
			certifyNotes,
			grapes,
			itemState
        );
    }

    // Functions to fetch data
    function fetchGrapeItemBufferOne(uint256 _grapeUpc)
        public
        view
        returns (
			uint256 sku,
			uint256 upc,
			address ownerID,
			address originFarmerID,
			string memory originFarmName,
			string memory originFarmInformation,
			string memory originFarmLatitude,
			string memory originFarmLongitude
        )
    {
			sku			= grapeItems[_grapeUpc].sku;
			upc			= grapeItems[_grapeUpc].upc;
			ownerID			= grapeItems[_grapeUpc].ownerID;
			originFarmerID	= grapeItems[_grapeUpc].originFarmerID;
			originFarmName	= grapeItems[_grapeUpc].originFarmName;
			originFarmInformation	= grapeItems[_grapeUpc].originFarmInformation;
			originFarmLatitude		= grapeItems[_grapeUpc].originFarmLatitude;
			originFarmLongitude		= grapeItems[_grapeUpc].originFarmLongitude;
        return (
			sku,
			upc,
			ownerID,
			originFarmerID,
			originFarmName,
			originFarmInformation,
			originFarmLatitude,
			originFarmLongitude
        );
    }


    // Functions to fetch data
    function fetchGrapeItemBufferTwo(uint256 _grapeUpc)
        public
        view
        returns (
			string memory harvestNotes,
			string memory auditNotes,
			uint256 itemState
        )
    {
			harvestNotes	= grapeItems[_grapeUpc].harvestNotes;
			auditNotes		= grapeItems[_grapeUpc].auditNotes;
			itemState 		= uint256(grapeItems[_grapeUpc].itemState);
        return (
			harvestNotes,
			auditNotes,
			itemState
        );
    }

}
