class Report
  constructor: (params) ->
    form = document.getElementById(params.form)
    for select in form.getElementsByTagName('select')
      select.addEventListener('change', (event) =>
        @enable(form)
      )

  enable: (form) ->
    form.getElementsByClassName('btn')[0].removeAttribute('disabled')



class ReportSummary
  constructor: (params) ->
    @renderForm = document.getElementById(params.renderForm)
    @downloadForm = document.getElementById(params.downloadForm)

    @downloadForm.addEventListener('submit', (event) =>
      event.preventDefault()
      @download(event.target)
    )
    for select in @renderForm.getElementsByTagName('select')
      select.addEventListener('change', (event) =>
        @enable(@downloadForm)
      )

  download: (form) ->
    attrs = []
    selects = @renderForm.getElementsByTagName('select')
    for i in [0..selects.length-1]
      select = selects[i]
      attrs.push(select.name + '=' + select.value)
    window.location.href = form.action + '?' + attrs.join('&')

  enable: (form) ->
    form.getElementsByClassName('btn')[0].removeAttribute('disabled')

window.Report = Report
window.ReportSummary = ReportSummary
