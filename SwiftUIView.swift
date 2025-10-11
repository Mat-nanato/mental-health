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
    @EnvironmentObject var userInfo: UserInfo
    @State private var quantity: Int = 1
    let pricePerUnit = 100
    
    @State private var showAlert = false
    @State private var purchaseAIMessage = "にゃん診断中…"

    var totalPrice: Int {
        quantity * pricePerUnit
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.pink.opacity(0.3),
                         Color.yellow.opacity(0.3),
                         Color.blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("チューるを購入")
                    .font(.title)
                    .bold()
                
                Stepper("個数: \(quantity)", value: $quantity, in: 1...99)
                    .padding()
                
                Text("合計金額: \(totalPrice)円")
                    .font(.headline)
                
                // AI応援メッセージ
                Text(purchaseAIMessage)
                    .font(.body)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(12)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: {
                    // チュールを増やす
                    userInfo.churuCount += quantity
                    showAlert = true
                    
                    // 購入ボタン押したタイミングで AI メッセージ取得
                    Task {
                        let prompt = """
                        あなたは猫キャラクターです。ユーザーがチュールを購入しました。
                        ユーザー情報:
                        呼ばれたい名前: \(userInfo.catCallName)
                                                猫の名前: \(userInfo.catRealName)
                                                性別: \(userInfo.gender)
                                                年齢: \(userInfo.age)
                                                身長: \(userInfo.height)
                                                体重: \(userInfo.weight)
                                                住所: \(userInfo.address)
                                                アルコール: \(userInfo.alcohol)
                                                タバコ: \(userInfo.tobacco)
                        
                        これらを踏まえて、短く可愛く、元気づける応援メッセージを出してください。
                        """
                        purchaseAIMessage = await fetchAIReplyText(for: prompt)
                    }

                    
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
    
    private func fetchAIReplyText(for prompt: String) async -> String {
        let fullPrompt = "\(prompt)"
        #if DEBUG
        let baseURL = "http://localhost:8787"
        #else
        let baseURL = "https://my-worker.app-lab-nanato.workers.dev"
        #endif
        
        guard let url = URL(string: baseURL) else { return "URL無効にゃ" }
        
        let body: [String: Any] = ["prompt": fullPrompt]
        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            
            let (responseData, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let reply = json["reply"] as? String {
                return reply
            } else {
                return "返答形式が不正にゃ"
            }
        } catch {
            return "サーバに接続できないにゃ: \(error.localizedDescription)"
        }
    }
}

    // --- 非同期 AI 呼び出し（ContentView と共通関数を流用） ---
    private func fetchAIReplyText(for prompt: String) async -> String {
        let fullPrompt = "\(prompt)"
        #if DEBUG
        let baseURL = "http://localhost:8787"
        #else
        let baseURL = "https://my-worker.app-lab-nanato.workers.dev"
        #endif
        
        guard let url = URL(string: baseURL) else { return "URL無効にゃ" }
        
        let body: [String: Any] = ["prompt": fullPrompt]
        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            
            let (responseData, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let reply = json["reply"] as? String {
                return reply
            } else {
                return "返答形式が不正にゃ"
            }
        } catch {
            return "サーバに接続できないにゃ: \(error.localizedDescription)"
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
                    userInfo.addChuru(99)
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

 ねこログ プライバシーポリシー（規約末尾追記用・一括）
ねこログ（以下「当アプリ」）は、ユーザーのプライバシーを尊重し、個人情報の適切な保護に努めます。本ポリシーは、当アプリが収集する情報、利用方法、管理方法について説明するものです。
1. 収集する情報
当アプリは、以下の情報を収集することがあります：
ユーザーが入力する日記内容やメンタル記録
アップロードした画像（飼い猫の写真など）
デバイス情報（OSの種類、バージョン、デバイス識別子）
アプリ利用状況（利用時間、操作履歴、エラー情報）
2. 利用目的
収集した情報は以下の目的で使用します：
ユーザーの日記内容・画像の保存および表示
AIによるテキスト生成機能の提供
サービス改善、利用統計分析、不具合修正
利用規約違反や不正行為の検知
3. 第三者提供
ユーザーの個人情報を本人の同意なく第三者に提供することはありません。
ただし、法令に基づく場合、権利保護のために必要な場合、またはサービス運営に必要な業務委託先への提供は例外です。
広告配信や分析サービスなど外部サービスを利用する場合は、必要最小限の情報のみを匿名化して提供します。
4. データの保管期間
ユーザーのアカウントが存在する間、または法令で定められた期間のみ情報を保管します。
ユーザーが削除リクエストを行った場合、合理的な期間内に削除します。
5. ユーザーの権利
ユーザーは以下の権利を有します：
自分のデータの閲覧、修正、削除
データ利用停止の要求
サポート窓口への問い合わせによる権利行使
6. セキュリティ
当アプリは、ユーザー情報を安全に管理するために、適切な技術的・物理的・組織的対策を講じます。
ただし、インターネットを経由した通信やデータ保存の完全な安全性は保証できません。
7. 未成年の利用
13歳未満（または各国法令に定める年齢）の方は、保護者の同意なしに本アプリを利用できません。
保護者の同意が必要な場合、同意確認を行うことがあります。
8. 改訂について
プライバシーポリシーは予告なく改訂することがあります。
改訂後はアプリ内通知や公式サイトで周知します。
9. お問い合わせ
本ポリシーに関するお問い合わせは app.lab.nanato@gmail.com までお願いします。
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

📄 NekoLog Privacy Policy (Append to Terms of Service)
NekoLog (hereinafter "the App") respects users' privacy and is committed to protecting personal information appropriately. This Policy explains the information collected by the App, how it is used, and how it is managed.
1. Information We Collect
The App may collect the following information:
Diary entries and mental health records entered by users
Uploaded images (e.g., photos of your pet cat)
Device information (OS type, version, device identifiers)
App usage data (usage time, operation history, error logs)
2. Purpose of Use
Collected information is used for the following purposes:
Saving and displaying users’ diary entries and images
Providing AI text generation features
Service improvement, usage statistics analysis, and bug fixing
Detecting violations of the Terms of Service or fraudulent activity
3. Third-Party Disclosure
Users’ personal information will not be provided to third parties without consent.
Exceptions include cases required by law, to protect rights, or for necessary business operations.
When using external services for advertising or analytics, only anonymized and minimal data is provided.
4. Data Retention
User data is retained while the account exists or as required by law.
Upon user request for deletion, data will be removed within a reasonable period.
5. User Rights
Users have the following rights:
Access, correct, or delete their data
Request cessation of data use
Contact support to exercise their rights
6. Security
The App implements appropriate technical, physical, and organizational measures to safeguard user information.
However, complete security of data transmitted or stored over the Internet cannot be guaranteed.
7. Use by Minors
Users under the age of 13 (or the age specified by local law) must obtain parental consent before using the App.
Parental consent may be verified when required.
8. Policy Updates
This Privacy Policy may be revised without prior notice.
Users will be informed of significant changes via in-app notification or official website.
9. Contact
For any questions regarding this Policy, please contact us at app.lab.nanato@gmail.com.
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

