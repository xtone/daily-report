module ProjectsHelper
  def display_status(project)
    if project.displayed?
      tag(:span, class: 'glyphicon glyphicon-ok text-success')
    else
      tag(:span, class: 'glyphicon glyphicon-remove text-danger')
    end
  end
end
