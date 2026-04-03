import React from 'react';
import {
  FlatList,
  StyleSheet,
  Text,
  View,
  Image,
  TouchableOpacity,
  NativeModules,
  TurboModuleRegistry,
} from 'react-native';
import {useAppSelector} from './store';
import {getColors, getFontSizes} from './theme';

const NavigationBridge =
  TurboModuleRegistry.get('NavigationBridge') ||
  NativeModules.NavigationBridge;

interface NewsItem {
  id: string;
  title: string;
  summary: string;
  body: string;
  image: string;
  source: string;
  time: string;
}

const NEWS_DATA: NewsItem[] = [
  {
    id: '1',
    title: 'SpaceX Starship Completes Fifth Test Flight with Booster Catch',
    summary:
      'SpaceX successfully caught the Super Heavy booster with the launch tower during the fifth Starship test flight.',
    body: "SpaceX has achieved a historic milestone by successfully catching the Super Heavy booster with the launch tower's mechanical arms during the fifth integrated flight test of its Starship vehicle.\n\nThe test flight launched from Starbase in Boca Chica, Texas, with the full Starship stack reaching orbital velocity before the upper stage performed a controlled splashdown in the Indian Ocean.\n\nThis achievement represents a fundamental breakthrough in rocket reusability. Unlike SpaceX's Falcon 9 boosters, which land on drone ships or landing pads, the tower-catch approach eliminates the need for landing legs, reducing weight and enabling rapid turnaround between flights.\n\nElon Musk stated that this success brings SpaceX closer to its goal of making space travel affordable, with Starship flights potentially costing as little as $10 million per launch once fully operational.",
    image: 'https://picsum.photos/seed/spacex/400/300',
    source: 'Space News',
    time: '2h ago',
  },
  {
    id: '2',
    title: 'Apple Unveils M5 Chip with Record-Breaking Performance',
    summary:
      'Apple announced its next-generation M5 chip built on 3nm process, delivering 40% faster CPU and 50% faster GPU.',
    body: "Apple has officially unveiled the M5 chip at its Spring event, marking a significant leap in silicon performance for Mac and iPad devices.\n\nBuilt on TSMC's second-generation 3-nanometer process, the M5 features a 14-core CPU with 6 performance cores and 8 efficiency cores, along with a 12-core GPU.\n\nBenchmark results show the M5 delivering approximately 40% faster single-core CPU performance and 50% faster GPU performance compared to the M4.\n\nThe first devices featuring the M5 chip will be available for pre-order starting next week.",
    image: 'https://picsum.photos/seed/apple5/400/300',
    source: 'The Verge',
    time: '3h ago',
  },
  {
    id: '3',
    title: 'WHO Approves First Malaria Vaccine for Widespread Use in Children',
    summary:
      'The WHO has approved a second-generation malaria vaccine with 78% efficacy for children in high-risk regions.',
    body: "The World Health Organization announced the approval of a groundbreaking second-generation malaria vaccine, R21/Matrix-M, for widespread use in children aged 5 months to 3 years.\n\nDeveloped by the University of Oxford in partnership with the Serum Institute of India, the vaccine demonstrated 78% efficacy in clinical trials.\n\nMalaria remains one of the world's deadliest diseases, killing over 600,000 people annually. The vaccine requires three initial doses followed by a booster, at approximately $3 per dose.",
    image: 'https://picsum.photos/seed/malaria/400/300',
    source: 'Reuters Health',
    time: '5h ago',
  },
  {
    id: '4',
    title: 'AI Drug Discovery Platform Identifies New Antibiotic in Record Time',
    summary:
      'Researchers used deep learning to screen 100 million compounds in 30 days, identifying a novel antibiotic effective against drug-resistant bacteria.',
    body: 'Researchers at MIT and Harvard have used an artificial intelligence platform to discover a new class of antibiotics capable of killing drug-resistant bacteria, completing in just 30 days what traditionally takes years.\n\nThe AI model screened over 100 million chemical structures and identified a compound called halicin-2 that effectively kills methicillin-resistant Staphylococcus aureus (MRSA).\n\nIn laboratory tests, the compound successfully treated MRSA infections in mice with no observable toxicity to human cells. Phase 1 clinical trials are planned for later this year.',
    image: 'https://picsum.photos/seed/aidrug/400/300',
    source: 'Nature Medicine',
    time: '6h ago',
  },
  {
    id: '5',
    title: 'Tesla Robotaxi Service Launches Public Beta in San Francisco',
    summary:
      "Tesla has opened its autonomous ride-hailing service to the public in San Francisco with 500 vehicles.",
    body: "Tesla has officially launched its Robotaxi service in San Francisco, making 500 autonomous vehicles available to the public through the Tesla app.\n\nThe service operates 18 hours per day at approximately $0.50 per mile. Each vehicle relies entirely on Tesla's Full Self-Driving system.\n\nThe launch follows two years of limited testing during which Tesla's fleet completed over 10 million miles without a serious incident.",
    image: 'https://picsum.photos/seed/tesla/400/300',
    source: 'TechCrunch',
    time: '8h ago',
  },
  {
    id: '6',
    title: 'Global Renewable Energy Surpasses 50% of Electricity Generation',
    summary:
      'The IEA reports renewable sources exceeded 50% of global electricity production for the first time in Q1 2026.',
    body: 'The International Energy Agency confirmed that renewable energy sources accounted for 51.3% of global electricity generation in Q1 2026.\n\nSolar power led the growth at 3.2 terawatts, followed by wind at 1.8 terawatts. The levelized cost of solar has fallen to $0.02 per kilowatt-hour in optimal locations, making it the cheapest electricity source in history.',
    image: 'https://picsum.photos/seed/renew/400/300',
    source: 'Bloomberg Green',
    time: '10h ago',
  },
  {
    id: '7',
    title: 'CRISPR Gene Therapy Cures Sickle Cell Disease in Clinical Trial',
    summary:
      'A Phase 3 trial shows CRISPR-based gene therapy eliminated sickle cell crises in 94% of patients.',
    body: "Results from a Phase 3 clinical trial show that a CRISPR-Cas9 gene therapy has effectively cured sickle cell disease in the vast majority of treated patients.\n\nOf 75 patients who completed a two-year follow-up, 71 (94.7%) were completely free of vaso-occlusive crises and able to discontinue regular blood transfusions.\n\nSickle cell disease affects approximately 20 million people worldwide. The current therapy cost is approximately $2.2 million per patient.",
    image: 'https://picsum.photos/seed/crispr/400/300',
    source: 'NEJM',
    time: '12h ago',
  },
];

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

const NewsList: React.FC = () => {
  const {theme, fontSize} = useAppSelector(state => state.settings);
  const colors = getColors(theme);
  const fonts = getFontSizes(fontSize);

  const onPressItem = (item: NewsItem) => {
    NavigationBridge?.pushNewsDetail({
      title: item.title,
      body: item.body,
      image: item.image,
      source: item.source,
      time: item.time,
    });
  };

  return (
    <View style={[styles.container, {backgroundColor: colors.background}]}>
      <FlatList
        data={NEWS_DATA}
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
