module ApplicationHelper
  # ActiveRecordのエラーメッセージを表示する
  # @param [ActiveRecord] resource
  # @param [Symbol] attribute
  def error_message(resource, attribute)
    return nil unless resource.errors[attribute].present?
    content_tag :div, class: 'alert alert-danger' do
      concat safe_join(resource.errors.full_messages_for(attribute), '<br />'.html_safe)
    end
  end

  def render_flash_message
    capture do
      concat tag.div(flash[:alert], class: 'alert alert-danger') if flash[:alert].present?
      concat tag.div(flash[:notice], class: 'alert alert-success') if flash[:notice].present?
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
      concat(content_tag(:li, class: current_page?(settings_password_path) ? 'active' : nil) do
        link_to 'パスワード変更', settings_password_path
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

  def date_select_ja(object_name, method, options = {}, html_options = {})
    date_select(
      object_name,
      method,
      {
        use_month_numbers: true,
        start_year: 2011,
        end_year: Time.zone.now.year,
        date_separator: '%s'
      }.merge(options),
      { class: 'form-control' }.merge(html_options)
    ) % ['年', '月'] + '日'
  end

  def text_with_ruby(text, ruby)
    tag.ruby do
      concat text
      concat tag.rp('（')
      concat tag.rt(ruby)
      concat tag.rp('）')
    end
  end
end
