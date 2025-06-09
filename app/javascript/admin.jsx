import React from 'react';
import ReactDOM from 'react-dom';
import DatePicker from './components/DatePicker';

// CsvDownload機能のReactコンポーネント
class CsvDownloadManager extends React.Component {
  componentDidMount() {
    // Firefoxで起きる、リロード後もdisabled属性が残り続ける問題への対処
    this.removeDisabledAttributes();
  }

  removeDisabledAttributes() {
    const submitInputs = document.querySelectorAll('input[type="submit"]');
    submitInputs.forEach(input => {
      input.removeAttribute('disabled');
    });
  }

  render() {
    // このコンポーネントは副作用のみを持ち、UIは描画しない
    return null;
  }
}

// Report機能のReactコンポーネント（既存のCoffeeScriptから移植）
class ReportDownloadForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      alertVisible: false
    };
    this.handleSelectChange = this.handleSelectChange.bind(this);
  }

  componentDidMount() {
    // 既存のアラートがあるかチェック
    const alerts = document.getElementsByClassName('alert');
    if (alerts.length > 0) {
      this.setState({ alertVisible: true });
    }

    // selectタグにイベントリスナーを追加
    const form = document.getElementById(this.props.formId);
    if (form) {
      const selects = form.getElementsByTagName('select');
      Array.from(selects).forEach(select => {
        select.addEventListener('change', this.handleSelectChange);
      });
    }
  }

  componentWillUnmount() {
    // イベントリスナーをクリーンアップ
    const form = document.getElementById(this.props.formId);
    if (form) {
      const selects = form.getElementsByTagName('select');
      Array.from(selects).forEach(select => {
        select.removeEventListener('change', this.handleSelectChange);
      });
    }
  }

  handleSelectChange() {
    this.enableSubmitButton();
    this.removeAlert();
  }

  enableSubmitButton() {
    const form = document.getElementById(this.props.formId);
    if (form) {
      const submitBtn = form.getElementsByClassName('btn')[0];
      if (submitBtn) {
        submitBtn.removeAttribute('disabled');
      }
    }
  }

  removeAlert() {
    const alerts = document.getElementsByClassName('alert');
    if (alerts.length > 0) {
      const alertNode = alerts[0];
      if (alertNode && alertNode.parentNode) {
        alertNode.parentNode.removeChild(alertNode);
        this.setState({ alertVisible: false });
      }
    }
  }

  render() {
    // このコンポーネントは副作用のみを持ち、UIは描画しない
    return null;
  }
}

// CSV出力用の日付ピッカーコンポーネント
class CsvDatePicker extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      startDate: this.props.initialStartDate || '',
      endDate: this.props.initialEndDate || ''
    };
    this.handleStartDateChange = this.handleStartDateChange.bind(this);
    this.handleEndDateChange = this.handleEndDateChange.bind(this);
  }

  handleStartDateChange(dateValue) {
    this.setState({ startDate: dateValue });
    
    // 元のinputフィールドの値も更新
    const originalInput = document.querySelector('input[name="reports[start]"]');
    if (originalInput) {
      originalInput.value = dateValue;
    }
  }

  handleEndDateChange(dateValue) {
    this.setState({ endDate: dateValue });
    
    // 元のinputフィールドの値も更新
    const originalInput = document.querySelector('input[name="reports[end]"]');
    if (originalInput) {
      originalInput.value = dateValue;
    }
  }

  render() {
    return (
      <div className="form-group">
        <DatePicker
          name="reports[start]"
          placeholder="集計開始日"
          value={this.state.startDate}
          onChange={this.handleStartDateChange}
        />
        <span className="separator"> 〜 </span>
        <DatePicker
          name="reports[end]"
          placeholder="集計終了日"
          value={this.state.endDate}
          onChange={this.handleEndDateChange}
        />
        <span> の日報を</span>
      </div>
    );
  }
}

// CSRFトークンを取得
const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

// Turbolinksイベントでコンポーネントをマウント
document.addEventListener('turbolinks:load', () => {
  // CsvDownloadManagerをマウント
  const csvContainer = document.createElement('div');
  csvContainer.id = 'csv-download-manager';
  document.body.appendChild(csvContainer);
  
  ReactDOM.render(<CsvDownloadManager />, csvContainer);

  // ReportDownloadFormをマウント（reportsフォームが存在する場合）
  const reportsForm = document.getElementById('reports');
  if (reportsForm) {
    const reportContainer = document.createElement('div');
    reportContainer.id = 'report-download-manager';
    document.body.appendChild(reportContainer);
    
    ReactDOM.render(<ReportDownloadForm formId="reports" />, reportContainer);
  }

  // CSV出力の日付ピッカーをReact化
  const csvForm = document.getElementById('reports');
  if (csvForm) {
    const formGroup = csvForm.querySelector('.form-group');
    const startInput = formGroup.querySelector('input[name="reports[start]"]');
    const endInput = formGroup.querySelector('input[name="reports[end]"]');
    
    if (startInput && endInput && !formGroup.dataset.reactDatePickerMounted) {
      // 元の値を取得
      const initialStartDate = startInput.value;
      const initialEndDate = endInput.value;
      
      // Reactコンポーネント用のコンテナを作成
      const reactContainer = document.createElement('div');
      formGroup.parentNode.insertBefore(reactContainer, formGroup);
      
      // 元のフォームグループを非表示にする
      formGroup.style.display = 'none';
      formGroup.dataset.reactDatePickerMounted = 'true';
      
      ReactDOM.render(
        <CsvDatePicker
          initialStartDate={initialStartDate}
          initialEndDate={initialEndDate}
        />,
        reactContainer
      );
    }
  }
});

// Turbolinksページ遷移前にコンポーネントをアンマウント
document.addEventListener('turbolinks:before-render', () => {
  const csvContainer = document.getElementById('csv-download-manager');
  if (csvContainer) {
    ReactDOM.unmountComponentAtNode(csvContainer);
    csvContainer.remove();
  }

  const reportContainer = document.getElementById('report-download-manager');
  if (reportContainer) {
    ReactDOM.unmountComponentAtNode(reportContainer);
    reportContainer.remove();
  }

  // CSV日付ピッカーのクリーンアップ
  const reactDatePickerElements = document.querySelectorAll('[data-react-date-picker-mounted="true"]');
  reactDatePickerElements.forEach(element => {
    const reactContainer = element.previousSibling;
    if (reactContainer && reactContainer.nodeType === Node.ELEMENT_NODE) {
      ReactDOM.unmountComponentAtNode(reactContainer);
      reactContainer.remove();
    }
    element.style.display = '';
    delete element.dataset.reactDatePickerMounted;
  });
}); 