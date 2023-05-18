import * as React from 'react';

import { SafeAreaView, StyleSheet } from 'react-native';
import { RnVdocipherPlayerByAjayView } from 'rn-vdocipher-player-by-ajay';

export default function App() {
  return (
    <SafeAreaView style={styles.container}>
      <RnVdocipherPlayerByAjayView style={styles.box} />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  box: {
    width: 300,
    height: 600,
    borderWidth: 2,
    // backgroundColor: 'skyblue',
  },
});
