import React from 'react'
import ReactDOM from 'react-dom'

const csrfToken = document.getElementsByName('csrf-token').item(0).content;
const requestParams = {
  credentials: 'same-origin',
  headers: {
    'Accept': 'application/json',
    'X-CSRF-Token': csrfToken
  }
};

class Estimate extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      resource: null,
      warnings: [],
      error: null
    };
  }

  confirm(formData) {
    fetch(this.props.confirmEstimatesPath, Object.assign(requestParams, { method: 'POST', body: formData }))
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
      return <EstimateForm action={this.props.estimatesPath}
                           resource={this.state.resource}
                           warnings={this.state.warnings}
                           onCancel={this.cancel.bind(this)} />;
    } else {
      return <EstimateConfirmForm action={this.props.confirmEstimatesPath}
                                  error={this.state.error}
                                  onSubmit={this.confirm.bind(this)} />;
    }
  }
}

/**
 * 確認表示をするためのフォーム
 */
class EstimateConfirmForm extends React.Component {
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
        <div className="panel-heading">「ファイルの解析に失敗しました」エラーが出たときは</div>
        <div className="panel-body">
          「小計」の上の行のセルのコメントを削除すると、エラーを回避できることがあります。
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
            または、見積書ファイルをここにドラッグ ＆ ドロップ
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
class EstimateForm extends React.Component {
  cancel(event) {
    event.preventDefault();
    this.props.onCancel();
  }

  render() {
    let warnings = null;
    if (this.props.warnings && this.props.warnings.length > 0) {
      warnings = <EstimateWarnings warnings={this.props.warnings} />;
    }
    return <form action={this.props.action} method="POST">
      <input type="hidden" name="authenticity_token" value={csrfToken} />
      <p>この内容で良ければ、登録ボタンを押してください。</p>
      {warnings}
      <EstimateTable resource={this.props.resource} />
      <EstimateHiddenFields resource={this.props.resource} />
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
class EstimateWarnings extends React.Component {
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
class EstimateTable extends React.Component {
  render() {
    let estimate = this.props.resource;
    return (
      <table className="table confirm">
        <tbody>
          <tr>
            <th>PJコード</th>
            <td>{estimate.project_code}</td>
          </tr>
          <tr>
            <th>プロジェクト名</th>
            <td>{estimate.project_name}</td>
          </tr>
          <tr>
            <th>見積もり件名</th>
            <td>{estimate.subject}</td>
          </tr>
          <tr>
            <th>見積書NO</th>
            <td>{estimate.serial_no}</td>
          </tr>
          <tr>
            <th>見積もり日付</th>
            <td>{estimate.estimated_on}</td>
          </tr>
          <tr>
            <th>見積もり金額</th>
            <td>¥{estimate.amount.toLocaleString()}</td>
          </tr>
          <tr>
            <th>営業・ディレクター想定工数</th>
            <td>{estimate.director_manday} 人/日</td>
          </tr>
          <tr>
            <th>エンジニア想定工数</th>
            <td>{estimate.engineer_manday} 人/日</td>
          </tr>
          <tr>
            <th>デザイナー想定工数</th>
            <td>{estimate.designer_manday} 人/日</td>
          </tr>
          <tr>
            <th>その他想定工数</th>
            <td>{estimate.other_manday} 人/日</td>
          </tr>
          <tr>
            <th>予定原価</th>
            <td>¥{estimate.cost.toLocaleString()}</td>
          </tr>
          <tr>
            <th>見積書ファイル名</th>
            <td>{estimate.filename}</td>
          </tr>
        </tbody>
      </table>
    );
  }
}

/**
 * サーバーに送信するためのinputタグ
 */
class EstimateHiddenFields extends React.Component {
  render() {
    let estimate = this.props.resource;
    let fields = ['project_id', 'subject', 'estimated_on', 'serial_no', 'amount',
      'director_manday', 'engineer_manday', 'designer_manday', 'other_manday', 'cost', 'filename'].map((attribute, i) => {
      return <input type="hidden"
                    name={"estimate[" + attribute + "]"}
                    value={estimate[attribute]}
                    key={"value" + i} />;
    });
    return <div>{fields}</div>;
  }
}

document.addEventListener('DOMContentLoaded', () => {
  let container = document.getElementById('estimates');
  if (!container) return;
  ReactDOM.render(
    <Estimate estimatesPath={container.dataset.estimatesPath}
              confirmEstimatesPath={container.dataset.confirmEstimatesPath} />,
    container
  );
});

document.addEventListener('turbo:before-render', () => {
  let container = document.getElementById('estimates');
  if (!container) return;
  ReactDOM.unmountComponentAtNode(container);
});
