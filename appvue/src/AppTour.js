
export function tour_steps() {
	return [
		{
			target: "#title-dapp",
			header: {
				title: "Get Started",
			},
			content: `Discover <strong>DrugChain Tour</strong>!`,
		},

		{
			target: "#btn-wallet",
			header: {
				title: "Configure your Wallet",
			},
			content: `Click here to <strong>Configure</strong> your wallet!`,
		},

		{
			target: "#btn-github",
			header: {
				title: "Source Code",
			},
			content: `Click here to check the <strong>source code</strong>!`,
		},
		{
			target: "#b-farmer-subtitle", // We're using document.querySelector() under the hood
			header: {
				title: "Details about",
			},
			params: {
				enableScrolling: false,
			},
			content: `Click here<br>to check details<br>about this Supplier!`,
		},
		{
			target: "#b-farmer-item-0",
			content: "Click here<br>to <strong>Source raw materials</strong>!",
			params: {
				enableScrolling: false
			},

		},
		{
			target: "#b-farmer-item-1",
			content:
				"Click here<br>to <strong>Produce ingredients</strong><br>Note that is<br>disabled until<br>you have a sourced Ingredient!",
			params: {
				enableScrolling: false
			},

		},
		{
			target: "#b-farmer-item-2",
			content:
				"Click here<br>to <strong>Process ingredients</strong><br>Note that is<br>disabled until<br>you have a audited Ingredient!",
			params: {
				enableScrolling: false
			},

		},
	];
}
