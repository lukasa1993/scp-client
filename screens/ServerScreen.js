import React from 'react';
import { Col, Grid } from 'react-native-easy-grid';
import { SSHServer } from '../components/SSHServer';

export default class ServerScreen extends React.Component {
  static navigationOptions = ({ navigation }) => {
    const params = navigation.state.params || {};

    return {
      title: params.server.host
    };
  };

  constructor() {
    super();

    const serverConfig = {
      host:     this.props.navigation.state.params.server.host,
      username: this.props.navigation.state.params.server.user,
      password: this.props.navigation.state.params.server.pass
    };

    this.leftSSH = {};

    this.rightSSH = {};
  }

  render() {
    return (
      <Grid>
        <Col>
          <SSHServer SSHClient={this.leftSSH}/>
        </Col>
        <Col>
          <SSHServer SSHClient={this.rightSSH}/>
        </Col>
      </Grid>
    );
  }
}
