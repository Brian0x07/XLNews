import React, {useEffect, useState} from 'react';
import {
  FlatList,
  StyleSheet,
  Text,
  View,
  Image,
  TouchableOpacity,
  NativeModules,
  TurboModuleRegistry,
  ActivityIndicator,
} from 'react-native';
import {useAppSelector} from './store';
import {getColors, getFontSizes} from './theme';

const NavigationBridge =
  TurboModuleRegistry.get('NavigationBridge') ||
  NativeModules.NavigationBridge;

const NewsDataBridge = NativeModules.NewsDataBridge;

interface NewsItem {
  id: string;
  title: string;
  summary: string;
  body: string;
  image: string;
  source: string;
  time: string;
}

const NewsListItem: React.FC<{
  item: NewsItem;
  onPress: () => void;
  colors: ReturnType<typeof getColors>;
  fonts: ReturnType<typeof getFontSizes>;
}> = ({item, onPress, colors, fonts}) => (
  <TouchableOpacity onPress={onPress} activeOpacity={0.7}>
    <View style={[styles.itemContainer, {backgroundColor: colors.card}]}>
      <Image source={{uri: item.image}} style={[styles.itemImage, {backgroundColor: colors.imagePlaceholder}]} />
      <View style={styles.itemContent}>
        <Text
          style={[styles.itemTitle, {color: colors.textPrimary, fontSize: fonts.title}]}
          numberOfLines={2}>
          {item.title}
        </Text>
        <Text
          style={[styles.itemSummary, {color: colors.textSecondary, fontSize: fonts.body - 2}]}
          numberOfLines={2}>
          {item.summary}
        </Text>
        <View style={styles.itemMeta}>
          <Text style={[styles.itemSource, {color: colors.accent, fontSize: fonts.caption}]}>
            {item.source}
          </Text>
          <Text style={[styles.itemTime, {color: colors.textTertiary, fontSize: fonts.caption}]}>
            {item.time}
          </Text>
        </View>
      </View>
    </View>
  </TouchableOpacity>
);

const NewsList: React.FC<{category?: string}> = ({category = 'trending'}) => {
  const {theme, fontSize} = useAppSelector(state => state.settings);
  const colors = getColors(theme);
  const fonts = getFontSizes(fontSize);

  const [news, setNews] = useState<NewsItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadNews();
  }, [category]);

  const loadNews = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await NewsDataBridge.fetchNewsFeed(category);
      setNews(data);
    } catch (e: any) {
      setError(e.message || 'Failed to load news');
    } finally {
      setLoading(false);
    }
  };

  const onPressItem = (item: NewsItem) => {
    NavigationBridge?.pushNewsDetail({
      title: item.title,
      body: item.body,
      image: item.image,
      source: item.source,
      time: item.time,
    });
  };

  if (loading) {
    return (
      <View style={[styles.center, {backgroundColor: colors.background}]}>
        <ActivityIndicator size="large" color={colors.accent} />
      </View>
    );
  }

  if (error) {
    return (
      <View style={[styles.center, {backgroundColor: colors.background}]}>
        <Text style={[styles.errorText, {color: colors.textSecondary, fontSize: fonts.body}]}>
          {error}
        </Text>
        <TouchableOpacity onPress={loadNews} style={[styles.retryButton, {backgroundColor: colors.accent}]}>
          <Text style={[styles.retryText, {fontSize: fonts.body}]}>Retry</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={[styles.container, {backgroundColor: colors.background}]}>
      <FlatList
        data={news}
        keyExtractor={item => item.id}
        renderItem={({item}) => (
          <NewsListItem
            item={item}
            onPress={() => onPressItem(item)}
            colors={colors}
            fonts={fonts}
          />
        )}
        contentContainerStyle={styles.listContent}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
        automaticallyAdjustContentInsets={true}
        contentInsetAdjustmentBehavior="automatic"
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  center: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorText: {
    marginBottom: 16,
  },
  retryButton: {
    paddingHorizontal: 24,
    paddingVertical: 10,
    borderRadius: 8,
  },
  retryText: {
    color: '#FFFFFF',
    fontWeight: '600',
  },
  listContent: {
    padding: 16,
  },
  itemContainer: {
    flexDirection: 'row',
    borderRadius: 10,
    padding: 12,
  },
  itemImage: {
    width: 90,
    height: 90,
    borderRadius: 8,
  },
  itemContent: {
    flex: 1,
    marginLeft: 12,
    justifyContent: 'space-between',
  },
  itemTitle: {
    fontWeight: '600',
    lineHeight: 22,
  },
  itemSummary: {
    lineHeight: 18,
    marginTop: 4,
  },
  itemMeta: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 6,
  },
  itemSource: {},
  itemTime: {},
  separator: {
    height: 10,
  },
});

export default NewsList;
