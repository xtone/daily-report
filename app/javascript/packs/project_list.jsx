import React from 'react'
import { createRoot } from 'react-dom/client'
import * as Turbo from '@hotwired/turbo-rails'
import PropTypes from 'prop-types'

const csrfToken = document.getElementsByName('csrf-token').item(0).content;
const requestParams = {
  credentials: 'same-origin',
  headers: {
    'Accept': 'application/json',
    'X-CSRF-Token': csrfToken
  }
};

class ProjectListRoot extends React.Component {
  constructor(props) {
    super(props);
    this.state = { projects: [] };
  }

  componentDidMount() {
    fetch(`${this.props.projects_path}.json`, requestParams)
      .then(response => response.json())
      .then(this.setProjectList.bind(this))
  }

  /**
   * プロジェクトの一覧を作る
   * @param {object} data - プロジェクトのデータ
   */
  setProjectList(data) {
    let projects = [[], [], [], [], [], [], [], [], [], []];
    data.forEach((project) => {
      let index = this.getCharCodeIndex(project.name_reading);
      projects[index].push(project);
    }, this);
    this.setState({ projects: projects });
  }

  /**
   * プロジェクトの読みの頭文字で this.state.projects の index を決定して、返す
   * @param {string} initialChar プロジェクトの読みの頭文字
   * @return {number} index
   * @throws {RangeError} 想定されていない文字 initialChar が渡された時
   */
  getCharCodeIndex(initialChar) {
    let unicode = initialChar.charCodeAt(0);
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
    if (unicode === 0x3094) return 0;  // ゔ = あ行
    if (unicode < 0x3097) return 1; // ヵヶ = か行
    throw new RangeError();
  }

  render() {
    let projects = this.state.projects.map((ps, i) => {
      return <ProjectList projects_path={this.props.projects_path} projects={ps} index={i} key={i} />;
    });
    return(
      <div id="projectSetting" className="container">
        {projects}
      </div>
    );
  }
}

ProjectListRoot.initials = ['あ','か','さ','た','な','は','ま','や','ら','わ'];

/**
 * ◯行の文字で始まるプロジェクトの一覧Component
 */
class ProjectList extends React.Component {
  constructor(props) {
    super(props);
    this.state = { projects: this.props.projects || [] };

    this.toggleRelated = this.toggleRelated.bind(this);
  }

  /**
   * 自分が関わってる/関わってない状態の切り替えを行う
   * @param {number} index - 変更するStateのindex
   */
  toggleRelated(index) {
    let project = this.state.projects[index];
    fetch(`${this.props.projects_path}/${project.id}.json`, Object.assign(requestParams, { method: project.related ? 'DELETE' : 'PUT' }))
      .then(response => response.text())
      .then(text => {
        project.related = !project.related;
        let projects = this.state.projects;
        projects[index] = project;
        this.setState({ projects: projects });
      });
  }

  /**
   * プロジェクトの頭文字
   * @returns {string}
   */
  initialChar() {
    return ProjectListRoot.initials[this.props.index];
  }

  render() {
    let projects = this.props.projects.map((project, index) => {
      return <Project project={project} index={index} key={project.id} onClick={this.toggleRelated} />;
    });

    return (
      <section>
        <h3>{this.initialChar()}</h3>
        <div className="list-group">
          {projects}
        </div>
      </section>
    );
  }
}

/**
 * プロジェクトComponent
 */
class Project extends React.Component {
  constructor(props) {
    super(props);

    this.onClick = this.onClick.bind(this);
  }

  onClick(event) {
    event.preventDefault();
    this.props.onClick(this.props.index);
  }

  render() {
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
}

class ProjectCode extends React.Component {
  render() {
    if (this.props.code) {
      return <div className="project-code">【{this.props.code}】</div>
    } else {
      return <div className="project-code" />
    }
  }
}


document.addEventListener('turbo:load', () => {
  const container = document.getElementById('project_list');
  if (container) {
    const root = createRoot(container);
    root.render(<ProjectListRoot projects_path="/settings/projects" />);
  }
});

document.addEventListener('turbo:before-render', () => {
  // React 18では不要: ReactDOM.unmountComponentAtNode(document.getElementById('project_list'));
});
