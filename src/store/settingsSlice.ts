import {createSlice, PayloadAction} from '@reduxjs/toolkit';

export type ThemeMode = 'dark' | 'light';
export type FontSize = 'small' | 'medium' | 'large';

interface SettingsState {
  theme: ThemeMode;
  fontSize: FontSize;
}

const initialState: SettingsState = {
  theme: 'dark',
  fontSize: 'medium',
};

const settingsSlice = createSlice({
  name: 'settings',
  initialState,
  reducers: {
    setTheme(state, action: PayloadAction<ThemeMode>) {
      state.theme = action.payload;
    },
    setFontSize(state, action: PayloadAction<FontSize>) {
      state.fontSize = action.payload;
    },
  },
});

export const {setTheme, setFontSize} = settingsSlice.actions;
export default settingsSlice.reducer;
