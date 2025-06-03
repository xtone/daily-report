import React from 'react'
import ReactDOM from 'react-dom'
//import FormData from 'formdata-polyfill'
import PropTypes from 'prop-types'

const csrfToken = document.getElementsByName('csrf-token').item(0).content;

class Calendar extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      reports: []
    };

    this.sendReport = this.sendReport.bind(this);
    this.destroyReport = this.destroyReport.bind(this);
  }

  componentDidMount() {
    ApiClient.get(this.props.projects_path)
      .then(response => response.json())
      .then(this.setProjects.bind(this));

    let searchParams = new URLSearchParams(window.location.search);
    ApiClient.get(`${this.props.reports_path}?date=${searchParams.get('date')}`)
      .then(response => response.json())
      .then(data => this.setState({ reports: data }))
      .catch(error => console.log(`There has been a problem with your fetch operation: ${error.message}`));

  }

  setProjects(data) {
    let projects = [];
    for (let project of data) {
      if (project.related) {
        projects.push(project);
      }
    }
    this.setState({ projects: projects });
  }

  /**
   * 日報データをサーバーに送信し、Stateを書き換える
   * @param {number} index - this.state.reports の index
   * @param {object} data - 日報データ
   * @return {}
   */
  sendReport(index, data) {
    return ApiClient.post(data.path, { body: data.data })
      .then(response => response.json())
      .then(report => {
        let reports = this.state.reports;
        reports[index] = report;
        this.setState({ reports: reports });
      });
  }

  destroyReport(index, data) {
    return ApiClient.delete(data.path)
      .then(response => response.json())
      .then(report => {
        let reports = this.state.reports;
        reports[index] = report;
        this.setState({ reports: reports });
      });
  }

  render() {
    let days = this.state.reports.map((report, index) => {
      return <CalendarDay data={report}
                          projects={this.state.projects}
                          sendReport={this.sendReport}
                          destroy={this.destroyReport}
                          index={index}
                          key={report.date} />;
    });
    return (
      <ul className="calendar list-group">
        {days}
      </ul>
    );
  }
}

/**
 * 1日分のユーザーの日報を表示するComponent
 */
class CalendarDay extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      operationCount: 0,
      isEditing: false
    };

    this.toggleForm = this.toggleForm.bind(this);
    this.abort = this.abort.bind(this);
    this.addOperation = this.addOperation.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
    this.destroy = this.destroy.bind(this);
  }

  componentWillMount() {
    this.setOperationCountDefault();
  }

  setOperationCountDefault() {
    if (this.reportExist()) {
      this.setState({ operationCount: this.props.data.report.operations.length });
    } else {
      this.setState({ operationCount: 1 });
    }
  }

  /**
   * reportのPropが存在するかチェックする
   * @return {boolean}
   */
  reportExist() {
    return this.props.data.hasOwnProperty('report');
  }

  /**
   * data.dateが未来かどうかチェックする
   * @returns {boolean}
   */
  isFuture() {
    return new Date().getTime() < new Date(this.props.data.date).getTime();
  }

  /**
   * 登録フォームの開閉を行う
   */
  toggleForm() {
    this.setState({ isEditing: !this.state.isEditing });
  }

  /**
   * 登録作業を中止する
   */
  abort() {
    this.setOperationCountDefault();
    this.toggleForm();
  }

  /**
   * 作業項目を増やす
   */
  addOperation() {
    this.setState({ operationCount: this.state.operationCount + 1 });
  }

  /**
   * データの更新
   * @param {object} report
   */
  onSubmit(report) {
    report.data.append('worked_in', this.props.data.date);
    this.props.sendReport(this.props.index, report)
      .then(this.toggleForm);
  }

  /**
   * データの削除
   * @param {object} report
   */
  destroy(report) {
    this.props.destroy(this.props.index, report)
      .then(this.toggleForm);
  }

  /**
   * classNameを組み立てて返す
   * @return {string}
   */
  dayClassName() {
    let dayClass = 'list-group-item day';
    let today_str = this.dateToString(new Date());
    if (today_str === this.props.data.date) {
      dayClass += ' today';
    } else {
      switch (this.props.data.wday) {
        case 0:
          dayClass += ' sun';
          break;
        case 6:
          dayClass += ' sat';
          break;
      }
      if (this.props.data.holiday) {
        dayClass += ' holiday';
      }
    }
    return dayClass;
  }

  /**
   * DateをYYYY-MM-DD形式の文字列で出力する
   * @param {Date} date
   * @returns {string}
   */
  dateToString(date) {
    let year = date.getFullYear();
    let month = date.getMonth() + 1;
    let day = date.getDate();
    if (month < 10) month = '0' + month;
    if (day < 10) day = '0' + day;
    return year + '-' + month + '-' + day;
  }

  render() {
    if (this.state.isEditing) {
      return (
        <li className={this.dayClassName()}>
          <CalendarDate date={this.props.data.date}
                        wday={this.props.data.wday}
                        key={this.props.data.date + '-date'} />
          <AbortButton abort={this.abort} />
          <ReportForm formLength={this.state.operationCount}
                      isRegistered={this.reportExist()}
                      report={this.props.data.report}
                      projects={this.props.projects}
                      addOperation={this.addOperation}
                      onSubmit={this.onSubmit}
                      destroy={this.destroy} />
        </li>
      );
    } else {
      let operations = [];
      if (this.reportExist()) {
        operations = this.props.data.report.operations.map((operation, index) => {
          return <Operation project={operation.project}
                            workload={operation.workload}
                            index={index}
                            key={operation.id} />;
        });
      }
      return (
        <li className={this.dayClassName()}>
          <CalendarDate date={this.props.data.date}
                        wday={this.props.data.wday}
                        key={this.props.data.date + '-date'} />
          <RegisterButton isRegistered={this.reportExist()}
                          disabled={this.isFuture()}
                          toggleForm={this.toggleForm} />
          <div className="operations">
            {operations}
          </div>
        </li>
      );
    }
  }
}

/**
 * 日付を表示するComponent
 */
class CalendarDate extends React.Component {
  render() {
    const wdays = ['日', '月', '火', '水', '木', '金', '土'];
    return(
      <div className="date">
        {parseInt(this.props.date.replace(/\d{4}-\d{2}-(\d{2})/, '$1'))}({wdays[this.props.wday]})
      </div>
    );
  }
}

/**
 * 日報の登録フォームを表示するボタンComponent
 **/
class RegisterButton extends React.Component {
  constructor(props) {
    super(props);

    this.onClick = this.onClick.bind(this);
  }
  onClick(event) {
    this.props.toggleForm();
  }

  render() {
    if (this.props.isRegistered) {
      return (
        <div>
          <button type="button" className="btn btn-success" onClick={this.onClick}>更新</button>
        </div>
      );
    } else {
      if (this.props.disabled) {
        return (
          <div>
            <button type="button" className="btn btn-default" disabled="disabled">登録</button>
          </div>
        );
      } else {
        return (
          <div>
            <button type="button" className="btn btn-primary" onClick={this.onClick}>登録</button>
          </div>
        );
      }
    }
  }
}

/**
 * 日報の登録フォームを非表示にするボタンComponent
 */
class AbortButton extends React.Component {
  constructor(props) {
    super(props);

    this.onClick = this.onClick.bind(this);
  }

  onClick(event) {
    this.props.abort();
  }

  render() {
    return (
      <div>
        <button type="button" className="btn btn-danger" onClick={this.onClick}>中止</button>
      </div>
    );
  }
}

/**
 * 作業内容を表示するComponent
 */
class Operation extends React.Component {
  render() {
    return (
      <div className="operation">
        <span className="project label label-default">
          {this.props.project.name}
        </span>
        <span className="workload">{this.props.workload}%</span>
      </div>
    );
  }
}

/**
 * 日報登録フォームComponent
 */
class ReportForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      id: null,
      displayed: [],
      reportError: null,
      operationErrors: []
    };

    this.addOperation = this.addOperation.bind(this);
    this.destroy = this.destroy.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
    this.destroyReport = this.destroyReport.bind(this);
  }

  componentWillMount() {
    if (this.props.isRegistered) {
      let displayed = [];
      for (let i = 0, imax = this.props.report.operations.length; i < imax; i++) {
        displayed.push(true);
      }
      this.setState({
        id: this.props.report.id,
        displayed: displayed
      });
    }
  }

  /**
   * 登録フォームを増やす
   * @param {Event} event
   */
  addOperation(event) {
    this.props.addOperation();
  }

  /**
   * 登録フォームを削除する
   * @param {number} index - 削除したフォームのindex
   */
  destroy(index) {
    let displayed = this.state.displayed;
    displayed[index] = false;
    this.setState({ displayed: displayed });
  }

  /**
   * 日報データを親Componentに送信する
   * @param {Event} event
   */
  onSubmit(event) {
    event.preventDefault();
    let form = this.refs.form;
    let data = new FormData(form);
    if (this.validate(data)) {
      this.props.onSubmit({
        path:   form.action,
        method: data.get('_method'),
        data:   data
      });
    } else {
      // error
    }
  }

  /**
   * 日報データを削除する
   * @param {Event} event
   */
  destroyReport(event) {
    event.preventDefault();
    let form = this.refs.form;
    if (!window.confirm('この日の日報を削除してもよろしいですか？')) return;
    this.props.destroy({
      path: form.action
    });
  }

  /**
   * POSTする値が正しいかを調べる
   * @param {FormData} formdata
   * @return {boolean}
   */
  validate(formdata) {
    let total = 0, errors = [];
    formdata.getAll('workloads[]').map((val, index) => {
      if (val === '') {
        errors[index] = '稼働率が設定されていません。';
        return;
      }
      let intval = parseInt(val);
      if (intval <= 0 || 100 < intval) {
        errors[index] = '稼働率は1〜100の間で設定してください。';
      }
      total += intval;
    }, this);
    if (total !== 100) {
      this.setState({ reportError: '稼働率の合計が100になっていません。現在'+ total +'%です。' });
    }
    this.setState({ operationErrors: errors });
    return total === 100 && errors.join('') === '';
  }

  render() {
    let action, method, deleteButton, operation = undefined, inputs = [], error = null;
    for (let i = 0; i < this.props.formLength; i++) {
      if (this.state.displayed[i] === false) {
        continue;
      }
      if (this.props.isRegistered) {
        operation = this.props.report.operations[i];
      }
      if (typeof operation === 'object') {
        inputs.push(
          <OperationForm operation={operation}
                         error={this.state.operationErrors[i]}
                         projects={this.props.projects}
                         destroy={this.destroy}
                         index={i}
                         key={operation.id}/>
        );
      } else {
        inputs.push(
          <OperationForm error={this.state.operationErrors[i]}
                         projects={this.props.projects}
                         destroy={this.destroy}
                         index={i}
                         key={i} />
        );
      }
    }
    if (this.props.isRegistered) {
      action = `/reports/${this.props.report.id}.json`;
      method = 'PUT';
      deleteButton = <input type="button"
                            className="btn btn-danger pull-right"
                            onClick={this.destroyReport}
                            value="削除" />;
    } else {
      action = '/reports.json';
      method = 'POST';
    }
    if (this.state.reportError) {
      error = <span className="alert alert-danger">{this.state.reportError}</span>;
    }
    return (
      <form action={action} method="post" ref="form" onSubmit={this.onSubmit}>
        <input type="hidden" name="_method" value={method} />
        {inputs}
        <button type="button" className="btn btn-info btn-sm" onClick={this.addOperation}>フォームの追加</button>
        <input type="submit" className="btn btn-primary pull-right" value="送信" />
        {deleteButton}
        {error}
      </form>
    );
  }
}

/**
 * 作業内容を登録するフォームComponent
 */
class OperationForm extends React.Component {
  constructor(props) {
    super(props);

    this.onChangeProject = this.onChangeProject.bind(this);
    this.destroyOperation = this.destroyOperation.bind(this);
  }

  operationExist() {
    return this.props.hasOwnProperty('operation');
  }

  /**
   * フォームの削除
   * @param {Event} event
   */
  destroyOperation(event) {
    this.props.destroy(this.props.index);
  }

  /**
   * プロジェクト変更後、稼働率の入力のためfocusを移動させる
   * @param {Event} event
   */
  onChangeProject(event) {
    this.refs.workload.focus();
  }

  render() {
    let error = null;
    if (typeof this.props.error === 'string') {
      error = <span className="alert alert-danger">{this.props.error}</span>
    }
    if (this.operationExist()) {
      return (
        <div className="form-inline">
          <input type="hidden" name="operation_ids[]" value={this.props.operation.id} />
          <ProjectSelect project_id={this.props.operation.project.id}
                         projects={this.props.projects}
                         key={"project" + this.props.operation.id}
                         onChange={this.onChangeProject} />
          <div className="input-group">
            <input type="text"
                   name="workloads[]"
                   defaultValue={this.props.operation.workload}
                   ref="workload"
                   className="form-control input-sm" />
            <div className="input-group-addon">%</div>
          </div>
          <button type="button"
                  className="btn btn-danger btn-xs"
                  onClick={this.destroyOperation}>
            <span className="glyphicon glyphicon-remove" />
          </button>
          {error}
        </div>
      );
    } else {
      return (
        <div className="form-inline">
          <input type="hidden" name="operation_ids[]" value="" />
          <ProjectSelect projects={this.props.projects}
                         onChange={this.onChangeProject} />
          <div className="input-group">
            <input type="text"
                   name="workloads[]"
                   defaultValue=""
                   ref="workload"
                   className="form-control input-sm" />
            <div className="input-group-addon">%</div>
          </div>
          <button type="button"
                  className="btn btn-danger btn-xs"
                  onClick={this.destroyOperation}>
            <span className="glyphicon glyphicon-remove" />
          </button>
          {error}
        </div>
      );
    }
  }
}

/**
 * 稼働したプロジェクトを選択するComponent
 */
class ProjectSelect extends React.Component {
  constructor(props) {
    super(props);
    this.state = { project_id: null };
  }

  render() {
    let options = this.props.projects.map((project) => {
      return <option value={project.id} key={project.id}>{project.name}</option>;
    });

    return (
      <select name="project_ids[]"
              defaultValue={this.props.project_id}
              className="form-control input-sm"
              onChange={this.props.onChange}>
        {options}
      </select>
    );
  }
}

class ApiClient {
  static get(requestPath, params) {
    return fetch(requestPath, ApiClient.requestParams('GET', params));
  }

  static post(requestPath, params) {
    return fetch(requestPath, ApiClient.requestParams('POST', params));
  }

  static put(requestPath, params) {
    return fetch(requestPath, ApiClient.requestParams('PUT', params));
  }

  static delete(requestPath, params) {
    return fetch(requestPath, ApiClient.requestParams('DELETE', params));
  }

  static requestParams(method, params) {
    return Object.assign({
      credentials: 'same-origin',
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': csrfToken
      }
    }, params, { method: method });
  }
}

function initializeReports() {
  let container = document.getElementById('reports');
  if (!container) return;
  ReactDOM.render(
    <Calendar reports_path={container.dataset.reportsPath}
              projects_path={container.dataset.projectsPath} />,
    container
  );
}

function cleanupReports() {
  let container = document.getElementById('reports');
  if (!container) return;
  ReactDOM.unmountComponentAtNode(container);
}

// DOMContentLoadedとturbo:loadの両方に対応
document.addEventListener('DOMContentLoaded', initializeReports);
document.addEventListener('turbo:load', initializeReports);
document.addEventListener('turbo:before-render', cleanupReports);
