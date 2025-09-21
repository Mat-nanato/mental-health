//
//  Untitled.swift
//  mental health
//
//  Created by user on 2025/09/18.
//

// MARK: - TermsOfServiceView.swift
import SwiftUI
import Foundation
import StoreKit


// MARK: - 言語管理
enum AppLanguage: String, CaseIterable {
    case japanese = "ja"
    case english = "en"
}

class LanguageManager: ObservableObject {
    @Published var current: AppLanguage = .japanese
}
// MARK: - 追加購入
struct PurchaseChuruView: View {
    @EnvironmentObject var userInfo: UserInfo   // ← 追加
    @State private var quantity: Int = 1
    let pricePerUnit = 100
    
    @State private var showAlert = false // アラート表示フラグ

    
    var totalPrice: Int {
        quantity * pricePerUnit
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("チューるを購入")
                .font(.title)
                .bold()
            
            Stepper("個数: \(quantity)", value: $quantity, in: 1...99)
                .padding()
            
            Text("合計金額: \(totalPrice)円")
                .font(.headline)
            
            Button(action: {
                // 非同期購入処理がある場合は Task { await ... } 内で行う
                userInfo.churuCount += quantity  // ← 所持チュール数を増やす
                showAlert = true
            }) {
                Text("購入する")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }

            .padding(.horizontal)
            .alert("購入完了", isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text("\(quantity)個のチュールいつもありがとにゃ。合計 \(totalPrice)円にゃ。")
            })
            
            Spacer()
        }
        .padding()
    }
}


// MARK: - 初回起動管理
class AppState: ObservableObject {
    @Published var isFirstLaunch: Bool
    
    init() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        self.isFirstLaunch = !launchedBefore
    }
    
    func markLaunched() {
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        isFirstLaunch = false
    }
}


/// MARK: - 課金管理 + 無料トライアル
@MainActor
class SubscriptionManager: ObservableObject {
    @Published var hasActiveSubscription: Bool = false
    @Published var subscriptionStatusMessage: String = ""
    @Published var subscriptionStartDate: Date?

    let productId = "com.example.mentalhealth.monthly"

    init() {
        print("🔹 SubscriptionManager init start")

        if let savedDate = UserDefaults.standard.object(forKey: "subscriptionStartDate") as? Date {
            subscriptionStartDate = savedDate
            print("🔹 課金開始日 savedDate が見つかった: \(savedDate)")
        } else {
            print("🔹 課金開始日 savedDate はなし")
        }

        print("🔹 SubscriptionManager init end")
    }

    /// 購入処理（UserInfo に直接反映）
    func purchase(userInfo: UserInfo) async {
        do {
            let storeProducts = try await Product.products(for: [productId])
            guard let product = storeProducts.first else { return }

            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                let trialPeriodDays = 7
                let purchaseDate = transaction.purchaseDate

                if subscriptionStartDate == nil {
                    // 初回購入で7個付与
                    userInfo.addChuru(7)
                    subscriptionStartDate = purchaseDate
                    UserDefaults.standard.set(purchaseDate, forKey: "subscriptionStartDate")
                } else if let start = subscriptionStartDate {
                    let daysSinceStart = Calendar.current.dateComponents([.day], from: start, to: purchaseDate).day ?? 0
                    if daysSinceStart < trialPeriodDays {
                        userInfo.addChuru(7)
                    } else {
                        userInfo.addChuru(31)
                    }
                }

                hasActiveSubscription = transaction.revocationDate == nil
                subscriptionStatusMessage = "Subscription active ✅"

                await transaction.finish()
                updateSubscriptionStatus()

            case .userCancelled:
                subscriptionStatusMessage = "User cancelled ❌"
            default:
                subscriptionStatusMessage = "Purchase failed ❌"
            }

        } catch {
            subscriptionStatusMessage = "Error: \(error.localizedDescription)"
            print("purchase error: \(error.localizedDescription)")
        }
    }

    func restorePurchases(userInfo: UserInfo) async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productID == productId {
                    subscriptionStartDate = transaction.purchaseDate
                    hasActiveSubscription = transaction.revocationDate == nil
                    updateSubscriptionStatus()
                    
                    // 必要ならチュール付与などをここで userInfo に反映
                    let trialPeriodDays = 7
                    let now = Date()
                    if let start = subscriptionStartDate {
                        let daysSinceStart = Calendar.current.dateComponents([.day], from: start, to: now).day ?? 0
                        if daysSinceStart < trialPeriodDays {
                            userInfo.churuCount += 7
                        } else {
                            userInfo.churuCount += 31
                        }
                    }
                }
            }
        }
    }


    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw StoreError.failedVerification
        case .verified(let safe): return safe
        }
    }

    enum StoreError: Error { case failedVerification }

    func subscriptionEndDate() -> Date? {
        guard let start = subscriptionStartDate else { return nil }
        return Calendar.current.date(byAdding: .day, value: 7, to: start)
    }

    func updateSubscriptionStatus() {
        if let end = subscriptionEndDate() {
            if Date() < end {
                hasActiveSubscription = true
                let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: end).day ?? 0
                subscriptionStatusMessage = "Active (expires in \(daysLeft) days)"
            } else {
                hasActiveSubscription = false
                subscriptionStatusMessage = "Subscription expired"
            }
        }
    }
}

    // MARK: - 利用規約テキスト
    struct TermsOfServiceText {
        static let japanese: String = """
利用規約

本アプリケーション（以下「本アプリ」）をご利用いただく前に、以下の利用規約（以下「本規約」）を必ずお読みください。本アプリを利用することで、本規約に同意したものとみなされます。

1. サービス内容
本アプリは、メンタルヘルスサポート機能を提供するアプリケーションです。提供される機能や内容は予告なく変更される場合があります。

2. 利用料金および支払い
1. 本アプリは、登録時に1週間の無料トライアルを提供します。
2. 無料トライアル期間終了後は、月額 3,000円（税込）の利用料が自動的に発生します。
3. 利用料は Apple ID の決済情報を通じて請求されます。
4. 課金は自動更新され、解約しない限り次回請求日に継続課金されます。
5. 無料トライアル期間中に解約した場合、料金は発生しません。

3. サブスクリプションの管理と解約
ユーザーは、Apple ID のアカウント設定からサブスクリプションを管理および解約できます。解約は次回課金日前に行う必要があります。

4. 禁止事項
ユーザーは以下の行為を行ってはなりません：
- 法令または公序良俗に反する行為
- 他のユーザーや第三者の権利を侵害する行為
- 本アプリの不正利用やリバースエンジニアリング
- 他のユーザーに迷惑や損害を与える行為
- 本アプリの運営や他ユーザーの信頼を損なう行為

5. 免責事項
本アプリは、可能な限り正確な情報提供を目指しますが、提供内容の完全性や正確性を保証するものではありません。
本アプリの利用によって生じたいかなる損害についても、運営者は一切責任を負いません。
健康に関する情報は参考として提供されるものであり、医療行為や診断の代替にはなりません。

6. データの取り扱い
ユーザーが本アプリで提供する情報（テキストや写真など）は、アプリ内機能の提供や改善のために使用されます。
個人情報の取り扱いについては、別途定めるプライバシーポリシーに従います。

7. サービスの変更・終了
本アプリは、予告なくサービス内容の変更や提供の中止を行う場合があります。
サービス提供の中止によって生じたいかなる損害についても、運営者は責任を負いません。

8. 規約の変更
本規約は予告なく変更されることがあります。変更後に本アプリを利用した場合、変更後の規約に同意したものとみなされます。

9. お問い合わせ
本規約に関するお問い合わせは、アプリ内のお問い合わせ機能または運営者指定の連絡先までご連絡ください。

10. 準拠法および裁判管轄
本規約は日本法に準拠します。本アプリ利用に関する紛争は東京地方裁判所を第一審の専属管轄裁判所とします。
"""
        
        static let english: String = """
Terms of Service

Before using this application (hereinafter "this App"), please read the following Terms of Service (hereinafter "these Terms"). By using this App, you agree to these Terms.

1. Service Description
This App provides mental health support features. The content and functionality may change without notice.

2. Fees and Payment
1. This App offers a one-week free trial upon registration.
2. After the free trial period ends, a monthly fee of 3,000 JPY (including tax) will be automatically charged.
3. The fee will be billed through the payment method registered with your Apple ID.
4. Subscriptions are automatically renewed unless canceled before the next billing date.
5. If canceled during the free trial period, no charge will occur.

3. Subscription Management and Cancellation
Users can manage and cancel subscriptions from their Apple ID account settings. Cancellation must occur before the next billing date.

4. Prohibited Activities
Users must not:
- Violate any laws or public morals
- Infringe on the rights of other users or third parties
- Misuse the app or attempt reverse engineering
- Cause inconvenience or damage to other users
- Undermine the operation of the app or trust of other users

5. Disclaimer
This App aims to provide accurate information but does not guarantee completeness or accuracy. The operator is not responsible for any damages resulting from app usage. Health information is provided for reference only and does not replace medical advice or diagnosis.

6. Data Handling
Information provided by users (text, photos, etc.) may be used for app functionality and improvement. Personal information handling is governed by the separate Privacy Policy.

7. Service Changes or Termination
The app may change or terminate services without notice. The operator is not responsible for any damages resulting from service termination.

8. Changes to Terms
These Terms may change without notice. Continued use of the app after changes constitutes agreement to the revised Terms.

9. Contact
For inquiries regarding these Terms, please use the in-app contact feature or the operator's designated contact method.

10. Governing Law and Jurisdiction
These Terms are governed by Japanese law. Any disputes shall be subject to the exclusive jurisdiction of the Tokyo District Court as the court of first instance.
"""
    }
    
// MARK: - 利用規約表示
struct TermsView: View {
    @EnvironmentObject var langManager: LanguageManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager   // ← 追加
    @EnvironmentObject var userInfo: UserInfo  // ← 追加
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            ScrollView {
                Text(langManager.current == .japanese ? TermsOfServiceText.japanese : TermsOfServiceText.english)
                    .padding()
            }
            
            Button(action: {
                appState.markLaunched()
                presentationMode.wrappedValue.dismiss()

                // ✅ 購入処理を呼ぶ
                Task {
                    await subscriptionManager.purchase(userInfo: userInfo)
                }

            }) {
                Text(langManager.current == .japanese ? "同意して開始する" : "Agree and Start")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .navigationTitle(langManager.current == .japanese ? "利用規約" : "Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

  
// MARK: - 設定画面
struct SettingsView: View {
    @StateObject private var langManager = LanguageManager()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @EnvironmentObject var userInfo: UserInfo
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // 言語切替
                Picker("言語 / Language", selection: $langManager.current) {
                    Text("日本語").tag(AppLanguage.japanese)
                    Text("English").tag(AppLanguage.english)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 利用規約遷移
                NavigationLink(
                    destination: TermsView()
                        .environmentObject(langManager)
                        .environmentObject(subscriptionManager)
                ) {
                    Text(langManager.current == .japanese ? "利用規約を見る" : "View Terms of Service")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                // サブスク購入ボタン
                Button(action: {
                    Task {
                        print("SettingsView: purchase button tapped")
                        print("Current churuCount before purchase = \(userInfo.churuCount)")

                        Task {
                            await subscriptionManager.purchase(userInfo: userInfo)
                            print("Current churuCount after purchase = \(userInfo.churuCount)")
                        }

                    }
                }) {
                    Text(langManager.current == .japanese ? "購読を開始する (7日無料 → 月額3,000円)" : "Start Subscription (7-day free → ¥3,000/month)")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                
                // 復元ボタン
                Button(action: {
                    Task {
                        print("SettingsView: restore button tapped")
                        await subscriptionManager.restorePurchases(userInfo: userInfo)
                    }

                }) {
                    Text(langManager.current == .japanese ? "購入を復元する" : "Restore Purchases")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                
                // サブスクステータス表示
                Text(subscriptionManager.subscriptionStatusMessage)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding()
            .navigationTitle(langManager.current == .japanese ? "設定" : "Settings")
        }
    }
}

    // MARK: - ルートビュー
    struct RootView: View {
        @StateObject private var appState = AppState()
        
        var body: some View {
            ZStack {
                if appState.isFirstLaunch {
                    FirstLaunchView().environmentObject(appState)
                } else {
                    SettingsView()
                }
            }
        }
    }

