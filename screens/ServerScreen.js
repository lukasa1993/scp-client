import React from 'react';
import { Col, Grid } from 'react-native-easy-grid';
import { ButtonGroup, Icon } from 'react-native-elements';
import { StackNavigator } from 'react-navigation';
import SSHServer from '../components/SSHServer';

export default class ServerScreen extends React.Component {
  static navigationOptions = ({ navigation }) => {
    const params  = navigation.state.params || {};
    const buttons = [
      {
        element: () => <Icon
          name='border-left'
          color='#008cff'
        />
      },
      {
        element: () => <Icon
          name='border-vertical'
          color='#008cff'
        />
      },
      {
        element: () => <Icon
          name='border-right'
          color='#008cff'
        />
      }];

    return {
      title:       params.server.name,
      headerRight: (
                     <ButtonGroup
                       onPress={params.updateIndex}
                       selectedIndex={params.selectedIndex || 1}
                       buttons={buttons}
                     />
                   )
    };
  };

  constructor() {
    super();

    this.state = {
      ssh_config:  {},
      borderIndex: 1
    };
  }

  componentDidMount() {
    const serverConfig = {
      host:     this.props.navigation.state.params.server.host,
      port:     this.props.navigation.state.params.server.port,
      username: this.props.navigation.state.params.server.user,
      password: this.props.navigation.state.params.server.pass
    };

    this.setState({ ssh_config: serverConfig });
    this.props.navigation.setParams({ updateIndex: this._handleSideSwitch.bind(this) });
  }

  _handleSideSwitch(selectedIndex) {
    if (selectedIndex === this.state.borderIndex) {
      return;
    }

    this.setState({ borderIndex: selectedIndex });
    this.props.navigation.setParams({ selectedIndex: selectedIndex });
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
        {this.state.borderIndex === 0 || this.state.borderIndex === 1 ?
          <Col style={colStyle}>
            <LeftNavigator screenProps={this.state.ssh_config}/>
          </Col>
          : null}
        {this.state.borderIndex === 2 || this.state.borderIndex === 1 ?
          <Col style={colStyle}>
            <RightNavigator screenProps={this.state.ssh_config}/>
          </Col>
          : null}
      </Grid>
    );
  }
}
