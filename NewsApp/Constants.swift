import SwiftUI
import UIKit

// MARK: - Spacing Scale

public enum Spacing {
    public static let xxs:  CGFloat = 2
    public static let xs:   CGFloat = 4
    public static let s:    CGFloat = 8
    public static let m:    CGFloat = 12
    public static let l:    CGFloat = 16
    public static let xl:   CGFloat = 20
    public static let xxl:  CGFloat = 24
    public static let xxxl: CGFloat = 32
    /// 页面水平边距
    public static let page: CGFloat = 20
}

// MARK: - Component Sizes

public enum ComponentSize {
    // 导航栏
    public static let navBarHeight:    CGFloat = 44
    public static let navBackButton:   CGFloat = 24
    public static let navBackMargin:   CGFloat = 20

    // Tab Bar (Figma: 底部Bar 375x70pt, 背景 68.776pt)
    public static let tabBarHeight:    CGFloat = 70
    public static let tabContentH:     CGFloat = 56
    public static let tabIconSize:     CGFloat = 24
    public static let tabAIButton:     CGFloat = 48
    public static let tabAIButtonH:    CGFloat = 40
    public static let tabAreaWidth:    CGFloat = 113

    // 按钮
    public static let buttonHeightL:   CGFloat = 56
    public static let buttonHeight:    CGFloat = 48
    public static let buttonHeightS:   CGFloat = 36
    public static let buttonMinWidth:  CGFloat = 120

    // 图标
    public static let iconXS:          CGFloat = 16
    public static let iconS:           CGFloat = 20
    public static let iconM:           CGFloat = 24
    public static let iconL:           CGFloat = 36
    public static let iconXL:          CGFloat = 48

    // 头像
    public static let avatarS:         CGFloat = 32
    public static let avatarM:         CGFloat = 48
    public static let avatarL:         CGFloat = 80

    // 卡片
    public static let cardMinHeight:   CGFloat = 56

    // 输入框
    public static let inputHeight:     CGFloat = 48
    public static let inputPaddingH:   CGFloat = 16

    // 分隔线
    public static let dividerHeight:   CGFloat = 0.5

    // 弹窗
    public static let sheetItemHeight: CGFloat = 58
    public static let alertButtonH:    CGFloat = 48
}

// MARK: - Corner Radius Scale

public enum CornerRadius {
    /// 进度条、小标签
    public static let xs:     CGFloat = 4
    /// 小图标
    public static let s:      CGFloat = 6
    /// 输入框
    public static let m:      CGFloat = 8
    /// 卡片、弹窗、按钮
    public static let l:      CGFloat = 12
    /// 模态、Sheet (顶部)
    public static let xl:     CGFloat = 16
    /// 大卡片
    public static let xxl:    CGFloat = 20
    /// 胶囊按钮
    public static let xxxl:   CGFloat = 24
    /// 完全胶囊 (height/2)
    public static let pill:   CGFloat = 9999
}



/// INMO 字体系统
/// - MiSans (Normal/Medium/DemiBold): UI 文字
/// - D-DIN-PRO (Medium/ExtraBold): 数字
public enum INMOFont {

    // MARK: - 标题

    /// 超大标题 36pt DemiBold - 首页设备名、大数字
    public static func largeTitle() -> Font {
        .custom("MiSans-DemiBold", size: scaled(36))
    }

    /// 页面标题 26pt DemiBold
    public static func title1() -> Font {
        .custom("MiSans-DemiBold", size: scaled(26))
    }

    /// 弹窗/导航标题 18pt Medium
    public static func title2() -> Font {
        .custom("MiSans-Medium", size: scaled(18))
    }

    /// 卡片标题/Section Header 16pt Medium
    public static func title3() -> Font {
        .custom("MiSans-Medium", size: scaled(16))
    }

    // MARK: - 正文

    /// 大正文 16pt Medium - 设置项标签
    public static func bodyLarge() -> Font {
        .custom("MiSans-Medium", size: scaled(16))
    }

    /// 标准正文 14pt Normal - 列表文字、对话内容
    public static func body() -> Font {
        .custom("MiSans-Normal", size: scaled(14))
    }

    /// 小正文 13pt Normal - 次要信息
    public static func bodySmall() -> Font {
        .custom("MiSans-Normal", size: scaled(13))
    }

    // MARK: - 辅助

    /// 标注 12pt Medium - 标签
    public static func caption() -> Font {
        .custom("MiSans-Medium", size: scaled(12))
    }

    /// 小标注 11pt Normal - 时间戳、角标
    public static func captionSmall() -> Font {
        .custom("MiSans-Normal", size: scaled(11))
    }

    /// 极小 10pt Normal
    public static func micro() -> Font {
        .custom("MiSans-Normal", size: scaled(10))
    }

    // MARK: - 数字

    /// 大数字 24pt ExtraBold - 电量、百分比
    public static func numberLarge() -> Font {
        .custom("D-DIN-PRO-ExtraBold", size: scaled(24))
    }

    /// 标准数字 16pt Medium - 版本号、序号
    public static func number() -> Font {
        .custom("D-DIN-PRO-Medium", size: scaled(16))
    }

    // MARK: - 按钮

    /// 大按钮 17pt Medium
    public static func buttonLarge() -> Font {
        .custom("MiSans-Medium", size: scaled(17))
    }

    /// 标准按钮 14pt Medium
    public static func button() -> Font {
        .custom("MiSans-Medium", size: scaled(14))
    }

    /// 小按钮 13pt Medium
    public static func buttonSmall() -> Font {
        .custom("MiSans-Medium", size: scaled(13))
    }

    // MARK: - UIFont 版本 (UIKit 场景使用)

    public static func uiFont(name: String, size: CGFloat) -> UIFont {
        UIFont(name: name, size: ScreenAdapt.scaled(size)) ?? .systemFont(ofSize: ScreenAdapt.scaled(size))
    }

    // MARK: - Private

    private static func scaled(_ size: CGFloat) -> CGFloat {
        ScreenAdapt.scaled(size)
    }
}



/// 基准宽度 375pt (iPhone SE/8 尺寸)
/// 所有设计值基于此宽度, 按比例缩放到当前设备
public enum ScreenAdapt {
    public static let baseWidth: CGFloat = 375.0

    /// iPad 上缩放基准最大宽度（等同 iPhone 16 Pro Max），防止元素过大
    public static let maxScaleWidth: CGFloat = 430.0

    /// 是否为 iPad
    public static let isIPad = UIDevice.current.userInterfaceIdiom == .pad

    /// iPad 内容区最大宽度
    public static let iPadContentMaxWidth: CGFloat = 430.0

    /// 按屏幕宽度等比缩放
    public static func scaled(_ value: CGFloat) -> CGFloat {
        let width = isIPad ? min(UIScreen.main.bounds.width, maxScaleWidth) : UIScreen.main.bounds.width
        return ceil(value * width / baseWidth)
    }
}

public extension CGFloat {
    /// 自适应缩放: `20.scaled`
    var scaled: CGFloat { ScreenAdapt.scaled(self) }
}

public extension Double {
    /// 自适应缩放: `20.0.scaled`
    var scaled: CGFloat { ScreenAdapt.scaled(CGFloat(self)) }
}

public extension Int {
    /// 自适应缩放: `20.scaled`
    var scaled: CGFloat { ScreenAdapt.scaled(CGFloat(self)) }
}

// MARK: - iPad 内容居中容器

import SwiftUI

/// iPad 上限制内容最大宽度并居中，iPhone 上无任何效果
struct IPadContentAdaptor: ViewModifier {
    func body(content: Content) -> some View {
        if ScreenAdapt.isIPad {
            content
                .frame(maxWidth: ScreenAdapt.iPadContentMaxWidth)
                .frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}

extension View {
    /// iPad 适配：限制内容最大宽度并居中显示
    func iPadContent() -> some View {
        modifier(IPadContentAdaptor())
    }
}


/// INMO 分隔线: 0.5pt, whiteO4
public struct INMODivider: View {
    let indent: CGFloat

    public init(indent: CGFloat = 0) {
        self.indent = indent
    }

    public var body: some View {
        Rectangle()
            .fill(Color.whiteO4)
            .frame(height: ComponentSize.dividerHeight)
            .padding(.leading, indent)
    }
}
