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
