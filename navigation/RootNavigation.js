import React from 'react';
import { StackNavigator } from 'react-navigation';
import HomeScreen from '../screens/HomeScreen';
import AddServerScreen from '../screens/AddServerScreen';
import ServerScreen from '../screens/ServerScreen';

const RootStackNavigator = StackNavigator(
  {
    Main:      {
      screen: HomeScreen
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
