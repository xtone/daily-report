var MyProjectList = React.createClass({
  componentDidMount: function() {

  },

  render: function() {
    var projects = JSON.parse(this.props.data).map(function(project) {
      return <MyProject project={project} key={project.id} />;
    });
    return (
      <ul id={this.props.id} className="list-group">
        {projects}
      </ul>
    );
  }
});

var MyProject = React.createClass({
  render: function() {
    return (
      <li className="list-group-item">
        <div>{this.props.project.name}</div>
        <RemoveButton projectId={this.props.project.id} />
      </li>
    );
  }
});

var RemoveButton = React.createClass({
  onSubmit: function(event) {
    event.preventDefault();
  },

  render: function() {
    var action = '/settings/projects/' + this.props.projectId + '.json'
    return (
      <form action={action} method="delete" onSubmit={this.onSubmit}>
        <input className="btn btn-danger" type="submit" value="削除" />
      </form>
    );
  }
});

var AllProjectList = React.createClass({
  componentDidMount: function() {

  },

  render: function() {
    var projects = JSON.parse(this.props.data).map(function(project) {
      return <Project name={project.name} name_reading={project.name_reading} key={project.id} />;
    });
    return (
      <ul id={this.props.id} className="list-group">
        {projects}
      </ul>
    );
  }
});

var Project = React.createClass({
  render: function() {
    return (
      <li className="list-group-item">
        <AddButton projectId={this.props.projectId} />
        <div>{this.props.name}</div>
      </li>
    );
  }
});

var AddButton = React.createClass({
  onSubmit: function(event) {
    event.preventDefault();
  },

  render: function() {
    var action = '/settings/projects.json'
    return (
      <form action={action} method="post" onSubmit={this.onSubmit}>
        <input type="hidden" name="project_id" value={this.props.projectId} />
        <input className="btn btn-success" type="submit" value="追加" />
      </form>
    );
  }
});