module UsersHelper
  def available_label(user)
    if user.available?
      content_tag(:span, t('user.status.available'), class: 'label label-success')
    else
      content_tag(:span, t('user.status.deleted'), class: 'label label-default')
    end
  end

  def role_labels(user)
    capture do
      if user.administrator?
        concat content_tag(:span, t('user_role.administrator'), class: 'label label-primary')
      end
      if user.general_affairs?
        concat content_tag(:span, t('user_role.general_affairs'), class: 'label label-primary')
      end
      if user.director?
        concat content_tag(:span, t('user_role.director'), class: 'label label-primary')
      end
    end
  end
end
