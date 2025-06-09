import React from 'react';
import ReactDOM from 'react-dom';

// ReportSummary機能のReactコンポーネント（既存のCoffeeScriptから移植）
class ReportSummaryManager extends React.Component {
  constructor(props) {
    super(props);
    this.handleDownloadSubmit = this.handleDownloadSubmit.bind(this);
    this.handleDatePickerClick = this.handleDatePickerClick.bind(this);
  }

  componentDidMount() {
    // downloadFormのsubmitイベントリスナーを追加
    const downloadForm = document.getElementById(this.props.downloadFormId);
    if (downloadForm) {
      downloadForm.addEventListener('submit', this.handleDownloadSubmit);
    }

    // renderFormの日付ピッカーボタンにイベントリスナーを追加
    const renderForm = document.getElementById(this.props.renderFormId);
    if (renderForm) {
      const datePickerButtons = renderForm.getElementsByClassName('input-group-addon');
      Array.from(datePickerButtons).forEach(button => {
        button.addEventListener('click', this.handleDatePickerClick);
      });
    }
  }

  componentWillUnmount() {
    // イベントリスナーをクリーンアップ
    const downloadForm = document.getElementById(this.props.downloadFormId);
    if (downloadForm) {
      downloadForm.removeEventListener('submit', this.handleDownloadSubmit);
    }

    const renderForm = document.getElementById(this.props.renderFormId);
    if (renderForm) {
      const datePickerButtons = renderForm.getElementsByClassName('input-group-addon');
      Array.from(datePickerButtons).forEach(button => {
        button.removeEventListener('click', this.handleDatePickerClick);
      });
    }
  }

  handleDownloadSubmit(event) {
    event.preventDefault();
    this.download(event.target);
  }

  handleDatePickerClick() {
    this.enableDownloadForm();
  }

  download(form) {
    const renderForm = document.getElementById(this.props.renderFormId);
    if (!renderForm) return;

    const attrs = [];
    const inputs = renderForm.getElementsByClassName('date-input');
    
    Array.from(inputs).forEach(input => {
      attrs.push(`${input.name}=${input.value}`);
    });

    window.location.href = `${form.action}?${attrs.join('&')}`;
  }

  enableDownloadForm() {
    const downloadForm = document.getElementById(this.props.downloadFormId);
    if (!downloadForm) return;

    const buttons = downloadForm.getElementsByClassName('btn');
    Array.from(buttons).forEach(button => {
      button.removeAttribute('disabled');
    });
  }

  render() {
    // このコンポーネントは副作用のみを持ち、UIは描画しない
    return null;
  }
}

// CSRFトークンを取得
const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

// Turbolinksイベントでコンポーネントをマウント
document.addEventListener('turbolinks:load', () => {
  // ReportSummaryManagerをマウント（summaryRenderとsummaryDownloadフォームが存在する場合）
  const renderForm = document.getElementById('summaryRender');
  const downloadForm = document.getElementById('summaryDownload');
  
  if (renderForm && downloadForm) {
    const container = document.createElement('div');
    container.id = 'report-summary-manager';
    document.body.appendChild(container);
    
    ReactDOM.render(
      <ReportSummaryManager 
        renderFormId="summaryRender" 
        downloadFormId="summaryDownload" 
      />, 
      container
    );
  }
});

// Turbolinksページ遷移前にコンポーネントをアンマウント
document.addEventListener('turbolinks:before-render', () => {
  const container = document.getElementById('report-summary-manager');
  if (container) {
    ReactDOM.unmountComponentAtNode(container);
    container.remove();
  }
}); 