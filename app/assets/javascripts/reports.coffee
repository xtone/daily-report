class ReportSummary
  constructor: (params) ->
    @renderForm = document.getElementById(params.renderForm)
    document.getElementById(params.downloadForm).addEventListener('submit', (event) =>
      event.preventDefault()
      @download(event.target)
    )

  download: (form) ->
    attrs = []
    selects = @renderForm.getElementsByTagName('select')
    for i in [0..selects.length-1]
      select = selects[i]
      attrs.push(select.name + '=' + select.value)
    window.location.href = form.action + '?' + attrs.join('&')

window.ReportSummary = ReportSummary