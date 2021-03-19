const { before } = require("lodash");

const SupplyChain = artifacts.require("SupplyChain");
const truffleAssert = require('truffle-assertions');

var accounts;
var owner;

contract('SupplyChain', (accs) => {
	accounts = accs;
	owner = accounts[0];
});

// Accounts
let acc_owner = accounts[0];	// Contract Owner account
let acc_supplier_0 = accounts[1];	// Supplier account
let acc_manufacturer_0 = accounts[2];	// Manufacturer account
let acc_inspector_0 = accounts[3];	// Inspector account
let acc_distributor_0 = accounts[4];	// Distributor account
let acc_retailer_0 = accounts[5];	// Retailer account

let instance = null;

describe('Programmatic usage suite', function () {

	describe('#index', function () {

		it('can the Supplier secure sources of raw materials', async function () {
			this.timeout(20000);

			instance = await SupplyChain.deployed();
			await instance.addSupplier(acc_supplier_0, { from: acc_owner });
			await instance.addManufacturer(acc_manufacturer_0, { from: acc_owner });
			await instance.addInspector(acc_inspector_0, { from: acc_owner });
			await instance.addDistributor(acc_distributor_0, { from: acc_owner });
			await instance.addRetailer(acc_retailer_0, { from: acc_owner });

			let upc = 1;
			let ownerID = acc_supplier_0;
			let originSupplierID = acc_supplier_0;
			let originSupplierName = "GlaxoSmithKline";
			let originSupplierInformation = "38 Quality Rd, Singapore 618809";
			let originSupplierLatitude = "1.335232";
			let originSupplierLongitude = "103.6924815";
			let produceNotes = "";
			let auditNotes = "";
			let itemState = 0;

			// Source raw material
			let source = await instance.ingredientSourceItem(upc,
				originSupplierID,
				originSupplierName,
				originSupplierInformation,
				originSupplierLatitude,
				originSupplierLongitude,
				{ from: acc_supplier_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchIngredientItemBufferOne.call(upc);
			let res2 = await instance.fetchIngredientItemBufferTwo.call(upc);

			// Check results
			assert.equal(res1.upc, upc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.originSupplierID, originSupplierID, 'Error: Missing or Invalid originSupplierID');
			assert.equal(res1.originSupplierName, originSupplierName, 'Error: Missing or Invalid originSupplierName');
			assert.equal(res1.originSupplierInformation, originSupplierInformation, 'Error: Missing or Invalid originSupplierInformation');
			assert.equal(res1.originSupplierLatitude, originSupplierLatitude, 'Error: Missing or Invalid originSupplierLatitude');
			assert.equal(res1.originSupplierLongitude, originSupplierLongitude, 'Error: Missing or Invalid originSupplierLongitude');
			assert.equal(res2.produceNotes, produceNotes, 'Error: Missing or Invalid produceNotes');
			assert.equal(res2.auditNotes, auditNotes, 'Error: Missing or Invalid auditNotes');
			assert.equal(res2.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(source, 'IngredientSourced');
		});


		it('can the Supplier produce a pharmaceutical ingredient', async function () {
			this.timeout(20000);
			let upc = 1;
			let ownerID = acc_supplier_0;
			let originSupplierID = acc_supplier_0;
			let produceNotes = "Paracetamol 500mg";
			let itemState = 1;
			let produce = await instance.ingredientProduceItem(upc, produceNotes, { from: acc_supplier_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchIngredientItemBufferOne.call(upc);
			let res2 = await instance.fetchIngredientItemBufferTwo.call(upc);

			assert.equal(res1.upc, upc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.originSupplierID, originSupplierID, 'Error: Missing or Invalid originSupplierID');
			assert.equal(res2.produceNotes, produceNotes, 'Error: Missing or Invalid produceNotes');
			assert.equal(res2.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(produce, 'IngredientProduced');		});

		it('can the Inspector audit an ingredient', async function () {
			this.timeout(20000);
			let upc = 1;
			let ownerID = acc_supplier_0;
			let originSupplierID = acc_supplier_0;
			let auditNotes = "ISO9002 audit passed";
			let itemState = 2;
			let audited = await instance.ingredientAuditItem(upc, auditNotes, { from: acc_inspector_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchIngredientItemBufferOne.call(upc);
			let res2 = await instance.fetchIngredientItemBufferTwo.call(upc);

			assert.equal(res1.upc, upc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.originSupplierID, originSupplierID, 'Error: Missing or Invalid originSupplierID');
			assert.equal(res2.auditNotes, auditNotes, 'Error: Missing or Invalid auditNotes');
			assert.equal(res2.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(audited, 'IngredientAudited');		});

		it('can the Supplier process an ingredient', async function () {
			this.timeout(20000);
			let upc = 1;
			let ownerID = acc_supplier_0;
			let originSupplierID = acc_supplier_0;
			let itemState = 3;
			let processed = await instance.ingredientProcessItem(upc, { from: acc_supplier_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchIngredientItemBufferOne.call(upc);
			let res2 = await instance.fetchIngredientItemBufferTwo.call(upc);

			assert.equal(res1.upc, upc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.originSupplierID, originSupplierID, 'Error: Missing or Invalid originSupplierID');
			assert.equal(res2.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(processed, 'IngredientProcessed');
		});

		it('can the Manufacturer create a Drug', async function () {
			this.timeout(20000);
			let upc = 1;
			let productID = 1001;
			let ownerID = acc_manufacturer_0;
			let itemState = 0;
			let created = await instance.drugCreateItem(upc, productID, { from: acc_manufacturer_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchDrugItemBufferOne.call(upc);

			assert.equal(res1.upc, upc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.productID, productID, 'Error: Missing or Invalid productID');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(created, 'DrugCreated');
		});

		it('can the Manufacturer refine a drug', async function () {
			this.timeout(20000);
			let drugUpc = 1;
			let ingredientUpc = 1;
			let productID = 1001;
			let ownerID = acc_manufacturer_0;
			let itemState = 1;
			let refined = await instance.drugRefineItem(drugUpc, ingredientUpc, { from: acc_manufacturer_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchDrugItemBufferOne.call(drugUpc);

			assert.equal(res1.upc, drugUpc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.productID, productID, 'Error: Missing or Invalid productID');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			assert.equal(res1.ingredient[0], ingredientUpc, 'Error: Invalid item ingredientUpc');
			truffleAssert.eventEmitted(refined, 'DrugRefined');
		});

		it('can the Manufacturer manufacture a Drug', async function () {
			this.timeout(20000);
			let drugUpc = 1;
			let productNotes = "Panadol 500mg tablets";
			let productPrice = 26;
			let ownerID = acc_manufacturer_0;
			let itemState = 2;
			let manufactured = await instance.drugManufactureItem(drugUpc, productNotes, productPrice, { from: acc_manufacturer_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchDrugItemBufferOne.call(drugUpc);

			assert.equal(res1.upc, drugUpc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.productNotes, productNotes, 'Error: Missing or Invalid productNotes');
			assert.equal(res1.productPrice, productPrice, 'Error: Missing or Invalid productPrice');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(manufactured, 'DrugManufactured');
		});

		it('can the Inspector certify a Drug', async function () {
			this.timeout(20000);
			let drugUpc = 1;
			let certifyNotes = "ISO9002 Certified";
			let ownerID = acc_manufacturer_0;
			let itemState = 3;
			let certified = await instance.drugCertifyItem(drugUpc, certifyNotes, { from: acc_inspector_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchDrugItemBufferOne.call(drugUpc);

			assert.equal(res1.upc, drugUpc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.certifyNotes, certifyNotes, 'Error: Missing or Invalid certifyNotes');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(certified, 'DrugCertified');
		});

		it('can the Manufacturer pack a Drug', async function () {
			this.timeout(20000);
			let drugUpc = 1;
			let ownerID = acc_manufacturer_0;
			let itemState = 4;
			let packed = await instance.drugPackItem(drugUpc, { from: acc_manufacturer_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchDrugItemBufferOne.call(drugUpc);

			assert.equal(res1.upc, drugUpc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(packed, 'DrugPacked');
		});

		it('can the Distributor distribute a Drug', async function () {
			this.timeout(20000);
			let drugUpc = 1;
			let ownerID = acc_manufacturer_0;
			let itemState = 5;
			let fordistribution = await instance.drugDistributeItem(drugUpc, { from: acc_distributor_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchDrugItemBufferOne.call(drugUpc);

			assert.equal(res1.upc, drugUpc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(fordistribution, 'DrugDistributed');
		});

		it('can the Retailer purchase a Drug', async function () {
			this.timeout(20000);
			let drugUpc = 1;
			let ownerID = acc_retailer_0;
			let itemState = 6;
			let res1 = await instance.fetchDrugItemBufferOne.call(drugUpc);
			let purchased = await instance.drugPurchaseItem(drugUpc, { from: acc_retailer_0, value: res1.productPrice });

			// Read the result from blockchain
			res1 = await instance.fetchDrugItemBufferOne.call(drugUpc);

			assert.equal(res1.upc, drugUpc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(purchased, 'DrugPurchased');
		});
	});
});