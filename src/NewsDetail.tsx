import React from 'react';
import {StyleSheet, Text, View, Image, ScrollView} from 'react-native';
import {useAppSelector} from './store';
import {getColors, getFontSizes} from './theme';

interface Props {
  title: string;
  body: string;
  image: string;
  source: string;
  time: string;
}

const NewsDetail: React.FC<Props> = ({title, body, image, source, time}) => {
  const {theme, fontSize} = useAppSelector(state => state.settings);
  const colors = getColors(theme);
  const fonts = getFontSizes(fontSize);

  return (
    <View style={[styles.container, {backgroundColor: colors.background}]}>
      <ScrollView
        contentContainerStyle={styles.content}
        automaticallyAdjustContentInsets={true}
        contentInsetAdjustmentBehavior="automatic">
        <Image
          source={{uri: image}}
          style={[styles.image, {backgroundColor: colors.imagePlaceholder}]}
        />

        <View style={styles.body}>
          <Text
            style={{
              fontSize: fonts.detailTitle,
              fontWeight: '700',
              color: colors.textPrimary,
              lineHeight: fonts.detailTitle * 1.35,
            }}>
            {title}
          </Text>

          <View style={styles.meta}>
            <Text style={{fontSize: fonts.caption + 1, color: colors.accent, fontWeight: '600'}}>
              {source}
            </Text>
            <Text style={{fontSize: fonts.caption + 1, color: colors.textTertiary}}>
              {time}
            </Text>
          </View>

          <View style={[styles.divider, {backgroundColor: colors.divider}]} />

          <Text
            style={{
              fontSize: fonts.detail,
              color: colors.textSecondary,
              lineHeight: fonts.detail * 1.7,
            }}>
            {body}
          </Text>
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
    paddingBottom: 40,
  },
  image: {
    width: '100%',
    height: 220,
  },
  body: {
    padding: 20,
  },
  meta: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 12,
  },
  divider: {
    height: 1,
    marginVertical: 20,
  },
});

export default NewsDetail;
