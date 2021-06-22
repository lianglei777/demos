import * as React from 'react';
import {View, Text, Button, Image} from 'react-native';
import {NavigationContainer} from '@react-navigation/native';
import {createStackNavigator} from '@react-navigation/stack';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';

import WebviewDemo from './Pages/WebviewDemo';
import FunctionBridgeDemo from './Pages/FunctionBridgeDemo';
import ComponentBridgeDemo from './Pages/ComponentBridgeDemo';

const Stack = createStackNavigator();
const Tab = createBottomTabNavigator();

function HomeScreen({navigation}) {
  return (
    <View
      style={{
        flex: 1,
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'space-around',
      }}>
      <Button
        title="原生方法桥接 demo"
        onPress={() => {
          navigation.navigate('FunctionBridgeDemo');
        }}
      />
      <Button
        title="原生组件桥接 demo"
        onPress={() => {
          navigation.navigate('ComponentBridgeDemo');
        }}
      />
      <Button
        title="webview demo"
        onPress={() => {
          navigation.navigate('WebviewDemo');
        }}
      />
    </View>
  );
}

function WorkScreen({navigation}) {
  return (
    <View
      style={{
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
      }}>
      <Text> Work Screen </Text>
    </View>
  );
}

function MainScreen() {
  return (
    <Tab.Navigator
      initialRouteName="Home"
      tabBarOptions={{
        activeTintColor: '#14be4b',
        inactiveTintColor: 'gray',
      }}>
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{
          tabBarLabel: 'Home',
          tabBarIcon: ({focused, color}) => (
            <Image
              style={{
                resizeMode: 'cover',
                height: 23,
                width: 23,
              }}
              source={
                focused
                  ? require('./Images/home.png')
                  : require('./Images/home_gray.png')
              }
            />
          ),
        }}
      />
      <Tab.Screen
        name="Work"
        component={WorkScreen}
        options={{
          tabBarLabel: 'Work',
          tabBarIcon: ({focused, color}) => (
            <Image
              style={{
                resizeMode: 'cover',
                height: 23,
                width: 23,
              }}
              source={
                focused
                  ? require('./Images/work.png')
                  : require('./Images/work_gray.png')
              }
            />
          ),
        }}
      />
    </Tab.Navigator>
  );
}

function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Main"
        screenOptions={{
          gestureEnabled: false,
        }}
        // headerMode="none" // 隐藏导航栏
      >
        <Stack.Screen name="Main" component={MainScreen} />
        <Stack.Screen name="WebviewDemo" component={WebviewDemo} />
        <Stack.Screen
          name="FunctionBridgeDemo"
          component={FunctionBridgeDemo}
        />
        <Stack.Screen
          name="ComponentBridgeDemo"
          component={ComponentBridgeDemo}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default App;
