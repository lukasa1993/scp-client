import React from 'react';
import { Col, Grid } from 'react-native-easy-grid';
import { StackNavigator } from 'react-navigation';
import SSHServer from '../components/SSHServer';

export default class ServerScreen extends React.Component {
  static navigationOptions = ({ navigation }) => {
    const params = navigation.state.params || {};

    return {
      title: params.server.name
    };
  };

  constructor() {
    super();

    this.state = {
      ssh_config: {}
    };
  }

  componentWillMount() {
    const serverConfig = {
      host:     this.props.navigation.state.params.server.host,
      port:     this.props.navigation.state.params.server.port,
      username: this.props.navigation.state.params.server.user,
      password: this.props.navigation.state.params.server.pass
    };

    this.setState({ ssh_config: serverConfig });
  }

  render() {
    const colStyle      = {
      padding:     4,
      borderWidth: 1,
      borderColor: '#d6d7da'
    };
    const LeftNavigator = StackNavigator({
      SSHServer: {
        screen: SSHServer
      }
    }, {
      headerMode: 'none'
    });

    const RightNavigator = StackNavigator({
      SSHServer: {
        screen: SSHServer
      }
    }, {
      headerMode: 'none'
    });

    return (
      <Grid>
        <Col style={colStyle}>
          <LeftNavigator screenProps={this.state.ssh_config}/>
        </Col>
        <Col style={colStyle}>
          <RightNavigator screenProps={this.state.ssh_config}/>
        </Col>
      </Grid>
    );
  }
}
