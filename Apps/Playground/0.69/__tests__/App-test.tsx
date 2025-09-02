/**
 * @format
 */

import 'react-native';
import React from 'react';

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer';

// Simple component to test basic React functionality
const TestComponent = () => <></>;

it('renders simple component correctly', () => {
  renderer.create(<TestComponent />);
});

it('can import React and React Native', () => {
  expect(React).toBeDefined();
  expect(require('react-native')).toBeDefined();
});
