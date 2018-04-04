import _ from 'lodash';
import React from 'react';
import { AsyncStorage, Platform, StyleSheet } from 'react-native';
import { Icon, List, ListItem } from 'react-native-elements';
import { NavigationActions } from 'react-navigation';

export default class HomeScreen extends React.Component {
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
      list: []
    };

    this._loadServers();

    this.dispatch        = (action) => {
      this.props.navigation.dispatch(action);
      setTimeout(() => {
        this.single_dispatch = _.once(this.dispatch);
      }, 500);
    };
    this.single_dispatch = _.once(this.dispatch);
  }

  _loadServers() {
    const self = this;
    AsyncStorage.getItem('@SSHServerStore:list')
                .then(ssh_list => {
                  ssh_list = _.isString(ssh_list) ? JSON.parse(ssh_list) : ssh_list;
                  ssh_list = _.castArray(ssh_list);

                  const promises = [];
                  const list     = [];
                  _.forEach(ssh_list, host => {
                    promises.push(AsyncStorage.getItem(`@SSHServerStore:${host}`)
                                              .then(ssh_server => {
                                                if (_.isEmpty(ssh_server)) {
                                                  return;
                                                }
                                                ssh_server = _.isString(ssh_server) ? JSON.parse(ssh_server) : ssh_list;
                                                list.push({
                                                  title: ssh_server.name,
                                                  host:  ssh_server.host,
                                                  icon:  'computer'
                                                });
                                              }));
                  });

                  return Promise.all(promises).then(() => self.setState({ list: list }));
                });
  }

  componentWillMount() {
    this.props.navigation.setParams({ handleAddPress: this._handleAddPress });
  }

  render() {
    return (
      <List>
        {
          this.state.list.map((item, i) => (
            <ListItem
              hideChevron
              key={i}
              title={item.title}
              leftIcon={{ name: item.icon }}
              onPress={() => this._handleServerPress(item.host)}
            />
          ))
        }
      </List>

    );
  }

  _handleServerPress(host) {
    this.single_dispatch(NavigationActions.navigate({
      routeName: 'Server',
      params:    {
        server: host
      }
    }));
  }

  _handleAddPress = () => {
    this.single_dispatch(NavigationActions.navigate({
      routeName: 'AddServer',
      params:    {
        dataChanged: () => {
          this._loadServers();
        }
      }
    }));
  };
}

const styles = StyleSheet.create({
  container:              {
    flex:            1,
    backgroundColor: '#fff'
  },
  developmentModeText:    {
    marginBottom: 20,
    color:        'rgba(0,0,0,0.4)',
    fontSize:     14,
    lineHeight:   19,
    textAlign:    'center'
  },
  contentContainer:       {
    paddingTop: 30
  },
  welcomeContainer:       {
    alignItems:   'center',
    marginTop:    10,
    marginBottom: 20
  },
  welcomeImage:           {
    width:      100,
    height:     80,
    resizeMode: 'contain',
    marginTop:  3,
    marginLeft: -10
  },
  getStartedContainer:    {
    alignItems:       'center',
    marginHorizontal: 50
  },
  homeScreenFilename:     {
    marginVertical: 7
  },
  codeHighlightText:      {
    color: 'rgba(96,100,109, 0.8)'
  },
  codeHighlightContainer: {
    backgroundColor:   'rgba(0,0,0,0.05)',
    borderRadius:      3,
    paddingHorizontal: 4
  },
  getStartedText:         {
    fontSize:   17,
    color:      'rgba(96,100,109, 1)',
    lineHeight: 24,
    textAlign:  'center'
  },
  tabBarInfoContainer:    {
    position:        'absolute',
    bottom:          0,
    left:            0,
    right:           0,
    ...Platform.select({
      ios:     {
        shadowColor:   'black',
        shadowOffset:  { height: -3 },
        shadowOpacity: 0.1,
        shadowRadius:  3
      },
      android: {
        elevation: 20
      }
    }),
    alignItems:      'center',
    backgroundColor: '#fbfbfb',
    paddingVertical: 20
  },
  tabBarInfoText:         {
    fontSize:  17,
    color:     'rgba(96,100,109, 1)',
    textAlign: 'center'
  },
  navigationFilename:     {
    marginTop: 5
  },
  helpContainer:          {
    marginTop:  15,
    alignItems: 'center'
  },
  helpLink:               {
    paddingVertical: 15
  },
  helpLinkText:           {
    fontSize: 14,
    color:    '#2e78b7'
  }
});
