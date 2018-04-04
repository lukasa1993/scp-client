import _ from 'lodash';
import React from 'react';
import { AsyncStorage, ScrollView } from 'react-native';
import { Button, Divider, FormInput, FormLabel } from 'react-native-elements';

export default class AddServerScreen extends React.Component {
  static navigationOptions = ({ navigation }) => {
    const params = navigation.state.params || {};

    return {
      title:       'SSH List',
      headerRight: (
                     <Icon
                       raised
                       name='plus-circle'
                       type='font-awesome'
                       color='#008cff'
                       onPress={params.handleAddPress}/>
                   )
    };
  };

  constructor() {
    super();

    this.state = {
      name: '',
      host: '',
      port: '',
      user: '',
      pass: ''
    };
  }

  render() {
    return (
      <ScrollView>
        <FormLabel>Name</FormLabel>
        <FormInput onChangeText={text => this.setState({ name: text })}/>
        <FormLabel>Host</FormLabel>
        <FormInput onChangeText={text => this.setState({ host: text })}/>
        <FormLabel>Port</FormLabel>
        <FormInput keyboardType='numeric' onChangeText={text => this.setState({ port: text })}/>
        <FormLabel>User</FormLabel>
        <FormInput onChangeText={text => this.setState({ user: text })}/>
        <FormLabel>Password</FormLabel>
        <FormInput onChangeText={text => this.setState({ pass: text })}/>
        <Divider style={{ marginVertical: 10 }}/>
        <Button raised large rounded title='Add Server' onPress={this._handleAddServer.bind(this)}
                buttonStyle={{ backgroundColor: 'blue' }}/>
      </ScrollView>

    );
  }

  _handleAddServer() {
    AsyncStorage.getItem('@SSHServerStore:list')
                .then(ssh_list => {
                  ssh_list = _.isString(ssh_list) ? JSON.parse(ssh_list) : ssh_list;
                  ssh_list = _.castArray(ssh_list);

                  ssh_list.push(this.state.host);
                  return AsyncStorage.setItem('@SSHServerStore:list', JSON.stringify(ssh_list));
                })
                .then(() => AsyncStorage.setItem(`@SSHServerStore:${this.state.host}`, JSON.stringify(this.state)))
                .then(() => {
                    if (_.isFunction(this.props.navigation.state.params.dataChanged)) {
                      this.props.navigation.state.params.dataChanged();
                    }
                    this.props.navigation.goBack();
                  }
                )
                .catch(e => console.log(e));

  }
}
