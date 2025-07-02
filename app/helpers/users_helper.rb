module UsersHelper
  def destroy_or_revive_button(user)
    if user.available?
      form_with model: user, method: :delete do |f|
        f.submit('このユーザーを集計対象から外す',
                 class: 'btn btn-danger navbar-btn',
                 data: { confirm: 'このユーザーを集計対象から外します。よろしいですか？' })
      end
    else
      form_with model: user, url: revive_user_path(user), method: :patch do |f|
        f.submit('このユーザーを集計対象に加える',
                 class: 'btn btn-success navbar-btn',
                 data: { confirm: 'このユーザーを集計対象に加えます。よろしいですか？' })
      end
    end
  end

  def available_label(user)
    if user.available?
      content_tag(:span, t('user.status.available'), class: 'label label-success')
    else
      content_tag(:span, t('user.status.deleted'), class: 'label label-default')
    end
  end

  def role_labels(user)
    capture do
      concat content_tag(:span, t('user_role.administrator'), class: 'label label-primary') if user.administrator?
      concat content_tag(:span, t('user_role.director'), class: 'label label-primary') if user.director?
    end
  end
end
