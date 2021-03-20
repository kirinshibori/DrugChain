module.exports = {
	publicPath: process.env.NODE_ENV === 'production'
	? '/kirinshibori/DrugChainUI'
	: '/',
  "transpileDependencies": [
    "vuetify"
  ]
}

