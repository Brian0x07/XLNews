//
//  ContentView.swift
//  demo
//
//  Created by xiaolei on 3/24/26.
//

import SwiftUI
import RNViewFactory

struct Category: Identifiable {
    let id: String
    let name: String
    let icon: String
    let accent: Color
}

let categories: [Category] = [
    Category(id: "medical",    name: "Medical",    icon: "cross.case.fill",        accent: Color(red: 0.35, green: 0.78, blue: 0.62)),
    Category(id: "tech",       name: "Tech",       icon: "cpu.fill",               accent: Color(red: 0.40, green: 0.56, blue: 1.0)),
    Category(id: "world",      name: "World",      icon: "globe.americas.fill",    accent: Color(red: 0.95, green: 0.62, blue: 0.22)),
    Category(id: "science",    name: "Science",    icon: "atom",                   accent: Color(red: 0.75, green: 0.45, blue: 0.95)),
    Category(id: "business",   name: "Business",   icon: "chart.line.uptrend.xyaxis", accent: Color(red: 0.30, green: 0.75, blue: 0.85)),
    Category(id: "sports",     name: "Sports",     icon: "sportscourt.fill",       accent: Color(red: 0.95, green: 0.40, blue: 0.40)),
]

struct ContentView: View {
    let gridColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]

    var body: some View {
        ZStack {
            Color(red: 0.09, green: 0.09, blue: 0.11)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Good Morning")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("What would you like to read today?")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))
                    }

                    // Categories Grid
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Categories")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))

                        LazyVGrid(columns: gridColumns, spacing: 14) {
                            ForEach(categories) { cat in
                                CategoryCard(category: cat) {
                                    pushRNNewsList(category: cat.id, title: cat.name)
                                }
                            }
                        }
                    }

                    // Trending Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Trending")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))

                        Button(action: {
                            pushRNNewsList(category: "trending", title: "Trending")
                        }) {
                            HStack(spacing: 14) {
                                Image(systemName: "flame.fill")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 0.95, green: 0.40, blue: 0.40))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Top Stories")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("See what everyone is reading right now")
                                        .font(.caption)
                                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(red: 0.40, green: 0.40, blue: 0.42))
                            }
                            .padding(16)
                            .background(Color(red: 0.11, green: 0.11, blue: 0.13))
                            .cornerRadius(12)
                        }
                    }

                    // Settings
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Settings")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))

                        Button(action: {
                            pushRNPage(moduleName: "SettingsPage", title: "Settings")
                        }) {
                            HStack(spacing: 14) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Preferences")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Theme, font size and more")
                                        .font(.caption)
                                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(red: 0.40, green: 0.40, blue: 0.42))
                            }
                            .padding(16)
                            .background(Color(red: 0.11, green: 0.11, blue: 0.13))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
    }

    private func pushRNNewsList(category: String, title: String) {
        pushRNPage(moduleName: "NewsList", title: title)
    }

    private func pushRNPage(moduleName: String, title: String) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let nav = window.rootViewController as? UINavigationController else {
            return
        }
        let vc = RNViewController(moduleName: moduleName)
        vc.title = title
        nav.pushViewController(vc, animated: true)
    }
}

struct CategoryCard: View {
    let category: Category
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(category.accent)
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color(red: 0.11, green: 0.11, blue: 0.13))
            .cornerRadius(12)
        }
    }
}

class RNViewController: UIViewController {
    private let moduleName: String

    init(moduleName: String) {
        self.moduleName = moduleName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.11, alpha: 1)
        let rnView = RNViewFactory.createRootView(withModuleName: moduleName)
        rnView.frame = view.bounds
        rnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(rnView)
    }
}

#Preview {
    ContentView()
}
