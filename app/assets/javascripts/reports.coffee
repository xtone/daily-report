# 日報一覧ダウンロードフォームに機能を追加する
class Report
  alertNode = null

  constructor: (params) ->
    form = document.getElementById(params.form)
    submitBtn = form.getElementsByClassName('btn')[0]
    alerts = document.getElementsByClassName('alert')
    if alerts.length != 0
      alertNode = alerts[0]

    for select in form.getElementsByTagName('select')
      select.addEventListener('change', (event) =>
        @enable(submitBtn)
        @removeAlert()
      )

  # ダウンロードボタンが使用不能になっていたら、その状態を解除する
  enable: (submitBtn) ->
    submitBtn.removeAttribute('disabled')

  # 警告が出ていたら、それを消去する
  removeAlert: ->
    if alertNode?
      alertNode.parentNode.removeChild(alertNode)
      alertNode = null



class ReportSummary
  constructor: (params) ->
    @renderForm = document.getElementById(params.renderForm)
    @downloadForm = document.getElementById(params.downloadForm)

    @downloadForm.addEventListener('submit', (event) =>
      event.preventDefault()
      @download(event.target)
    )
    for button in @renderForm.getElementsByClassName('input-group-addon')
      button.addEventListener('click', (event) =>
        @enable(@downloadForm)
      )

  download: (form) ->
    attrs = []
    inputs = @renderForm.getElementsByClassName('date-input')
    for i in [0..inputs.length-1]
      input = inputs[i]
      attrs.push(input.name + '=' + input.value)
    window.location.href = form.action + '?' + attrs.join('&')

  enable: (form) ->
    for button in form.getElementsByClassName('btn')
      button.removeAttribute('disabled')

window.Report = Report
window.ReportSummary = ReportSummary
