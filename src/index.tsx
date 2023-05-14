import {
  requireNativeComponent,
  UIManager,
  Platform,
  // ViewStyle,
} from 'react-native';

const LINKING_ERROR =
  `The package 'rn-vdocipher-player-by-ajay' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

// type RnVdocipherPlayerByAjayProps = {
//   color: string;
//   style: ViewStyle;
// };

const ComponentName = 'VideoPlayerView';

export const RnVdocipherPlayerByAjayView =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<any>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };
