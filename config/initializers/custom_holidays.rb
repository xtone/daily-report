# load_custom実行前に、デフォルトのjpの定義をマージできるように、ここで先にloadしておく。
Holidays.on(Date.today, :jp)

Holidays.load_custom(Rails.root.join('config', 'holidays.yml'))