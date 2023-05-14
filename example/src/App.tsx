import * as React from 'react';

import { StyleSheet, View } from 'react-native';
import { RnVdocipherPlayerByAjayView } from 'rn-vdocipher-player-by-ajay';

export default function App() {
  const [counter, setCounter] = React.useState<number>(0);
  return (
    <View style={styles.container}>
      <RnVdocipherPlayerByAjayView
        color="black"
        style={styles.box}
        value={counter}
        leftButtonText={'Minus'}
        rightButtonText={'Plus'}
        onPressLeftButton={() => setCounter(counter - 1)}
        onPressRightButton={() => setCounter(counter + 1)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: '100%',
    height: 60,
    marginVertical: 20,
  },
});
