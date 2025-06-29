import React from 'react'
import ReactDOM from 'react-dom'
import { createRoot } from 'react-dom/client'
import * as Turbo from '@hotwired/turbo-rails'

const csrfToken = document.getElementsByName('csrf-token').item(0).content;
const requestParams = {
  credentials: 'same-origin',
  headers: {
    'Accept': 'application/json',
    'X-CSRF-Token': csrfToken
  }
};

class Bill extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      resource: null,
      warnings: [],
      error: null
    };
  }

  confirm(formData) {
    fetch(this.props.confirmBillsPath, Object.assign(requestParams, { method: 'POST', body: formData }))
      .then(response => response.json())
      .then(response => {
        if (response.status === 'ok') {
          this.setState({ resource: response.resource, warnings: response.warnings, error: null })
        } else {
          this.setState({ resource: null, error: response.error });
        }
      });
  }

  cancel() {
    this.setState({ resource: null, warnings: [], error: null });
  }

  render() {
    if (this.state.resource) {
      return <BillForm action={this.props.billsPath}
                       resource={this.state.resource}
                       warnings={this.state.warnings}
                       onCancel={this.cancel.bind(this)} />;
    } else {
      return <BillConfirmForm action={this.props.confirmBillsPath}
                              error={this.state.error}
                              onSubmit={this.confirm.bind(this)} />;
    }
  }
}

/**
 * 確認表示をするためのフォーム
 */
class BillConfirmForm extends React.Component {
  openFileDialog(event) {
    event.preventDefault();
    this.refs.fileButton.click();
  }

  handleDragOver(event) {
    event.preventDefault();
    event.stopPropagation();
    event.target.classList.add('dragover');
  }

  handleDragEnter(event) {
    event.preventDefault();
    event.stopPropagation();
    event.target.classList.add('dragover');
  }

  handleDragLeave(event) {
    event.preventDefault();
    event.stopPropagation();
    event.target.classList.remove('dragover');
  }

  handleDrop(event) {
    event.preventDefault();
    event.stopPropagation();
    event.target.classList.remove('dragover');

    let file = event.dataTransfer.files[0];
    let form = this.refs.form;
    let formData = new FormData(form);
    formData.append('file', file);
    this.props.onSubmit(formData);
  }

  handleChange(event) {
    this.props.onSubmit(new FormData(this.refs.form));
  }

  render() {
    return <form action={this.props.action} method="POST" encType="multipart/form-data" ref="form">
      <div className="panel panel-info">
        <div className="panel-heading">ファイルアップロードの前に</div>
        <div className="panel-body">
          数式＞計算方法の設定が「手動計算を行う」になっているか確認してください。
        </div>
      </div>
      {this.props.error &&
      <div className="alert alert-danger">{this.props.error}</div>
      }
      <div className="panel panel-default drop-area"
           onDragOver={this.handleDragOver.bind(this)}
           onDragEnter={this.handleDragEnter.bind(this)}
           onDragLeave={this.handleDragLeave.bind(this)}
           onDrop={this.handleDrop.bind(this)}>
        <div className="panel-body">
          <p>
            <a href="#" onClick={this.openFileDialog.bind(this)}>ファイルを選択</a>
            または、請求書ファイルをここにドラッグ ＆ ドロップ
          </p>
        </div>
      </div>
      <input type="file" name="file" ref="fileButton" className="hidden" onChange={this.handleChange.bind(this)} />
    </form>;
  }
}

/**
 * データを登録するためのフォーム
 */
class BillForm extends React.Component {
  cancel(event) {
    event.preventDefault();
    this.props.onCancel();
  }

  render() {
    return <form action={this.props.action} method="POST">
      <input type="hidden" name="authenticity_token" value={csrfToken} />
      <p>この内容で良ければ、登録ボタンを押してください。</p>
      {this.props.warnings.length > 0 &&
        <BillWarnings warnings={this.props.warnings} />
      }
      <BillTable resource={this.props.resource} />
      <BillHiddenFields resource={this.props.resource} />
      <div className="form-group text-center">
        <input type="submit" value="登録" className="btn btn-primary navbar-btn" />
        <input type="reset" value="中止" className="btn btn-danger navbar-btn" onClick={this.cancel.bind(this)} />
      </div>
    </form>;
  }
}

/**
 * 登録しようとしているデータに対しての警告表示
 */
class BillWarnings extends React.Component {
  render() {
    return (
      <div className="panel panel-warning">
        <div className="panel-heading">
          <h3 className="panel-title">警告</h3>
        </div>
        <div className="panel-body">
          {this.props.warnings.map((warning, i) => {
            return <p key={"warning" + i}>{warning}</p>;
          })}
        </div>
      </div>
    );
  }
}

/**
 * 登録しようとしているデータを表示
 */
class BillTable extends React.Component {
  render() {
    let bill = this.props.resource;
    return (
      <table className="table confirm">
        <tbody>
        <tr>
          <th>見積書NO</th>
          <td>{bill.estimate_serial_no}</td>
        </tr>
        <tr>
          <th>請求書NO</th>
          <td>{bill.serial_no}</td>
        </tr>
        <tr>
          <th>請求書件名</th>
          <td>{bill.subject}</td>
        </tr>
        <tr>
          <th>請求書日付</th>
          <td>{bill.claimed_on}</td>
        </tr>
        <tr>
          <th>請求金額</th>
          <td>¥{bill.amount.toLocaleString()}</td>
        </tr>
        <tr>
          <th>請求金額（税込）</th>
          <td>¥{bill.tax_included_amount.toLocaleString()}</td>
        </tr>
        <tr>
          <th>請求書ファイル名</th>
          <td>{bill.filename}</td>
        </tr>
        </tbody>
      </table>
    );
  }
}

/**
 * サーバーに送信するためのinputタグ
 */
class BillHiddenFields extends React.Component {
  render() {
    let bill = this.props.resource;
    let fields = ['estimate_id', 'serial_no', 'subject', 'claimed_on', 'amount', 'filename'].map((attribute, i) => {
      return <input type="hidden"
                    name={"bill[" + attribute + "]"}
                    value={bill[attribute]}
                    key={"value" + i} />;
    });
    return <div>{fields}</div>;
  }
}

// React 18のルートを保持する変数
let billsRoot = null;

document.addEventListener('turbo:load', () => {
  let container = document.getElementById('bills');
  if (!container) return;
  
  // 既存のルートがある場合は再利用、なければ新規作成
  if (!billsRoot) {
    billsRoot = createRoot(container);
  }
  
  billsRoot.render(
    <Bill billsPath={container.dataset.billsPath}
          confirmBillsPath={container.dataset.confirmBillsPath} />
  );
});

document.addEventListener('turbo:before-render', () => {
  // React 18のルートをアンマウント
  if (billsRoot) {
    billsRoot.unmount();
    billsRoot = null;
  }
});
