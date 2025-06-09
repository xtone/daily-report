import React from 'react';
import ReactDOM from 'react-dom';
import DatePicker from './components/DatePicker';

// ユーザーフォーム用の日付ピッカーコンポーネント
class UserFormDatePicker extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: this.props.initialValue || ''
    };
    this.handleDateChange = this.handleDateChange.bind(this);
  }

  handleDateChange(dateValue) {
    this.setState({ value: dateValue });
    
    // 元のinputフィールドの値も更新
    const originalInput = document.querySelector(`input[name="${this.props.name}"]`);
    if (originalInput && originalInput !== this.datePickerInput) {
      originalInput.value = dateValue;
    }
  }

  render() {
    return (
      <DatePicker
        name={this.props.name}
        placeholder={this.props.placeholder}
        value={this.state.value}
        onChange={this.handleDateChange}
        required={this.props.required}
      />
    );
  }
}

// CSRFトークンを取得
const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

// Turbolinksイベントでコンポーネントをマウント
document.addEventListener('turbolinks:load', () => {
  // ユーザーフォームの日付ピッカーを置き換え
  const userFormDateInputs = document.querySelectorAll('#user .input-group.date input[type="text"]');
  
  userFormDateInputs.forEach(input => {
    const container = input.closest('.input-group.date');
    if (container && !container.dataset.reactMounted) {
      // 元の値を取得
      const initialValue = input.value;
      const name = input.name;
      const placeholder = input.placeholder;
      const required = input.required;
      
      // Reactコンポーネント用のコンテナを作成
      const reactContainer = document.createElement('div');
      container.parentNode.insertBefore(reactContainer, container);
      
      // 元のコンテナを非表示にする
      container.style.display = 'none';
      container.dataset.reactMounted = 'true';
      
      ReactDOM.render(
        <UserFormDatePicker
          name={name}
          placeholder={placeholder}
          initialValue={initialValue}
          required={required}
        />,
        reactContainer
      );
    }
  });
});

// Turbolinksページ遷移前にコンポーネントをアンマウント
document.addEventListener('turbolinks:before-render', () => {
  // React化された日付ピッカーをクリーンアップ
  const reactContainers = document.querySelectorAll('#user .input-group.date[data-react-mounted="true"]');
  reactContainers.forEach(container => {
    const reactContainer = container.previousSibling;
    if (reactContainer && reactContainer.nodeType === Node.ELEMENT_NODE) {
      ReactDOM.unmountComponentAtNode(reactContainer);
      reactContainer.remove();
    }
    container.style.display = '';
    delete container.dataset.reactMounted;
  });
}); 