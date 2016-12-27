var PropTypes = React.PropTypes;

/**
 * 1ヶ月分のユーザーの日報一覧を表示するComponent
 */
var Calendar = React.createClass({
  propTypes: {
    /** 日報を取得するURL */
    report_url: PropTypes.string,
    /** ユーザーが関与するプロジェクト群 */
    projects: PropTypes.arrayOf(PropTypes.object)
  },

  getInitialState: function() {
    return { reports: [] };
  },

  componentDidMount: function() {
    $.ajax(this.props.reports_url, {
      dataType: 'json'
    }).done(function(data) {
      this.setState({ reports: data });
    }.bind(this)
    ).fail(function(xhr, status, err) {
      console.error(this.props.reports_url, status, err.toString());
    }.bind(this)
    );
  },

  sendReport: function(index, params, callback) {
    $.ajax(params.path, {
      method: params.method,
      dataType: 'json',
      data: params.data,
      processData: false,
      contentType: false
    }).done(function(response) {
      var reports = this.state.reports;
      reports[index] = response;
      this.setState({ reports: reports });
    }.bind(this)
    ).fail(function() {

    }
    ).always(function() {
      callback();
    });
  },

  render: function() {
    var days = this.state.reports.map(function (report, index) {
      return <CalendarDay data={report}
                          projects={this.props.projects}
                          onSubmit={this.sendReport}
                          index={index}
                          key={report.date} />;
    }, this);
    return (
      <ul className="calendar list-group">
        {days}
      </ul>
    );
  }
});

/**
 * 1日分のユーザーの日報を表示するComponent
 */
var CalendarDay = React.createClass({
  propTypes: {
    data: PropTypes.shape({
      /** 日報の日付 */
      date: PropTypes.string,
      /** 曜日(0-6) */
      wday: PropTypes.number,
      /** 祝日判定 */
      holiday: PropTypes.bool,
      report: PropTypes.shape({
        /** ReportのID */
        id: PropTypes.number,
        /** 作業内容 */
        operations: PropTypes.arrayOf(PropTypes.object)
      })
    }),
    /** ユーザーの関与するプロジェクト群 */
    projects: PropTypes.arrayOf(PropTypes.object),
    onSubmit: PropTypes.func
  },

  getInitialState: function() {
    return {
      operationCount: 0,
      isEditing: false
    };
  },

  componentWillMount: function() {
    this.setOperationCountDefault();
  },

  /**
   * reportのPropが存在するかチェックする
   * @returns {boolean}
   */
  reportExist: function() {
    return this.props.data.hasOwnProperty('report');
  },

  /**
   * dateが未来かどうかチェックする
   * @returns {boolean}
   */
  isFuture: function() {
    return new Date().getTime() < new Date(this.props.data.date).getTime();
  },

  setOperationCountDefault: function() {
    if (this.reportExist()) {
      this.setState({ operationCount: this.props.data.report.operations.length });
    } else {
      this.setState({ operationCount: 1 });
    }
  },

  /**
   * 登録フォームの開閉を行う
   */
  toggleForm: function() {
    this.setState({ isEditing: !this.state.isEditing });
  },

  /**
   * 登録作業を中止する
   */
  abort: function() {
    this.setOperationCountDefault();
    this.toggleForm();
  },

  /**
   * 作業項目を増やす
   */
  addOperation: function() {
    this.setState({ operationCount: this.state.operationCount + 1 });
  },

  /**
   * データの更新
   * @param report {Object}
   */
  onSubmit: function(report) {
    report.data.append('worked_in', this.props.data.date);
    this.props.onSubmit(this.props.index, report, this.toggleForm);
  },

  /**
   * classNameを組み立てて返す
   * @returns {string}
   */
  dayClassName: function() {
    var dayClass = 'list-group-item day';
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
    return dayClass;
  },

  render: function() {
    if (this.state.isEditing) {
      return (
        <li className={this.dayClassName()}>
          <CalendarDate date={this.props.data.date}
                        wday={this.props.data.wday}
                        key={this.props.data.date + '-date'} />
          <AbortButton onClick={this.abort} />
          <ReportForm formLength={this.state.operationCount}
                      isRegistered={this.reportExist()}
                      report={this.props.data.report}
                      projects={this.props.projects}
                      onAddForm={this.addOperation}
                      onSubmit={this.onSubmit} />
        </li>
      );
    } else {
      var operations = [];
      if (this.reportExist()) {
        operations = this.props.data.report.operations.map(function (operation, index) {
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
});

/**
 * 日付を表示するComponent
 */
var CalendarDate = React.createClass({
  propTypes: {
    /** 日付(YYYY-MM-DD) */
    date: PropTypes.string,
    /** 曜日(0-6) */
    wday: PropTypes.number
  },

  render: function() {
    var wdays = ['日', '月', '火', '水', '木', '金', '土'];
    return(
      <div className="date">
        {parseInt(this.props.date.replace(/\d{4}-\d{2}-(\d{2})/, '$1'))}({wdays[this.props.wday]})
      </div>
    );
  }
});

/**
 * 日報の登録フォームを表示するボタンComponent
 **/
var RegisterButton = React.createClass({
  onClick: function(event) {
    this.props.toggleForm();
  },

  render: function() {
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
});

/**
 * 日報の登録フォームを非表示にするボタンComponent
 */
var AbortButton = React.createClass({
  onClick: function(event) {
    this.props.onClick();
  },

  render: function() {
    return (
      <div>
        <button type="button" className="btn btn-danger" onClick={this.onClick}>中止</button>
      </div>
    );
  }
});

/**
 * 作業内容を表示するComponent
 */
var Operation = React.createClass({
  render: function() {
    return (
      <div className="operation">
        <span className="project label label-default">
          {this.props.project.name}
        </span>
        <span className="workload">{this.props.workload}%</span>
      </div>
    );
  }
});

/**
 * 日報登録フォームComponent
 */
var ReportForm = React.createClass({
  getInitialState: function() {
    return {
      id: null,
      displayed: [],
      reportError: null,
      operationErrors: []
    };
  },

  componentWillMount: function() {
    if (this.props.isRegistered) {
      var displayed = [];
      for (var i = 0, imax = this.props.report.operations.length; i < imax; i++) {
        displayed.push(true);
      }
      this.setState({
        id: this.props.report.id,
        displayed: displayed
      });
    }
  },

  addOperation: function(event) {
    this.props.onAddForm();
  },

  destroy: function(index) {
    var displayed = this.state.displayed;
    displayed[index] = false;
    this.setState({ displayed: displayed });
  },

  onSubmit: function(event) {
    event.preventDefault();
    var form = this.refs.form;
    var data = new FormData(form);
    if (this.validate(data)) {
      this.props.onSubmit({
        path: form.action,
        method: data.get('_method'),
        data: data
      });
    } else {
      // error
    }
  },

  /**
   * POSTする値が正しいかを調べる
   * @param data {FormData}
   * @returns {boolean}
   */
  validate: function(data) {
    var total = 0, errors = [];
    data.getAll('workloads[]').map(function(val, index) {
      if (val == '') {
        errors[index] = '稼働率が設定されていません。';
        return;
      }
      var intval = parseInt(val);
      if (intval < 0 || 100 < intval) {
        errors[index] = '稼働率は0〜100の間で設定してください。';
        return;
      }
      total += intval;
    }, this);
    if (total != 100) {
      this.setState({ reportError: '稼働率の合計が100になっていません。' });
    }
    this.setState({ operationErrors: errors });
    return total == 100 && errors.join('') == '';
  },

  render: function() {
    var action, method, operation = undefined;
    var inputs = [];
    for (var i = 0; i < this.props.formLength; i++) {
      if (this.state.displayed[i] == false) {
        continue;
      }
      if (this.props.isRegistered) {
        operation = this.props.report.operations[i];
      }
      if (typeof operation == 'object') {
        inputs.push(
          <OperationForm operation={operation}
                         error={this.state.operationErrors[i]}
                         projects={this.props.projects}
                         onDestroy={this.destroy}
                         index={i}
                         key={operation.id}/>
        );
      } else {
        inputs.push(
          <OperationForm error={this.state.operationErrors[i]}
                         projects={this.props.projects}
                         onDestroy={this.destroy}
                         index={i}
                         key={i} />
        );
      }
    }
    if (this.props.isRegistered) {
      action = '/reports/' + this.props.report.id + '.json';
      method = 'PUT';
    } else {
      action = '/reports.json';
      method = 'POST';
    }
    var error = null;
    if (this.state.reportError) {
      error = <span className="alert alert-danger">{this.state.reportError}</span>;
    }
    return (
      <form action={action} method="post" ref="form" onSubmit={this.onSubmit}>
        <input type="hidden" name="_method" value={method} />
        {inputs}
        <button type="button" className="btn btn-info btn-sm" onClick={this.addOperation}>フォームの追加</button>
        <input type="submit" className="btn btn-primary pull-right" value="送信" />
        {error}
      </form>
    );
  }
});

/**
 * 作業内容を登録するフォームComponent
 */
var OperationForm = React.createClass({
  operationExist: function() {
    return this.props.hasOwnProperty('operation');
  },

  destroyOperation: function(event) {
    this.props.onDestroy(this.props.index);
  },

  /**
   * プロジェクト変更後、稼働率の入力のためfocusを移動させる
   * @param event
   */
  onChangeProject: function(event) {
    this.refs.workload.focus();
  },

  render: function() {
    var error;
    if (typeof this.props.error == 'string') {
      error = <span className="alert alert-danger">{this.props.error}</span>
    } else {
      error = null;
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
});

/**
 * 稼働したプロジェクトを選択するComponent
 */
var ProjectSelect = React.createClass({
  getInitialState: function() {
    return { project_id: null };
  },

  render: function() {
    var options = this.props.projects.map(function(project) {
      return <option value={project.id} key={project.id}>{project.name}</option>;
    });

    return (
      <select name="project_ids[]" defaultValue={this.props.project_id} className="form-control input-sm" onChange={this.props.onChange}>
        {options}
      </select>
    );
  }
});