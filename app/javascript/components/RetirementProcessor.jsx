import React from "react";
import consumer from "../channels/consumer";

class RetirementProcessor extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			users: props.users || [],
			selectedUserId: "",
			lastWorkingDate: "",
			retirementDate: "",
			taskId: null,
			status: "idle",
			progress: 0,
			totalItems: 0,
			processedItems: 0,
			result: null,
			error: null,
			isSubmitting: false,
		};
		this.subscription = null;
	}

	componentWillUnmount() {
		this.unsubscribe();
	}

	subscribe(taskId) {
		this.unsubscribe();

		this.subscription = consumer.subscriptions.create(
			{ channel: "TaskStatusChannel", task_id: taskId },
			{
				received: (data) => {
					this.handleStatusUpdate(data);
				},
				connected: () => {
					console.log("TaskStatusChannel connected");
				},
				disconnected: () => {
					console.log("TaskStatusChannel disconnected");
				},
			},
		);
	}

	unsubscribe() {
		if (this.subscription) {
			this.subscription.unsubscribe();
			this.subscription = null;
		}
	}

	handleStatusUpdate(data) {
		this.setState({
			status: data.status,
			progress: data.progress || 0,
			totalItems: data.total_items || 0,
			processedItems: data.processed_items || 0,
			result: data.result,
			error: data.error,
		});

		if (
			data.status === "completed" ||
			data.status === "failed" ||
			data.status === "cancelled"
		) {
			this.setState({ isSubmitting: false });
		}
	}

	handleUserChange = (e) => {
		this.setState({ selectedUserId: e.target.value });
	};

	handleLastWorkingDateChange = (e) => {
		this.setState({ lastWorkingDate: e.target.value });
	};

	handleRetirementDateChange = (e) => {
		this.setState({ retirementDate: e.target.value });
	};

	handleSubmit = async (e) => {
		e.preventDefault();

		const { selectedUserId, lastWorkingDate, retirementDate } = this.state;

		if (!selectedUserId || !lastWorkingDate || !retirementDate) {
			this.setState({ error: "すべての項目を入力してください" });
			return;
		}

		this.setState({
			isSubmitting: true,
			error: null,
			result: null,
			status: "pending",
			progress: 0,
		});

		try {
			const csrfToken = document
				.querySelector('meta[name="csrf-token"]')
				.getAttribute("content");

			const response = await fetch("/system_admin/retirement_processings", {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					"X-CSRF-Token": csrfToken,
				},
				body: JSON.stringify({
					user_id: selectedUserId,
					last_working_date: lastWorkingDate,
					retirement_date: retirementDate,
				}),
			});

			const data = await response.json();

			if (response.ok) {
				this.setState({
					taskId: data.task_id,
					status: data.status,
				});
				this.subscribe(data.task_id);
			} else {
				this.setState({
					error: data.error || "エラーが発生しました",
					isSubmitting: false,
				});
			}
		} catch (err) {
			this.setState({
				error: "ネットワークエラーが発生しました",
				isSubmitting: false,
			});
		}
	};

	handleCancel = async () => {
		const { taskId } = this.state;
		if (!taskId) return;

		try {
			const csrfToken = document
				.querySelector('meta[name="csrf-token"]')
				.getAttribute("content");

			await fetch(`/system_admin/retirement_processings/${taskId}/cancel`, {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					"X-CSRF-Token": csrfToken,
				},
			});
		} catch (err) {
			console.error("Cancel failed:", err);
		}
	};

	handleReset = () => {
		this.unsubscribe();
		this.setState({
			taskId: null,
			status: "idle",
			progress: 0,
			totalItems: 0,
			processedItems: 0,
			result: null,
			error: null,
			isSubmitting: false,
		});
	};

	renderProgressBar() {
		const { status, progress, totalItems, processedItems } = this.state;

		if (status === "idle") return null;

		const progressPercent = Math.min(progress, 100);
		const barClass =
			status === "failed"
				? "progress-bar progress-bar-danger"
				: status === "completed"
					? "progress-bar progress-bar-success"
					: "progress-bar progress-bar-striped active";

		return (
			<div className="progress-section" style={{ marginTop: "20px" }}>
				<div className="progress">
					<div
						className={barClass}
						role="progressbar"
						style={{ width: `${progressPercent}%` }}
						aria-valuenow={progressPercent}
						aria-valuemin="0"
						aria-valuemax="100"
					>
						{progressPercent}%
					</div>
				</div>
				<div
					className="progress-info"
					style={{ marginTop: "10px", textAlign: "center" }}
				>
					{status === "processing" && (
						<span>
							処理中: {processedItems} / {totalItems} 件
						</span>
					)}
					{status === "completed" && (
						<span className="text-success">完了しました</span>
					)}
					{status === "failed" && (
						<span className="text-danger">エラーが発生しました</span>
					)}
					{status === "cancelled" && (
						<span className="text-warning">キャンセルされました</span>
					)}
					{status === "pending" && <span>準備中...</span>}
				</div>
			</div>
		);
	}

	renderResult() {
		const { result, error } = this.state;

		if (error) {
			return (
				<div className="alert alert-danger" style={{ marginTop: "20px" }}>
					{error}
				</div>
			);
		}

		if (result) {
			return (
				<div className="alert alert-success" style={{ marginTop: "20px" }}>
					<strong>処理完了</strong>
					<ul style={{ marginTop: "10px", marginBottom: "0" }}>
						<li>対象者: {result.target_user_name}</li>
						<li>期間: {result.date_range}</li>
						<li>作成した日報数: {result.created_reports_count} 件</li>
					</ul>
				</div>
			);
		}

		return null;
	}

	render() {
		const {
			users,
			selectedUserId,
			lastWorkingDate,
			retirementDate,
			status,
			isSubmitting,
		} = this.state;

		const isProcessing = status === "processing" || status === "pending";
		const isCompleted =
			status === "completed" || status === "failed" || status === "cancelled";

		return (
			<div className="retirement-processor">
				<div className="panel panel-default">
					<div className="panel-heading">
						<h3 className="panel-title">休み一括登録</h3>
					</div>
					<div className="panel-body">
						<p className="text-muted" style={{ marginBottom: "20px" }}>
							開始日から終了日までの営業日を「休み 100%」で埋めます。
						</p>

						<form onSubmit={this.handleSubmit}>
							<div className="form-group">
								<label htmlFor="user_id">対象者</label>
								<select
									id="user_id"
									className="form-control"
									value={selectedUserId}
									onChange={this.handleUserChange}
									disabled={isSubmitting}
								>
									<option value="">選択してください</option>
									{users.map((user) => (
										<option key={user.id} value={user.id}>
											{user.name}
										</option>
									))}
								</select>
							</div>

							<div className="form-group">
								<label htmlFor="last_working_date">開始日</label>
								<input
									type="date"
									id="last_working_date"
									className="form-control"
									value={lastWorkingDate}
									onChange={this.handleLastWorkingDateChange}
									disabled={isSubmitting}
								/>
							</div>

							<div className="form-group">
								<label htmlFor="retirement_date">終了日</label>
								<input
									type="date"
									id="retirement_date"
									className="form-control"
									value={retirementDate}
									onChange={this.handleRetirementDateChange}
									disabled={isSubmitting}
								/>
							</div>

							<div className="form-actions" style={{ marginTop: "20px" }}>
								{!isProcessing && !isCompleted && (
									<button
										type="submit"
										className="btn btn-primary"
										disabled={isSubmitting}
									>
										{isSubmitting ? "処理開始中..." : "処理を開始"}
									</button>
								)}

								{isProcessing && (
									<button
										type="button"
										className="btn btn-warning"
										onClick={this.handleCancel}
									>
										キャンセル
									</button>
								)}

								{isCompleted && (
									<button
										type="button"
										className="btn btn-default"
										onClick={this.handleReset}
									>
										新しい処理を開始
									</button>
								)}
							</div>
						</form>

						{this.renderProgressBar()}
						{this.renderResult()}
					</div>
				</div>
			</div>
		);
	}
}

export default RetirementProcessor;
