class CsvDownload
  constructor: ->
    # Firefoxで起きる、リロード後もdisabled属性が残り続ける問題への対処
    for input in document.querySelectorAll('input[type="submit"]')
      input.removeAttribute('disabled')

window.CsvDownload = CsvDownload
