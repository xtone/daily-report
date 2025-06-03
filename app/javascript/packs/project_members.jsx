import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

const csrfToken = document.getElementsByName('csrf-token').item(0).content;
const requestParams = {
  credentials: 'same-origin',
  headers: {
    'Accept': 'application/json',
    'X-CSRF-Token': csrfToken
  }
};

class ProjectMembers extends React.Component {
  constructor(props) {
    super(props);
    this.state = { users: [] };

    this.toggleRelated = this.toggleRelated.bind(this);
  }

  componentDidMount() {
    fetch(`${this.props.project_members_path}.json`, requestParams)
      .then(response => response.json())
      .then(users => this.setState({ users: users }));
  }

  toggleRelated(index) {
    let user = this.state.users[index];
    fetch(`${this.props.project_members_path}/${user.id}.json`, Object.assign(requestParams, { method: user.related ? 'DELETE' : 'PUT' }))
      .then(response => response.text())
      .then(() => {
        user.related = !user.related;
        let users = this.state.users;
        users[index] = user;
        this.setState({ users: users });
      });
  }

  render() {
    let users = this.state.users.map((user, i) => {
      return <ProjectMember user={user} index={i} key={user.id} toggleRelated={this.toggleRelated} />
    });

    return (
      <section className="project-members">
        <div className="list-group">
          {users}
        </div>
      </section>
    );
  }
}

class ProjectMember extends React.Component {
  constructor(props) {
    super(props);

    this.onClick = this.onClick.bind(this);
  }

  onClick(event) {
    event.preventDefault();
    this.props.toggleRelated(this.props.index);
  }

  render() {
    if (this.props.user.related) {
      return (
        <a href="#" className="list-group-item list-group-item-success" onClick={this.onClick}>
          <strong>{this.props.user.name}</strong>
        </a>
      );
    } else {
      return (
        <a href="#" className="list-group-item" onClick={this.onClick}>
          {this.props.user.name}
        </a>
      );
    }
  }
}

function initializeProjectMembers() {
  let container = document.getElementById('project_members');
  if (!container) return;
  ReactDOM.render(
    <ProjectMembers project_members_path={container.dataset.projectMembersPath} />,
    container
  );
}

function cleanupProjectMembers() {
  let container = document.getElementById('project_members');
  if (!container) return;
  ReactDOM.unmountComponentAtNode(container);
}

// DOMContentLoadedとturbo:loadの両方に対応
document.addEventListener('DOMContentLoaded', initializeProjectMembers);
document.addEventListener('turbo:load', initializeProjectMembers);
document.addEventListener('turbo:before-render', cleanupProjectMembers);