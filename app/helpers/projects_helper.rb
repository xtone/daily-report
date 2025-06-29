module ProjectsHelper
  def display_status(project)
    if project.displayed?
      tag.span(class: 'glyphicon glyphicon-ok text-success')
    else
      tag.span(class: 'glyphicon glyphicon-remove text-danger')
    end
  end

  # @param [Symbol] model
  # @param [Symbol] column
  # @param [String] order_by
  def index_header(model, column, order_by: 'name_reading_asc', active: nil)
    label = t("#{model}.#{column}")
    opts = {}
    opts[:active] = true if active.present?
    if order_by == "#{column}_asc"
      link_to "#{label} ▼", opts.merge(order: "#{column}_desc"), { title: "#{label}の降順にソート" }
    else
      link_to "#{label} ▲", opts.merge(order: "#{column}_asc"), { title: "#{label}の昇順にソート" }
    end
  end
end
