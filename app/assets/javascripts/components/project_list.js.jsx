/**
 * プロジェクト一覧のラッパーComponent
 */
var ProjectListRoot = React.createClass({
  getInitialState: function() {
    return {
      projects: []
    };
  },

  componentDidMount: function() {
    $.ajax(this.props.resource_url, {
      dataType: 'json'
    }).done(function(response) {
      this.setProjectList(response);
    }.bind(this));
  },

  /**
   * プロジェクトの一覧を作る
   * @param {object} data - プロジェクトのデータ
   */
  setProjectList: function(data) {
    var projects = [[], [], [], [], [], [], [], [], [], []];
    data.forEach(function(project) {
      var index = this.getCharCodeIndex(project.name_reading);
      projects[index].push(project);
    }, this);
    this.setState({ projects: projects });
  },

  /**
   * プロジェクトの読みの頭文字で this.state.projects の index を決定して、返す
   * @param {string} initialChar プロジェクトの読みの頭文字
   * @return {number} index
   * @throws {RangeError} 想定されていない文字 initialChar が渡された時
   */
  getCharCodeIndex: function(initialChar) {
    var unicode = initialChar.charCodeAt(0);
    if (unicode < 0x3041) throw new RangeError();
    if (unicode < 0x304B) return 0; // あ行
    if (unicode < 0X3055) return 1; // か行
    if (unicode < 0x305F) return 2; // さ行
    if (unicode < 0X306A) return 3; // た行
    if (unicode < 0x306F) return 4; // な行
    if (unicode < 0x307E) return 5; // は行
    if (unicode < 0x3083) return 6; // ま行
    if (unicode < 0x3089) return 7; // や行
    if (unicode < 0x308E) return 8; // ら行
    if (unicode < 0x3094) return 9; // わ行
    if (unicode == 0x3094) return 0;  // ゔ = あ行
    if (unicode < 0x3097) return 1; // ヵヶ = か行
    throw new RangeError();
  },

  render: function() {
    var projects = this.state.projects.map(function(ps, i) {
      return <ProjectList projects={ps} index={i} key={i} />;
    });
    return(
      <div id="projectSetting" className="container">
        {projects}
      </div>
    );
  }
});

/**
 * ◯行の文字で始まるプロジェクトの一覧Component
 */
var ProjectList = React.createClass({
  getInitialState: function() {
    return {
      projects: []
    };
  },

  componentWillMount: function() {
    this.setState({ projects: this.props.projects });
  },

  /**
   * 自分が関わってる/関わってない状態の切り替えを行う
   * @param {number} index - 変更するStateのindex
   */
  toggleRelated: function(index) {
    var project = this.state.projects[index];
    $.ajax('/settings/projects/' + project.id + '.json', {
      method: project.related ? 'DELETE' : 'PUT',
      dataType: 'text'
    }).done(function(response) {
        project.related = !project.related;
        var projects = this.state.projects;
        projects[index] = project;
        this.setState({ projects: projects });
      }.bind(this)
    ).fail(function() {

    });
  },

  initials: ['あ','か','さ','た','な','は','ま','や','ら','わ'],

  /**
   * プロジェクトの頭文字
   * @returns {string}
   */
  initialChar: function() {
    return this.initials[this.props.index];
  },

  render: function() {
    var projects = this.props.projects.map(function(project, index) {
      return <Project project={project} index={index} key={project.id} onClick={this.toggleRelated} />;
    }, this);

    return (
      <section>
        <h3>{this.initialChar()}</h3>
        <div className="list-group">
          {projects}
        </div>
      </section>
    );
  }
});

/**
 * プロジェクトComponent
 */
var Project = React.createClass({
  onClick: function(event) {
    event.preventDefault();
    this.props.onClick(this.props.index);
  },

  projectCode: function(code) {
    if (code) {
      return ' (' + code + ')'
    } else {
      return ''
    }
  },

  render: function() {
    if (this.props.project.related) {
      return (
        <a href="#" className="list-group-item list-group-item-success" onClick={this.onClick}>
          <ProjectCode code={this.props.project.code} />
          <div className="project selected">{this.props.project.name}</div>
        </a>
      );
    } else {
      return (
        <a href="#" className="list-group-item" onClick={this.onClick}>
          <ProjectCode code={this.props.project.code} />
          <div className="project">{this.props.project.name}</div>
        </a>
      );
    }
  }
});

var ProjectCode = React.createClass({
  render: function() {
    if (this.props.code) {
      return <div className="project-code">【{this.props.code}】</div>
    } else {
      return <div className="project-code" />
    }
  }
});