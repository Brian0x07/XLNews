import React from 'react';
import {StyleSheet, Text, View, TouchableOpacity, ScrollView, NativeModules} from 'react-native';
import {useAppDispatch, useAppSelector} from './store';
import {setTheme, setFontSize, ThemeMode, FontSize} from './store/settingsSlice';
import {getColors, getFontSizes} from './theme';

const {SettingsBridge} = NativeModules;

const THEME_OPTIONS: {label: string; value: ThemeMode}[] = [
  {label: 'Dark', value: 'dark'},
  {label: 'Light', value: 'light'},
];

const FONT_OPTIONS: {label: string; value: FontSize}[] = [
  {label: 'Small', value: 'small'},
  {label: 'Medium', value: 'medium'},
  {label: 'Large', value: 'large'},
];

const SettingsPage: React.FC = () => {
  const dispatch = useAppDispatch();
  const {theme, fontSize} = useAppSelector(state => state.settings);
  const colors = getColors(theme);
  const fonts = getFontSizes(fontSize);

  const onThemeChange = (value: ThemeMode) => {
    dispatch(setTheme(value));
    SettingsBridge?.applyTheme(value);
  };

  const onFontSizeChange = (value: FontSize) => {
    dispatch(setFontSize(value));
  };

  return (
    <View style={[styles.container, {backgroundColor: colors.background}]}>
      <ScrollView
        contentContainerStyle={styles.content}
        automaticallyAdjustContentInsets={true}
        contentInsetAdjustmentBehavior="automatic">
        {/* Theme */}
        <Text style={[styles.sectionTitle, {color: colors.textSecondary}]}>
          Theme
        </Text>
        <View style={[styles.card, {backgroundColor: colors.card}]}>
          {THEME_OPTIONS.map(opt => (
            <TouchableOpacity
              key={opt.value}
              style={styles.row}
              onPress={() => onThemeChange(opt.value)}>
              <Text
                style={[
                  styles.rowLabel,
                  {color: colors.textPrimary, fontSize: fonts.body},
                ]}>
                {opt.label}
              </Text>
              {theme === opt.value && (
                <Text style={[styles.check, {color: colors.accent}]}>✓</Text>
              )}
            </TouchableOpacity>
          ))}
        </View>

        {/* Font Size */}
        <Text style={[styles.sectionTitle, {color: colors.textSecondary}]}>
          Font Size
        </Text>
        <View style={[styles.card, {backgroundColor: colors.card}]}>
          {FONT_OPTIONS.map(opt => (
            <TouchableOpacity
              key={opt.value}
              style={styles.row}
              onPress={() => onFontSizeChange(opt.value)}>
              <Text
                style={[
                  styles.rowLabel,
                  {color: colors.textPrimary, fontSize: fonts.body},
                ]}>
                {opt.label}
              </Text>
              {fontSize === opt.value && (
                <Text style={[styles.check, {color: colors.accent}]}>✓</Text>
              )}
            </TouchableOpacity>
          ))}
        </View>

        {/* Preview */}
        <Text style={[styles.sectionTitle, {color: colors.textSecondary}]}>
          Preview
        </Text>
        <View style={[styles.card, {backgroundColor: colors.card}]}>
          <View style={styles.previewRow}>
            <Text
              style={{
                fontSize: getFontSizes(fontSize).detailTitle,
                fontWeight: '700',
                color: colors.textPrimary,
              }}>
              Headline
            </Text>
          </View>
          <View style={styles.previewRow}>
            <Text
              style={{
                fontSize: getFontSizes(fontSize).body,
                color: colors.textSecondary,
                lineHeight: getFontSizes(fontSize).body * 1.6,
              }}>
              This is how body text will appear in articles and news content
              throughout the app.
            </Text>
          </View>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    padding: 20,
    paddingBottom: 40,
  },
  sectionTitle: {
    fontSize: 13,
    fontWeight: '600',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 8,
    marginTop: 24,
    marginLeft: 4,
  },
  card: {
    borderRadius: 12,
    overflow: 'hidden',
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  rowLabel: {
    fontWeight: '500',
  },
  check: {
    fontSize: 17,
    fontWeight: '600',
  },
  previewRow: {
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
});

export default SettingsPage;
