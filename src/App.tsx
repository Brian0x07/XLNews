import React from 'react';
import {
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  Alert,
} from 'react-native';

interface Props {
  onNavigateToSwift?: () => void;
}

const RNHomeScreen: React.FC<Props> = ({onNavigateToSwift}) => {
  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#ffffff" />
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.header}>
          <Text style={styles.title}>React Native 页面</Text>
          <Text style={styles.subtitle}>集成到现有 Swift 项目中</Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>功能展示</Text>
          <Text style={styles.cardText}>
            这是 React Native 编写的界面，可以和 SwiftUI 无缝混合使用。
          </Text>
        </View>

        <View style={styles.buttonContainer}>
          <TouchableOpacity
            style={styles.button}
            onPress={() => Alert.alert('提示', 'RN 按钮点击成功！')}>
            <Text style={styles.buttonText}>RN 按钮</Text>
          </TouchableOpacity>

          {onNavigateToSwift && (
            <TouchableOpacity
              style={[styles.button, styles.swiftButton]}
              onPress={onNavigateToSwift}>
              <Text style={styles.buttonText}>返回 Swift 页面</Text>
            </TouchableOpacity>
          )}
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  scrollContent: {
    padding: 20,
  },
  header: {
    marginBottom: 24,
    alignItems: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1a1a1a',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#666666',
  },
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 20,
    marginBottom: 24,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1a1a1a',
    marginBottom: 8,
  },
  cardText: {
    fontSize: 15,
    color: '#555555',
    lineHeight: 22,
  },
  buttonContainer: {
    gap: 12,
  },
  button: {
    backgroundColor: '#007AFF',
    borderRadius: 10,
    paddingVertical: 14,
    paddingHorizontal: 24,
    alignItems: 'center',
  },
  swiftButton: {
    backgroundColor: '#34C759',
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
});

export default RNHomeScreen;
