import {
  View,
  Button,
  StyleSheet,
  NativeModules,
  NativeEventEmitter,
} from 'react-native';
import React, {PureComponent} from 'react';

const {RNManager, EventEmitManager} = NativeModules;

const eventEmitManagerEmitter = new NativeEventEmitter(EventEmitManager);

export default class FunctionBridgeDemo extends PureComponent {
  constructor(args) {
    super(args);

    this.subscription = eventEmitManagerEmitter.addListener(
      'onNotification',
      reminder => {
        console.log('监听 ==》', reminder);
      },
    );
  }

  componentWillUnmount() {
    this.subscription && this.subscription.remove();
  }

  sendMsgToNative = () => {
    RNManager.sendMegToNative(
      '提醒一下',
      '要学RN吗？',
      '11',
      result => {
        console.log('callback success ==》', result);
      },
      error => {
        console.log('callback error ==》', error);
      },
    )
    //   .then(result => {
    //     console.log('promise success  ==》', result);
    //   })
    //   .catch(error => {
    //     console.log('promise error  ==》', error);
    //   });
  };

  render() {
    return (
      <View style={styles.container}>
        <Button title="Hello Native" onPress={this.sendMsgToNative} />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'space-around',
  },
});
