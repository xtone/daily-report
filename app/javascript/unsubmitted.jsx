import React from 'react';
import ReactDOM from 'react-dom';
import DatePicker from './components/DatePicker';

// 未提出一覧用の日付ピッカーコンポーネント
class UnsubmittedDatePicker extends React.Component {
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
        <span> の未提出一覧を</span>
      </div>
    );
  }
}

// CSRFトークンを取得
const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

// Turbolinksイベントでコンポーネントをマウント
document.addEventListener('turbolinks:load', () => {
  // 未提出一覧ページの日付ピッカーを置き換え
  const unsubmittedForm = document.querySelector('form[action*="unsubmitted"]');
  
  if (unsubmittedForm) {
    const formGroup = unsubmittedForm.querySelector('.form-group');
    const startInput = formGroup.querySelector('input[name="reports[start]"]');
    const endInput = formGroup.querySelector('input[name="reports[end]"]');
    
    if (startInput && endInput && !formGroup.dataset.reactMounted) {
      // 元の値を取得
      const initialStartDate = startInput.value;
      const initialEndDate = endInput.value;
      
      // Reactコンポーネント用のコンテナを作成
      const reactContainer = document.createElement('div');
      formGroup.parentNode.insertBefore(reactContainer, formGroup);
      
      // 元のフォームグループを非表示にする
      formGroup.style.display = 'none';
      formGroup.dataset.reactMounted = 'true';
      
      ReactDOM.render(
        <UnsubmittedDatePicker
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
  // React化された日付ピッカーをクリーンアップ
  const reactMountedElements = document.querySelectorAll('[data-react-mounted="true"]');
  reactMountedElements.forEach(element => {
    const reactContainer = element.previousSibling;
    if (reactContainer && reactContainer.nodeType === Node.ELEMENT_NODE) {
      ReactDOM.unmountComponentAtNode(reactContainer);
      reactContainer.remove();
    }
    element.style.display = '';
    delete element.dataset.reactMounted;
  });
}); 