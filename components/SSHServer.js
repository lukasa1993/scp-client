import _ from 'lodash';
import ParseLS from 'parse-listing';
import React from 'react';
import { ScrollView } from 'react-native';
import { List, ListItem } from 'react-native-elements';
import SSH from 'react-native-ssh';
import { NavigationActions } from 'react-navigation';

export default class SSHServer extends React.Component {
  constructor() {
    super();

    this.state = { list: [] };
    this.pwd   = '.';

    this.dispatch        = (action) => {
      this.props.navigation.dispatch(action);
      setTimeout(() => {
        this.single_dispatch = _.once(this.dispatch);
      }, 500);
    };
    this.single_dispatch = _.once(this.dispatch);
  }

  componentWillMount() {
    this.sshConfig = {
      host:     `${this.props.screenProps.host}:${this.props.screenProps.port}`,
      user:     this.props.screenProps.username,
      password: this.props.screenProps.password
    };

    try {
      console.log('path', this.props.navigation.state.params.path);
      this.pwd = this.props.navigation.state.params.path;
    } catch (e) {
      this.pwd = '.';
    }

    this.capturePWD()
        .then(this.listPWD.bind(this))
        .then(this.drawList.bind(this));
  }

  drawList(list) {
    const uiList = [];
    if (this.pwd !== '/') {
      uiList.push({
        title: '..',
        icon:  'folder',
        name:  '..'
      });
    }

    _.forEach(list, item => {
      uiList.push({
        title: item.name,
        name:  item.name,
        icon:  item.type === ParseLS.nodeTypes.DIRECTORY_TYPE ? 'folder' : 'note'
      });
    });

    this.setState({ list: uiList });
  }

  listPath(path) {
    return SSH.execute(this.sshConfig, `ls -l ${path}`).then(
      result => {
        const list = [];
        _.forEach(result, item => {
          const parsedList = ParseLS.parseEntry(item);

          if (_.isEmpty(parsedList)) {
            return;
          }

          list.push(parsedList);
        });

        return list;
      },
      error => console.log('Error:', error)
    );
  }

  listPWD() {
    return this.listPath(this.pwd);
  }

  capturePWD() {
    return SSH.execute(this.sshConfig, `cd ${this.pwd} && pwd`).then(
      result => {
        console.log('PWD', result[0]);
        this.pwd = result[0];
      },
      error => console.log('Error:', error)
    );
  }

  render() {
    return (
      <List>
        <ScrollView>
          {
            this.state.list.map((item, i) => (
              <ListItem
                key={i}
                title={item.title}
                leftIcon={{ name: item.icon }}
                onPress={() => this._handleItemPress(item)}
              />
            ))
          }
        </ScrollView>
      </List>
    );
  }

  _handleItemPress(item) {
    if (item.icon !== 'folder') {
      return;
    }

    this.single_dispatch(NavigationActions.navigate({
      routeName: 'SSHServer',
      params:    {
        path: `${this.pwd}/${item.name}`
      }
    }));
  }
}
