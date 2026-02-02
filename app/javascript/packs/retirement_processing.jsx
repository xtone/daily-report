import React from "react";
import { createRoot } from "react-dom/client";
import RetirementProcessor from "../components/RetirementProcessor";

document.addEventListener("turbo:load", () => {
	const container = document.getElementById("retirement-processor-container");
	if (container) {
		const usersData = container.dataset.users;
		const users = usersData ? JSON.parse(usersData) : [];

		const root = createRoot(container);
		root.render(<RetirementProcessor users={users} />);
	}
});
