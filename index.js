import {AppRegistry} from 'react-native';
import App from './src/App';
import NewsList from './src/NewsList';
import NewsDetail from './src/NewsDetail';
import SettingsPage from './src/SettingsPage';
import {withProvider} from './src/withProvider';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => withProvider(App));
AppRegistry.registerComponent('NewsList', () => withProvider(NewsList));
AppRegistry.registerComponent('NewsDetail', () => withProvider(NewsDetail));
AppRegistry.registerComponent('SettingsPage', () => withProvider(SettingsPage));
