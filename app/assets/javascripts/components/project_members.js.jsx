var ProjectMembers = React.createClass({
  getInitialState: function() {
    return { users: [] }
  },

  componentDidMount: function() {
    $.ajax(this.props.resource_url + '.json', {
      method: 'GET',
      dataType: 'json'
    }).done(
      function(response) {
        this.setState({ users: response });
      }.bind(this)
    );
  },

  toggleRelated: function(index) {
    var user = this.state.users[index];
    $.ajax(this.props.resource_url + '/' + user.id + '.json', {
      method: user.related ? 'DELETE' : 'PUT',
      dataType: 'text'
    }).done(
      function(response) {
        user.related = !user.related;
        var users = this.state.users;
        users[index] = user;
        this.setState({ users: users });
      }.bind(this)
    );
  },

  render: function() {
    var users = this.state.users.map(function(user, i) {
      return <ProjectMember user={user} index={i} key={user.id} onClick={this.toggleRelated} />
    }, this);

    return (
      <section className="project-members">
        <div className="list-group">
          {users}
        </div>
      </section>
    );
  }
});

var ProjectMember = React.createClass({
  onClick: function(event) {
    event.preventDefault();
    this.props.onClick(this.props.index);
  },

  render: function() {
    if (this.props.user.related) {
      return (<a href="#" className="list-group-item list-group-item-success" onClick={this.onClick}>
        <strong>{this.props.user.name}</strong>
      </a>);
    } else {
      return (
        <a href="#" className="list-group-item" onClick={this.onClick}>
          {this.props.user.name}
        </a>
      );
    }
  }
});