module ApplicationHelper
  def error_message(resource, attribute)
    return nil unless resource.errors[attribute].present?
    content_tag :div, class: 'alert alert-danger' do
      concat safe_join(resource.errors.full_messages_for(attribute), '<br />'.html_safe)
    end
  end

  def global_header
    return nil unless user_signed_in?
    capture do
      concat navbar
      concat "\n"
      concat signout_form
    end
  end

  def navbar
    content_tag(:ul, class: 'nav navbar-nav') do
      concat(content_tag(:li, class: current_page?(root_path) ? 'active' : nil) do
        link_to '日報入力', root_path
      end)
      concat(content_tag(:li, class: current_page?(settings_projects_path) ? 'active' : nil) do
        link_to 'プロジェクト設定', settings_projects_path
      end)
      if current_user.user_roles.present?
        concat(content_tag(:li, class: current_page?(admin_root_path) ? 'active' : nil) do
          link_to '管理画面', admin_root_path
        end)
      end
    end
  end

  def signout_form
    form_tag destroy_user_session_path, method: 'delete', class: 'navbar-form navbar-right' do
      submit_tag 'ログアウト', class: 'btn btn-default'
    end
  end
end
