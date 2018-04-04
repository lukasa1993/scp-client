import React from 'react';
import { List, ListItem } from 'react-native-elements';

export class SSHServer extends React.Component {
  constructor() {
    super();

    this.state = {
      list: []
    };
  }

  render() {
    return <List>
      {
        this.state.list.map((item, i) => (
          <ListItem
            key={i}
            title={item.title}
            leftIcon={{ name: item.icon }}
          />
        ))
      }
    </List>
      ;
  }
}
