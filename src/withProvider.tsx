import React from 'react';
import {Provider} from 'react-redux';
import {store} from './store';

export function withProvider<P extends object>(
  Component: React.ComponentType<P>,
): React.FC<P> {
  return (props: P) => (
    <Provider store={store}>
      <Component {...props} />
    </Provider>
  );
}
