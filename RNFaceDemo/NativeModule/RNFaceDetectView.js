/**
 * 原生桥接的相机组件，可以标记识别人脸
 *  */

import React, {Component} from 'react';
import {requireNativeComponent} from 'react-native';

const RCTFaceDetectView = requireNativeComponent(
  'RCTFaceDetectView', // 此名称必须和原生封装的 RCTFaceDetectView.h 名称一致
  RNFaceDetectView,
);

const FACE_REF_KEY = 'face_ref_key';

export default class RNFaceDetectView extends Component {
  _onChange = event => {
    const onFaceCallback = this.props.onFaceCallback;
    onFaceCallback && onFaceCallback(event.nativeEvent);
  };

  render() {
    return (
      <RCTFaceDetectView
        ref={FACE_REF_KEY}
        // eslint-disable-next-line react/jsx-props-no-spreading
        {...this.props}
        onChange={this._onChange}>
        {/* 子组件插槽 */}
        {this.props.children}
      </RCTFaceDetectView>
    );
  }
}
