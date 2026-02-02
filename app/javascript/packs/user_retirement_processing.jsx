import React from "react";
import { createRoot } from "react-dom/client";
import RetirementProcessorModal from "../components/RetirementProcessorModal";

// DOMContentLoaded または turbo:load でマウント
const mountRetirementProcessor = () => {
	const container = document.getElementById("retirement-processor-container");
	if (container) {
		const userId = container.dataset.userId;
		const userName = container.dataset.userName;

		if (userId && userName) {
			const root = createRoot(container);
			root.render(
				<RetirementProcessorModal
					userId={parseInt(userId, 10)}
					userName={userName}
				/>,
			);
		}
	}
};

// turbo:load イベントをリッスン（Turbolinks/Turbo対応）
document.addEventListener("turbo:load", mountRetirementProcessor);

// DOMContentLoaded でもマウント（Turboがない場合のフォールバック）
document.addEventListener("DOMContentLoaded", mountRetirementProcessor);

// すでにDOMが読み込まれている場合
if (
	document.readyState === "complete" ||
	document.readyState === "interactive"
) {
	mountRetirementProcessor();
}
