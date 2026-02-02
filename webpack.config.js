const path = require("path");
const webpack = require("webpack");

const isProduction = process.env.NODE_ENV === "production";

module.exports = {
	mode: isProduction ? "production" : "development",

	entry: {
		application: "./app/javascript/application.js",
		admin: "./app/javascript/packs/admin.jsx",
		bills: "./app/javascript/packs/bills.jsx",
		estimates: "./app/javascript/packs/estimates.jsx",
		forms: "./app/javascript/packs/forms.jsx",
		project_list: "./app/javascript/packs/project_list.jsx",
		project_members: "./app/javascript/packs/project_members.jsx",
		reports: "./app/javascript/packs/reports.jsx",
		reports_summary: "./app/javascript/packs/reports_summary.jsx",
		retirement_processing: "./app/javascript/packs/retirement_processing.jsx",
		unsubmitted: "./app/javascript/packs/unsubmitted.jsx",
		user_retirement_processing:
			"./app/javascript/packs/user_retirement_processing.jsx",
	},

	output: {
		path: path.resolve(__dirname, "app/assets/builds"),
		filename: "[name].js",
		clean: true,
	},

	resolve: {
		extensions: [".js", ".jsx"],
	},

	module: {
		rules: [
			{
				test: /\.jsx?$/,
				exclude: /node_modules/,
				use: {
					loader: "babel-loader",
					options: {
						presets: ["@babel/preset-env", "@babel/preset-react"],
						plugins: ["@babel/plugin-proposal-class-properties"],
					},
				},
			},
		],
	},

	plugins: [
		new webpack.DefinePlugin({
			"process.env.NODE_ENV": JSON.stringify(
				process.env.NODE_ENV || "development",
			),
			"process.env.RAILS_ENV": JSON.stringify(
				process.env.RAILS_ENV || "development",
			),
		}),
	],

	devtool: isProduction ? false : "source-map",

	optimization: {
		minimize: isProduction,
	},
};
