import {ThemeMode, FontSize} from './store/settingsSlice';

export interface ThemeColors {
  background: string;
  card: string;
  textPrimary: string;
  textSecondary: string;
  textTertiary: string;
  accent: string;
  divider: string;
  imagePlaceholder: string;
}

const darkColors: ThemeColors = {
  background: '#171719',
  card: '#1C1C21',
  textPrimary: '#E8E8ED',
  textSecondary: '#8E8E93',
  textTertiary: '#5A5A5E',
  accent: '#6690FF',
  divider: '#2A2A30',
  imagePlaceholder: '#2A2A30',
};

const lightColors: ThemeColors = {
  background: '#F2F2F7',
  card: '#FFFFFF',
  textPrimary: '#1C1C1E',
  textSecondary: '#6C6C70',
  textTertiary: '#AEAEB2',
  accent: '#4A6EE0',
  divider: '#E5E5EA',
  imagePlaceholder: '#E5E5EA',
};

export function getColors(theme: ThemeMode): ThemeColors {
  return theme === 'dark' ? darkColors : lightColors;
}

export interface FontSizes {
  body: number;
  title: number;
  caption: number;
  detail: number;
  detailTitle: number;
}

export function getFontSizes(size: FontSize): FontSizes {
  switch (size) {
    case 'small':
      return {body: 13, title: 14, caption: 11, detail: 14, detailTitle: 19};
    case 'large':
      return {body: 17, title: 18, caption: 14, detail: 18, detailTitle: 26};
    default:
      return {body: 15, title: 16, caption: 12, detail: 16, detailTitle: 22};
  }
}
