import React, { PureComponent } from 'react';
import {
    View, Button, StyleSheet, NativeModules, NativeEventEmitter, NativeAppEventEmitter, Dimensions
} from 'react-native';

import Slider from '@react-native-community/slider';
import { makeAutoObservable } from 'mobx';
import { observer } from 'mobx-react'


// import { GET, POST } from './Request/HttpRequest';
import RNFaceDetectView from '../NativeModule/RNFaceDetectView';

var {height, width} = Dimensions.get('window');


class faceStore  {

  constructor(){
      makeAutoObservable(this)
  }

  level = '0'

  onChangeSlider = (value) => {

    this.level = Math.floor(value) * 0.1 + '';

    // console.log('this.level: ', this.level);
  }

};

const store =  new faceStore();

@observer
export default class ComponentBridgeDemo extends PureComponent {

    constructor(args) {
        super(args);

    }


    componentWillUnmount() {}

    render() {

        return (
          <View style={{position:'relative' ,flex:1,flexDirection: "column", alignItems:'center',justifyContent:'center'}}>

            <RNFaceDetectView
              beautyLevel={store.level}
              ref="facedetectview"
              style={{width,height}}
              onFaceCallback={(e) => { 
                  e.persist();

                //   console.log('人脸个数 ==>', e.nativeEvent.detectFaceCount);
              }}
            /> 

            <Slider
              style={{ position:'absolute', bottom: 0, width, height: 40 }}
              minimumValue={0}
              maximumValue={10}
              onValueChange={store.onChangeSlider}
              minimumTrackTintColor="#FFFFFF"
              maximumTrackTintColor="#000000"
            />
          </View>
        )

    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#14bE4b',
    },
});
