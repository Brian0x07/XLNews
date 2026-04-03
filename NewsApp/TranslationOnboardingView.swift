//import SwiftUI
//import Lottie
//
///// 同传翻译开屏引导页
///// Figma: dark 11044-20098, light 11972-80848
//struct TranslationOnboardingView: View {
//    let onStart: () -> Void
//    let onSettings: () -> Void
//    let onRecords: () -> Void
//    let onDismiss: () -> Void
//
//    /// 功能是否正在运行
//    var isActive: Bool = false
//
//    @Environment(\.colorScheme) private var colorScheme
//
//    private var isDark: Bool { colorScheme == .dark }
//    private var accentColor: Color { isDark ? Color(hex: "#19C38E") : Color(hex: "#1ACF97") }
//
//    /// 源语言名称
//    var sourceLanguage: String = "中文"
//    /// 目标语言名称
//    var targetLanguage: String = "西班牙语"
//
//    var body: some View {
//        ZStack {
//            // Figma: dark #000000, light #FFFFFF
//            (isDark ? Color.black : Color.white).ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                navBar
//
//                // Figma: Frame at y=108, 375x350
//                illustrationArea
//                    .frame(width: 375.scaled, height: 350.scaled)
//                    .padding(.top, 20.scaled)
//
//                // Figma: 标题区域 at y=458
//                titleArea
//
//                // 语言选择区 at y=634
//                languageSelector
//                    .padding(.top, 24.scaled)
//
//                Spacer()
//
//                bottomSection
//            }
//        }
//        .navigationBarBackButtonHidden()
//        .swipeBack { onDismiss() }
//    }
//
//    // MARK: - Navigation Bar
//
//    private var navBar: some View {
//        INMONavigationBar(title: NSLocalizedString("translation_simultaneous", comment: ""), isTransparent: true) {
//            Button { onDismiss() } label: {
//                Image(systemName: "chevron.left")
//                    .font(.system(size: 18, weight: .medium))
//                    .foregroundColor(isDark ? Color(hex: "#F6F6F6") : .black)
//            }
//        } trailing: {
//            Button { onSettings() } label: {
//                Image("icon_nav_settings")
//                    .renderingMode(.template)
//                    .resizable()
//                    .frame(width: 24.scaled, height: 24.scaled)
//                    .foregroundColor(isDark ? Color(hex: "#F6F6F6") : .black)
//            }
//        }
//    }
//
//    // MARK: - Illustration Area
//
//    private var illustrationArea: some View {
//        Image("translation_onboarding")
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//    }
//
//    // MARK: - Title Area
//
//    private var titleArea: some View {
//        VStack(spacing: 0) {
//            // Figma: MiSans DemiBold 26pt, gradient
//            Text(NSLocalizedString("translation_simultaneous_title", comment: ""))
//                .font(.custom("MiSans-DemiBold", size: ScreenAdapt.scaled(26)))
//                .foregroundStyle(titleGradient)
//                .frame(width: 335.scaled, height: 34.scaled)
//
//            // Figma: MiSans Light 26pt, dark #F6F6F6, light #000000
//            Text(NSLocalizedString("translation_simultaneous_subtitle", comment: ""))
//                .font(.custom("MiSans-Light", size: ScreenAdapt.scaled(26)))
//                .foregroundColor(isDark ? Color(hex: "#F6F6F6") : .black)
//                .frame(width: 335.scaled, height: 34.scaled)
//                .padding(.top, 4.scaled)
//
//            // Figma: 装饰线 gradient stroke, opacity 0.5
//            Image("prompter_decorative_line")
//                .resizable()
//                .frame(width: 126.scaled, height: 5.scaled)
//                .opacity(0.5)
//                .frame(maxWidth: .infinity, alignment: .trailing)
//                .padding(.trailing, 36.scaled)
//        }
//        .padding(.horizontal, Spacing.page.scaled)
//    }
//
//    private var titleGradient: LinearGradient {
//        if isDark {
//            LinearGradient(
//                stops: [
//                    .init(color: Color(hex: "#00FF90"), location: 0),
//                    .init(color: Color(hex: "#D2FFE5"), location: 0.78),
//                    .init(color: Color(hex: "#D2FFE5"), location: 1.0)
//                ],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//        } else {
//            LinearGradient(
//                stops: [
//                    .init(color: Color(hex: "#005037"), location: 0),
//                    .init(color: .black, location: 0.78),
//                    .init(color: .black, location: 1.0)
//                ],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//        }
//    }
//
//    // MARK: - Language Selector
//    // Figma: "中文" + "译" + "西班牙语" 一行布局
//
//    private var languageSelector: some View {
//        HStack(spacing: 16.scaled) {
//            // 源语言
//            Button(action: onSettings) {
//                HStack(spacing: 4.scaled) {
//                    Text(sourceLanguage)
//                        .font(.custom("MiSans-Medium", size: ScreenAdapt.scaled(15)))
//                        .foregroundColor(isDark ? Color(hex: "#EEEEEE") : .black)
//                    Image(systemName: "chevron.down")
//                        .font(.system(size: 10, weight: .medium))
//                        .foregroundColor(isDark ? Color(hex: "#737373") : Color(hex: "#8C8C8C"))
//                        .frame(width: 16.scaled, height: 16.scaled)
//                }
//            }
//
//            // 中间 "译" 标签
//            Text("译")
//                .font(.custom("MiSans-Medium", size: ScreenAdapt.scaled(12)))
//                .foregroundColor(isDark ? Color(hex: "#737373") : Color(hex: "#8C8C8C"))
//
//            // 目标语言
//            Button(action: onSettings) {
//                HStack(spacing: 4.scaled) {
//                    Text(targetLanguage)
//                        .font(.custom("MiSans-Medium", size: ScreenAdapt.scaled(15)))
//                        .foregroundColor(isDark ? Color(hex: "#EEEEEE") : .black)
//                    Image(systemName: "chevron.down")
//                        .font(.system(size: 10, weight: .medium))
//                        .foregroundColor(isDark ? Color(hex: "#737373") : Color(hex: "#8C8C8C"))
//                        .frame(width: 16.scaled, height: 16.scaled)
//                }
//            }
//        }
//    }
//
//    // MARK: - Bottom Section
//
//    private var bottomSection: some View {
//        VStack(spacing: 0) {
//            if isActive {
//                activeButton
//            } else {
//                startButton
//            }
//
//            NoPurchaseGlassesLink()
//
//            Spacer().frame(height: Spacing.xxl.scaled)
//        }
//    }
//
//    // MARK: - 启动按钮 (未使用状态)
//
//    private var startButton: some View {
//        Button {
//            onStart()
//        } label: {
//            Text(NSLocalizedString("translation_start_simultaneous", comment: ""))
//                .font(.custom("PingFangSC-Medium", size: ScreenAdapt.scaled(17)))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .frame(height: 48.scaled)
//                .background(accentColor)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//        }
//        .padding(.horizontal, Spacing.page.scaled)
//    }
//
//    // MARK: - 正在使用按钮 (活跃状态)
//
//    private var activeButton: some View {
//        ZStack {
//            Text(NSLocalizedString("translation_simultaneous_active", comment: ""))
//                .font(.custom("PingFangSC-Medium", size: ScreenAdapt.scaled(17)))
//                .foregroundColor(accentColor)
//                .frame(maxWidth: .infinity)
//                .frame(height: 48.scaled)
//                .background(accentColor.opacity(0.1))
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//
//            LottieView(animation: .named("large_button_glow"))
//                .looping()
//                .frame(height: 48.scaled)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .allowsHitTesting(false)
//                .blendMode(isDark ? .normal : .screen)
//        }
//        .padding(.horizontal, Spacing.page.scaled)
//    }
//}
//
//#Preview("深色版") {
//    TranslationOnboardingView(
//        onStart: {}, onSettings: {}, onRecords: {}, onDismiss: {}
//    )
//    .preferredColorScheme(.dark)
//}
//
//#Preview("浅色版") {
//    TranslationOnboardingView(
//        onStart: {}, onSettings: {}, onRecords: {}, onDismiss: {}
//    )
//    .preferredColorScheme(.light)
//}
//
//#Preview("活跃状态") {
//    TranslationOnboardingView(
//        onStart: {}, onSettings: {}, onRecords: {}, onDismiss: {},
//        isActive: true
//    )
//    .preferredColorScheme(.dark)
//}
