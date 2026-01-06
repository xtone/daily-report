module SystemAdmin
  class DashboardController < SystemAdmin::BaseController
    def index
      @stats = {
        total_users: User.count,
        active_users: User.available.count,
        total_projects: Project.count,
        active_projects: Project.available.count,
        total_reports: Report.count,
        reports_this_month: Report.where(worked_in: Time.current.all_month).count,
        total_estimates: Estimate.count,
        total_bills: Bill.count
      }

      @recent_reports = Report.includes(:user)
                              .order(created_at: :desc)
                              .limit(10)

      @recent_users = User.order(created_at: :desc).limit(5)
    end
  end
end
