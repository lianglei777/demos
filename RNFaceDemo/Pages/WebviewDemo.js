import {View, NativeModules, BackHandler, StyleSheet} from 'react-native';
import React, {PureComponent} from 'react';
import {WebView} from 'react-native-webview';

export default class WebviewDemo extends PureComponent {
  constructor(args) {
    super(args);
  }

  // 监听事件---状态机是否发生改变
  onNavigationStateChange(navState) {
    console.log('onNavigationStateChange -->', navState);
  }

  onLoadStart() {}

  onLoadEnd() {}

  render() {
    const injectJSStr = `
  window.injectStr='我是注入的字段';
  var div = document.getElementById('testID');
  div.style.color='red';
  div.style.fontSize='100px';
  `;

    const html = `
    <html>
    <head></head>
    <body>
      <script>
        setTimeout(function () {
          window.ReactNativeWebView.postMessage(window.injectStr)
        }, 2000)
      </script>
      <div id='testID'>Hello Word</div>
    </body>
    </html>
  `;

    return (
      // <View style={styles.container}>
      //   <WebView
      //     ref={ref => (this.webview = ref)}
      //     useWebKit={true}
      //     source={{ uri: 'https://www.baidu.com/' }}
      //     style={{ flex: 1 }}
      //     onNavigationStateChange={navState => this.onNavigationStateChange(navState)}
      //     mixedContentMode="compatibility" // Android: WebView 是否应该允许安全链接（https）页面中加载非安全链接（http）的内容,
      //   />
      // </View>

      <View style={{flex: 1}}>
        <WebView
          source={{html}}
          injectedJavaScript={injectJSStr}
          onMessage={event => {
            alert(event.nativeEvent.data);
          }}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#14bE4b',
  },
});
