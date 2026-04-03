
import SwiftUI

/// INMO 自定义导航栏
/// - 高度: 44pt (不含 SafeArea)
/// - 背景: bgPrimary 或 transparent
/// - 返回按钮: 24x24pt, 距左 20pt
/// - 标题: MiSans-Medium 18pt, 居中
public struct INMONavigationBar<Leading: View, Trailing: View>: View {
    let title: String
    let showDivider: Bool
    let isTransparent: Bool
    let leading: Leading
    let trailing: Trailing

    public init(
        title: String = "",
        showDivider: Bool = false,
        isTransparent: Bool = false,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.showDivider = showDivider
        self.isTransparent = isTransparent
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 标题始终居中（不受 leading/trailing 宽度影响）
                if !title.isEmpty {
                    Text(title)
                        .font(INMOFont.title2())
                        .foregroundColor(Color.textPrimary)
                }

                // leading / trailing 定位在两侧
                HStack(spacing: 0) {
                    leading
                        .frame(width: ComponentSize.navBackButton.scaled,
                               height: ComponentSize.navBackButton.scaled)
                        .padding(.leading, ComponentSize.navBackMargin.scaled)

                    Spacer()

                    trailing
                        .frame(height: ComponentSize.navBackButton.scaled)
                        .padding(.trailing, ComponentSize.navBackMargin.scaled)
                }
            }
            .frame(height: ComponentSize.navBarHeight)

            if showDivider {
                INMODivider()
            }
        }
        .background(
            (isTransparent ? Color.clear : Color.bgPrimary)
                .ignoresSafeArea(.container, edges: .top)
        )
    }
}

/// 带返回按钮的导航栏便捷版本
public struct INMONavBarWithBack<Trailing: View>: View {
    let title: String
    let isTransparent: Bool
    let dismiss: () -> Void
    let trailing: Trailing

    public init(
        title: String = "",
        isTransparent: Bool = false,
        dismiss: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.isTransparent = isTransparent
        self.dismiss = dismiss
        self.trailing = trailing()
    }

    public var body: some View {
        INMONavigationBar(title: title, isTransparent: isTransparent) {
            Button(action: dismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.textPrimary)
            }
        } trailing: {
            trailing
        }
    }
}


// MARK: - Color Hex Initializer

extension Color {
    /// 从 hex 字符串创建颜色, 例: Color(hex: "#19C38E")
    init(hex: String, opacity: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(
            .sRGB,
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0,
            opacity: opacity
        )
    }
}

// MARK: - UIColor Hex Initializer

extension UIColor {
    /// 从 hex 字符串创建 UIColor, 例: UIColor(hex: "#19C38E")
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

// MARK: - Brand Colors (Asset Catalog)

public extension Color {
    /// 主品牌色 #19C38E
    static let inmoPrimary       = Color("inmoPrimary")
    static let inmoPrimary80     = Color("inmoPrimary").opacity(0.80)
    static let inmoPrimary50     = Color("inmoPrimary").opacity(0.50)
    static let inmoPrimary40     = Color("inmoPrimary").opacity(0.40)
    static let inmoPrimary28     = Color("inmoPrimary").opacity(0.28)
    static let inmoPrimary20     = Color("inmoPrimary").opacity(0.20)
    static let inmoPrimary10     = Color("inmoPrimary").opacity(0.10)
    static let inmoPrimary5      = Color("inmoPrimary").opacity(0.05)

    static let inmoAccentGreen   = Color("inmoAccentGreen")
    static let inmoCaribbean     = Color("inmoCaribbean")
    static let inmoBrightGreen   = Color("inmoBrightGreen")
}

// MARK: - Background Colors (Asset Catalog — auto light/dark)

public extension Color {
    static let bgPrimary         = Color("bgPrimary")
    static let bgCard            = Color("bgCard")
    static let bgDialog          = Color("bgDialog")
    static let bgCardSecondary   = Color("bgCardSecondary")
    static let bgInput           = Color("bgInput")
    static let bgBlack           = Color("bgBlack")
}

// MARK: - Text Colors (Asset Catalog — auto light/dark)

public extension Color {
    static let textPrimary       = Color("textPrimary")
    static let textPrimary90     = Color("textPrimary").opacity(0.90)
    static let textPrimary80     = Color("textPrimary").opacity(0.80)
    static let textPrimary60     = Color("textPrimary").opacity(0.60)
    static let textPrimary50     = Color("textPrimary").opacity(0.50)
    static let textPrimary40     = Color("textPrimary").opacity(0.40)
    static let textPrimary30     = Color("textPrimary").opacity(0.30)
    static let textPrimary20     = Color("textPrimary").opacity(0.20)

    /// 文字/02: dark=#CCCCCC, light=#333333 — 用于正文/内容文字
    static let textBody          = Color("textBody")
    static let textSecondary     = Color("textSecondary")
    static let textTertiary      = Color("textTertiary")
    static let textDarkGray      = Color("textDarkGray")
}

// MARK: - Functional Colors (Asset Catalog)

public extension Color {
    static let funcDanger        = Color("funcDanger")
    static let funcDanger8       = Color("funcDanger").opacity(0.08)
    static let funcDangerAlt     = Color("funcDangerAlt")
    static let funcWarning       = Color("funcWarning")
    static let funcOrange        = Color("funcOrange")
    static let funcGolden        = Color("funcGolden")
    static let funcSuccess       = Color("funcSuccess")
}

// MARK: - Button Colors

public extension Color {
    /// 次要按钮背景: dark=rgba(255,255,255,0.08), light=rgba(0,0,0,0.06)
    static let secondaryButtonBg = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.black.withAlphaComponent(0.06)
    })
    /// 次要按钮文字: dark=#CCCCCC, light=#333333
    static let secondaryButtonText = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: "#CCCCCC")
            : UIColor(hex: "#333333")
    })
}

// MARK: - Overlay Opacity Scale (动态: dark=白色半透明, light=黑色半透明)

public extension Color {
    /// 创建 dark=white.opacity(x) / light=black.opacity(x*0.7) 的动态颜色
    private static func adaptiveOverlay(_ darkOpacity: Double) -> Color {
        let lightOpacity = darkOpacity * 0.7
        return Color(UIColor { traits in
            if traits.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(darkOpacity)
            } else {
                return UIColor.black.withAlphaComponent(lightOpacity)
            }
        })
    }

    static let whiteO3  = adaptiveOverlay(0.03)
    static let whiteO4  = adaptiveOverlay(0.04)
    static let whiteO5  = adaptiveOverlay(0.05)
    static let whiteO8  = adaptiveOverlay(0.08)
    static let whiteO10 = adaptiveOverlay(0.10)
    static let whiteO12 = adaptiveOverlay(0.12)
    static let whiteO16 = adaptiveOverlay(0.16)
    static let whiteO20 = adaptiveOverlay(0.20)
    static let whiteO28 = adaptiveOverlay(0.28)
    static let whiteO30 = adaptiveOverlay(0.30)
    static let whiteO40 = adaptiveOverlay(0.40)
    static let whiteO50 = adaptiveOverlay(0.50)
    static let whiteO60 = adaptiveOverlay(0.60)
    static let whiteO70 = adaptiveOverlay(0.70)
    static let whiteO75 = adaptiveOverlay(0.75)
    static let whiteO80 = adaptiveOverlay(0.80)
    static let whiteO90 = adaptiveOverlay(0.90)
}

// MARK: - Gradients

public extension LinearGradient {
    static let sliderGradient = LinearGradient(
        colors: [Color(hex: "#B73AFB"), Color(hex: "#8A3DFD")],
        startPoint: .leading, endPoint: .trailing
    )
    static let aiWaveGradient = LinearGradient(
        colors: [Color(hex: "#0090FF"), Color(hex: "#83F655"), Color(hex: "#FFE500")],
        startPoint: .leading, endPoint: .trailing
    )
    /// 顶部遮罩: 使用 bgPrimary 自动适配浅深色
    static let topFade = LinearGradient(
        colors: [Color("bgPrimary"), Color.clear],
        startPoint: .top, endPoint: .bottom
    )
}



