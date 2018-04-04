import React from 'react';
import { StackNavigator } from 'react-navigation';
import AddServerScreen from '../screens/AddServerScreen';
import ServerScreen from '../screens/ServerScreen';

import MainTabNavigator from './MainTabNavigator';

const RootStackNavigator = StackNavigator(
  {
    Main:      {
      screen: MainTabNavigator
    },
    AddServer: {
      screen: AddServerScreen
    },
    Server:    {
      screen: ServerScreen
    }
  },
  {
    navigationOptions: () => ({
      headerTitleStyle: {
        fontWeight: 'normal'
      }
    })
  }
);

export default class RootNavigator extends React.Component {
  render() {
    return <RootStackNavigator/>;
  }

}
