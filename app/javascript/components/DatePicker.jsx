import React from 'react';
import PropTypes from 'prop-types';

// Bootstrap 3のdatetimepickerをラップするReactコンポーネント
class DatePicker extends React.Component {
  constructor(props) {
    super(props);
    this.inputRef = React.createRef();
  }

  componentDidMount() {
    this.initializeDatePicker();
  }

  componentWillUnmount() {
    this.destroyDatePicker();
  }

  initializeDatePicker() {
    // グローバルスコープから $ と moment を取得
    if (typeof window.$ === 'undefined' || typeof window.moment === 'undefined') {
      console.error('jQuery or moment.js is not loaded');
      return;
    }
    
    const $ = window.$;
    const moment = window.moment;
    
    const $input = $(this.inputRef.current);
    
    // Bootstrap datetimepickerの初期化
    const options = Object.assign({
      format: this.props.format || 'YYYY-MM-DD',
      dayViewHeaderFormat: 'YYYY年MMMM',
      locale: moment.locale('ja'),
      showClose: true
    }, this.props.options);
    
    $input.datetimepicker(options);

    // 値が変更された時のイベントハンドラー
    $input.on('dp.change', (e) => {
      if (this.props.onChange) {
        this.props.onChange(e.date ? e.date.format(this.props.format || 'YYYY-MM-DD') : '');
      }
    });
  }

  destroyDatePicker() {
    if (typeof window.$ === 'undefined') {
      return;
    }
    
    const $ = window.$;
    const $input = $(this.inputRef.current);
    if ($input.data('DateTimePicker')) {
      $input.data('DateTimePicker').destroy();
    }
  }

  render() {
    const {
      name,
      placeholder,
      value,
      className,
      disabled,
      required
    } = this.props;

    return (
      <div className="input-group date">
        <input
          ref={this.inputRef}
          type="text"
          name={name}
          placeholder={placeholder}
          value={value}
          className={`form-control date-input ${className || ''}`}
          disabled={disabled}
          required={required}
          readOnly
        />
        <span className="input-group-addon">
          <span className="glyphicon glyphicon-calendar"></span>
        </span>
      </div>
    );
  }
}

DatePicker.propTypes = {
  name: PropTypes.string,
  placeholder: PropTypes.string,
  value: PropTypes.string,
  className: PropTypes.string,
  disabled: PropTypes.bool,
  required: PropTypes.bool,
  format: PropTypes.string,
  options: PropTypes.object,
  onChange: PropTypes.func
};

DatePicker.defaultProps = {
  format: 'YYYY-MM-DD',
  disabled: false,
  required: false,
  options: {}
};

export default DatePicker; 