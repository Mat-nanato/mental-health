import SwiftUI
import PhotosUI
import Vision
import UserNotifications
import AVFoundation
import Accelerate
import UIKit

// MARK: - ユーザー情報
class UserInfo: ObservableObject {
    @Published var catCallName: String = "" {   // 猫に呼んでほしい名前
        didSet { UserDefaults.standard.set(catCallName, forKey: "catCallName") }
    }
    @Published var catRealName: String = "" {   // 猫の名前
        didSet { UserDefaults.standard.set(catRealName, forKey: "catRealName") }
    }
    @Published var gender: String = "" {
        didSet { UserDefaults.standard.set(gender, forKey: "gender") }
    }
    @Published var age: String = "" {
        didSet { UserDefaults.standard.set(age, forKey: "age") }
    }
    @Published var address: String = "" {
        didSet { UserDefaults.standard.set(address, forKey: "address") }
    }
    @Published var height: String = "" {
        didSet { UserDefaults.standard.set(height, forKey: "height") }
    }
    @Published var weight: String = "" {
        didSet { UserDefaults.standard.set(weight, forKey: "weight") }
    }
    @Published var alcohol: String = "" {
        didSet { UserDefaults.standard.set(alcohol, forKey: "alcohol") }
    }
    @Published var tobacco: String = "" {
        didSet { UserDefaults.standard.set(tobacco, forKey: "tobacco") }
    }

    // チュールの所持数（変更なし）
    @Published var churuCount: Int = 0 {
        didSet {
            UserDefaults.standard.set(churuCount, forKey: "churuCount")
        }
    }

    init() {
        // ユーザー情報の永続化読み込み
        catCallName = UserDefaults.standard.string(forKey: "catCallName") ?? ""
        catRealName = UserDefaults.standard.string(forKey: "catRealName") ?? ""
        gender = UserDefaults.standard.string(forKey: "gender") ?? ""
        age = UserDefaults.standard.string(forKey: "age") ?? ""
        address = UserDefaults.standard.string(forKey: "address") ?? ""
        height = UserDefaults.standard.string(forKey: "height") ?? ""
        weight = UserDefaults.standard.string(forKey: "weight") ?? ""
        alcohol = UserDefaults.standard.string(forKey: "alcohol") ?? ""
        tobacco = UserDefaults.standard.string(forKey: "tobacco") ?? ""

        // チュールは従来どおり
        churuCount = UserDefaults.standard.object(forKey: "churuCount") as? Int ?? 7
    }

    // チュールを追加
    func addChuru(_ amount: Int) {
        churuCount += amount
    }

    // チュールを消費
    func useChuru(_ amount: Int) {
        churuCount = max(churuCount - amount, 0)
    }
}


// MARK: - ユーザー情報入力画面（かわいいフォント版 + キーボード対応）
struct UserInfoView: View {
    @EnvironmentObject var userInfo: UserInfo 
    @Binding var isPresented: Bool

    let genders = ["男性", "女性", "その他"]
    let alcoholOptions = ["なし", "あり"]
    let tobaccoOptions = ["なし", "あり"]

    // キーボードフォーカス管理
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case catName1, catName2, age, address, height, weight
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                LinearGradient(
                    colors: [Color.pink.opacity(0.3), Color.yellow.opacity(0.3), Color.blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                GeometryReader { geo in
                    ForEach(0..<50, id: \.self) { _ in
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 20, height: 20)
                            .position(
                                x: CGFloat.random(in: 0...geo.size.width),
                                y: CGFloat.random(in: 0...geo.size.height)
                            )
                    }
                }

                Form {
                    Section(header: Text("お猫様の情報")
                                .font(.custom("ChalkboardSE-Bold", size: 20))
                                .foregroundColor(.pink)) {

                        // 呼んでほしい名前
                        TextField("お猫様に読んでほしい名前", text: $userInfo.catCallName)
                            .font(.custom("ChalkboardSE-Regular", size: 18))
                            .padding(.vertical, 5)
                            .focused($focusedField, equals: .catName1)

                        // 猫の名前
                        TextField("お猫様の名前", text: $userInfo.catRealName)
                            .font(.custom("ChalkboardSE-Regular", size: 18))
                            .padding(.vertical, 5)
                            .focused($focusedField, equals: .catName2)
                    }


                    Section(header: Text("ユーザープロフィール")
                                .font(.custom("ChalkboardSE-Bold", size: 20))
                                .foregroundColor(.pink)) {
                        Picker("性別", selection: $userInfo.gender) {
                            ForEach(genders, id: \.self) {
                                Text($0)
                                    .font(.custom("ChalkboardSE-Regular", size: 18))
                            }
                        }
                        TextField("年齢", text: $userInfo.age)
                            .keyboardType(.numberPad)
                            .font(.custom("ChalkboardSE-Regular", size: 18))
                            .focused($focusedField, equals: .age)
                        TextField("住所（市区町村）", text: $userInfo.address)
                            .font(.custom("ChalkboardSE-Regular", size: 18))
                            .focused($focusedField, equals: .address)
                        TextField("身長 (cm)", text: $userInfo.height)
                            .keyboardType(.decimalPad)
                            .font(.custom("ChalkboardSE-Regular", size: 18))
                            .focused($focusedField, equals: .height)
                        TextField("体重 (kg)", text: $userInfo.weight)
                            .keyboardType(.decimalPad)
                            .font(.custom("ChalkboardSE-Regular", size: 18))
                            .focused($focusedField, equals: .weight)
                    }

                    Section(header: Text("生活習慣")
                                .font(.custom("ChalkboardSE-Bold", size: 20))
                                .foregroundColor(.pink)) {
                        Picker("飲酒", selection: $userInfo.alcohol) {
                            ForEach(alcoholOptions, id: \.self) {
                                Text($0)
                                    .font(.custom("ChalkboardSE-Regular", size: 18))
                            }
                        }
                        Picker("喫煙", selection: $userInfo.tobacco) {
                            ForEach(tobaccoOptions, id: \.self) {
                                Text($0)
                                    .font(.custom("ChalkboardSE-Regular", size: 18))
                            }
                        }
                    }

                    Section {
                        Button("次へ") { isPresented = true }
                            .buttonStyle(.borderedProminent)
                            .font(.custom("ChalkboardSE-Bold", size: 20))
                            .tint(.pink)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ユーザー情報入力")
                        .font(.custom("ChalkboardSE-Bold", size: 22))
                        .foregroundColor(.pink)
                }
            }
            // キーボード出すための初期フォーカス
            .onAppear {
                print("UserInfoView が描画されたにゃ！") // ← ここでログ

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .catName1
                }
            }
        }
    }
}

// MARK: - レーダーチャート
struct RadarChart: View {
    var scores: [Double]
    var labels: [String]

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let totalHeight = geo.size.height
            let padding: CGFloat = 30 // 左右に確保する余白（ラベル分）
            let radius = min(totalWidth - padding*2, totalHeight - padding*2) / 2 * 0.8
            let center = CGPoint(x: totalWidth / 2, y: totalHeight / 2)
            let numAxes = max(scores.count, labels.count)

            // ストレス軸だけ反転
            let displayScores = scores.enumerated().map { (i, score) -> Double in
                labels[i] == "ストレス" ? 100 - score : score
            }

            ZStack {
                // 背景枠（中央配置）
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.6))
                    .frame(width: totalWidth - padding, height: min(totalHeight, 220))
                    .position(x: totalWidth/2, y: totalHeight/2)

                radarGrid(center: center, radius: radius, numAxes: numAxes)
                radarLabels(center: center, radius: radius, labels: labels)
                radarScorePath(center: center, radius: radius, scores: displayScores)
            }
        }
        .frame(height: 200)
    }

    @ViewBuilder
    private func radarGrid(center: CGPoint, radius: CGFloat, numAxes: Int) -> some View {
        ForEach(1...5, id: \.self) { step in
            let r = radius * CGFloat(step)/5
            Path { path in
                path.addEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r*2, height: r*2))
            }
            .stroke(Color.gray.opacity(0.2 + Double(step)*0.1), lineWidth: 1)
        }
        ForEach(0..<numAxes, id: \.self) { i in
            let angle = Double(i)/Double(numAxes) * 2 * .pi - .pi/2
            Path { path in
                path.move(to: center)
                path.addLine(to: CGPoint(x: center.x + radius * cos(angle),
                                         y: center.y + radius * sin(angle)))
            }
            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        }
    }

    private struct RadarLabel: View {
        let text: String
        let position: CGPoint
        var body: some View {
            Text(text)
                .font(.caption2)
                .foregroundColor(.black)
                .padding(2)
                .background(Color.white.opacity(0.7))
                .cornerRadius(4)
                .position(position)
        }
    }

    @ViewBuilder
    private func radarLabels(center: CGPoint, radius: CGFloat, labels: [String]) -> some View {
        let numAxes = labels.count
        ForEach(0..<numAxes, id: \.self) { i in
            let fraction = Double(i) / Double(numAxes)
            let angle = fraction * 2 * .pi - .pi / 2
            let offset = radius + 15
            let dx = offset * cos(angle)
            let dy = offset * sin(angle)
            let pos = CGPoint(x: center.x + dx, y: center.y + dy)
            RadarLabel(text: labels[i], position: pos)
        }
    }

    @ViewBuilder
    private func radarScorePath(center: CGPoint, radius: CGFloat, scores: [Double]) -> some View {
        let numAxes = scores.count
        let points = scores.enumerated().map { (i, score) -> CGPoint in
            let angle = Double(i)/Double(numAxes) * 2 * .pi - .pi/2
            return CGPoint(x: center.x + radius * CGFloat(score/100) * cos(angle),
                           y: center.y + radius * CGFloat(score/100) * sin(angle))
        }

        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for pt in points.dropFirst() { path.addLine(to: pt) }
            path.closeSubpath()
        }
        .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.7), Color.blue.opacity(0.4)]),
                             startPoint: .top,
                             endPoint: .bottom))
        .overlay(
            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                for pt in points.dropFirst() { path.addLine(to: pt) }
                path.closeSubpath()
            }
            .stroke(Color.blue, lineWidth: 2)
        )
    }
}

// MARK: - スコアスライダー
struct ScoreSlidersView: View {
    @Binding var scores: [Double]
    let labels: [String]

    var body: some View {
        VStack(spacing: 8) {
            Text("今日の調子は？").bold()
            ForEach(0..<scores.count, id: \.self) { i in
                HStack {
                    Text(labels[i])
                        .frame(width: 80, alignment: .leading)
                    Slider(value: $scores[i], in: 0...100)
                    Text("\(Int(scores[i]))")
                        .frame(width: 35, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.6))
        .cornerRadius(12)
    }
}

// MARK: - 猫アイコン吹き出し
struct CatTalkView: View {
    let icon: UIImage?
    let catName: String
    let score: Int
    let day: String
    @Binding var weather: String        // Binding に変更
    @ObservedObject var userInfo: UserInfo   // ← 親から渡す
    @State private var showScoreMessage = false
    @State private var showWeatherMessage = false
    @State private var showGreetingMessage = false
    @State private var showFinalScoreMessage = false
    @State private var showNextDayMessage = false

    var body: some View {
        VStack(spacing: 12) {
            if showScoreMessage, let icon = icon {
                messageHStack(icon: icon, text: encouragementMessage(for: score))
            }
            if showWeatherMessage, let icon = icon {
                messageHStack(icon: icon, text: "今日は\(day)、天気は\(weather)だにゃ")
            }
            if showGreetingMessage, let icon = icon {
                messageHStack(icon: icon, text: "じゃあ\(catName)の今日の点数を発表するにゃ")
            }
            if showFinalScoreMessage, let icon = icon {
                messageHStack(icon: icon, text: "\(catName)の今日の気分は多分\(score)点くらいだにゃ")
            }
            if showNextDayMessage, let icon = icon {
                messageHStack(icon: icon, text: "チューる後 \(userInfo.churuCount) 個にゃ")
            }
        }
        .padding(.bottom, 50)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { withAnimation { showScoreMessage = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { withAnimation { showWeatherMessage = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                withAnimation { showGreetingMessage = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
                    withAnimation { showFinalScoreMessage = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation { showNextDayMessage = true }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func messageHStack(icon: UIImage, text: String) -> some View {
        HStack {
            Image(uiImage: icon)
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 3)
                .padding(.leading)

            Text(text)
                .padding(10)
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 2)
            Spacer()
        }
        .padding(.bottom, 5)
        .transition(.opacity)
    }

    private func encouragementMessage(for score: Int) -> String {
        switch score {
        case 0..<40: return "今日は休んで病院行くにゃ！！"
        case 40..<60: return "無理せず、少しずつがんばろうにゃ？"
        case 60..<80: return "いい調子だにゃ！これをキープにゃ"
        default: return "絶好調にゃ！猫缶買ってくるにゃ"
        }
    }
}

// MARK: - AudioAnalyzer
class AudioAnalyzer: ObservableObject {
    private var engine = AVAudioEngine()
    @Published var volume: Float = 0.0
    @Published var pitch: Float = 0.0

    func startRecording() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    self.startEngine()
                } else {
                    print("マイク使用が許可されていません")
                }
            }
        } else {
            // iOS 16 以前
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    self.startEngine()
                } else {
                    print("マイク使用が許可されていません")
                }
            }
        }
    }

    private func startEngine() {
        DispatchQueue.global().async {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                try session.setActive(true)

                let input = self.engine.inputNode
                let format = input.inputFormat(forBus: 0)

                input.removeTap(onBus: 0)
                input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                    self.analyzeBuffer(buffer: buffer, format: format)
                }

                self.engine.prepare()
                try self.engine.start()
                print("録音開始")
            } catch {
                print("AVAudioEngine start error: \(error)")
            }
        }
    }

    func stopRecording() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
    }

    private func analyzeBuffer(buffer: AVAudioPCMBuffer, format: AVAudioFormat) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)

        var rms: Float = 0
        vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(frameLength))
        DispatchQueue.main.async { self.volume = rms }

        var maxVal: Float = 0
        vDSP_maxv(channelData, 1, &maxVal, vDSP_Length(frameLength))
        DispatchQueue.main.async { self.pitch = maxVal }
    }
}

// MARK: - CatVoiceManager
final class CatVoiceManager: ObservableObject {
    @Published var translatedText: String = "まだ鳴き声を翻訳していないよ"
    @Published var isRecording = false
    private var analyzer = AudioAnalyzer()
   
    private var recordingStartTime: Date? // CatVoiceManager のプロパティに追加

    func toggleRecording() {
        if isRecording {
            // 停止処理
            analyzer.stopRecording()
            isRecording = false
            
            let vol = analyzer.volume
            let pit = analyzer.pitch
            
            // 録音時間を計算
            let dur: Double
            if let start = recordingStartTime {
                dur = Date().timeIntervalSince(start)
            } else {
                dur = 1.0 // デフォルト1秒
            }
            
            translatedText = translate(volume: vol, pitch: pit, duration: dur)
        } else {
            // 録音開始処理
            analyzer.startRecording()
            isRecording = true
            recordingStartTime = Date() // 開始時間を記録
            translatedText = "録音中…"
        }
    }

    }

    private func translate(volume: Float, pitch: Float, duration: Double) -> String {
        var candidates: [String] = []

        // --- 音量による候補 ---
        if volume < 0.02 {
            candidates += ["小さな声にゃ", "控えめに呼んでるにゃ"]
        } else if volume < 0.05 {
            candidates += ["お腹が空いたにゃ", "撫でて欲しいにゃ"]
        } else {
            candidates += ["元気いっぱいだにゃ！", "大声で呼んでるにゃ！"]
        }

        // --- ピッチによる候補 ---
        if pitch > 300 {
            candidates += ["遊んで欲しいにゃ", "テンション高いにゃ！"]
        } else if pitch < 150 {
            candidates += ["眠いにゃ…", "リラックスしてるにゃ"]
        } else {
            candidates += ["ちょうど良い気分にゃ", "落ち着いてるにゃ"]
        }

        // --- 鳴き声の長さによる候補 ---
        if duration > 2.0 {
            candidates += ["長く呼んでるにゃ", "しつこく訴えてるにゃ"]
        } else {
            candidates += ["ちょっと鳴いただけにゃ", "気まぐれにゃ"]
        }

        return candidates.randomElement() ?? "にゃ？"
    }


// MARK: - CatVoiceUI (右上ポップ)
struct CatVoiceUI: View {
    @StateObject private var manager = CatVoiceManager()
    @State private var animateShake = false

    var body: some View {
        VStack(spacing: 6) {
            // 録音/停止 ボタン（切り替え式）
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    manager.toggleRecording()
                    animateShake = manager.isRecording
                }
            }) {
                HStack(spacing: 6) {
                    Text("🐱")
                        .font(.system(size: 30))
                        .rotationEffect(.degrees(animateShake ? 10 : 0))
                        .animation(
                            animateShake
                                ? Animation.easeInOut(duration: 0.3).repeatForever(autoreverses: true)
                                : .default,
                            value: animateShake
                        )

                    Text(manager.isRecording ? "録音停止" : "ニャウリンガルで聞いてみよう")
                        .font(.system(size: 10, weight: .bold)) // 小さめフォント
                        .foregroundColor(.white)
                        .padding(.horizontal, 6) // 横余白を縮小
                        .padding(.vertical, 4)   // 縦余白を縮小
                        .background(
                            LinearGradient(
                                colors: manager.isRecording
                                    ? [Color.red, Color.orange]
                                    : [Color.purple, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12) // 角丸も少し小さめ
                        .shadow(color: Color.purple.opacity(0.5), radius: 3, x: 0, y: 2)
                }
            }

            // 翻訳結果表示
            Text(manager.translatedText)
                .font(.caption)
                .foregroundColor(.black)
                .padding(8)
                .background(Color.white.opacity(0.95))
                .cornerRadius(12)
                .shadow(radius: 3)
                .frame(maxWidth: 180)
                .multilineTextAlignment(.center)
        }
        .animation(.easeInOut, value: manager.translatedText)
    }
}

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var userInfo: UserInfo
    @Binding var showHealingMode: Bool  // 親から渡される
    let characterSetting: String        // ← 親から渡すキャラクター設定
    @StateObject private var subscriptionManager = SubscriptionManager()    // --- 各種 State ---
    @State private var showPhotoSheet = false
    @State private var savedImages: [UIImage] = []
    @State private var adjustedScores: [Double] = [80, 40, 50, 70, 60, 90]
    @State private var selectedImage: UIImage? = nil
    @State private var wallpaperImage: UIImage? = nil
    @State private var iconImage: UIImage? = nil
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var isPickerPresented = false
    @State private var currentDay: String = ""
    @State private var currentWeather: String = "晴れ"
    @State private var lastWallpaperDate: String = ""
    @State private var lastCalculationDate: String = ""
    @State private var todayScore: Int = 0
    @State private var showWallpaperOnly: Bool = false
    @State private var userInput: String = ""
    @State private var submittedMessages: [String] = []
    @State private var isInputVisible: Bool = false
    @State private var photos: [PhotoListView.PhotoItem] = []
    @State private var aiReply: String = ""  // ここに追加
    // 選んだだけの画像を保持（保存はまだ）
    @State private var pendingImage: UIImage?
    // --- AI 関連 ---
    @State private var aiInput: String = ""    // ユーザー入力用
    @State private var isThinking: Bool = false // AI 返答中フラグ

    // --- Keyboard監視 ---
    @StateObject private var keyboard = KeyboardResponder()

    @AppStorage("yesterdayScore") private var yesterdayScore: Int = 50
    @State private var showNextDayMessage: Bool = true


    var body: some View {
        NavigationStack { // ← ここでルートをラップ（ContentView の最上位に一度だけ）
            ZStack {
                // 背景：パステルグラデーション
                LinearGradient(
                    colors: [Color.pink.opacity(0.3), Color.yellow.opacity(0.3), Color.blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // 背景パターン
                GeometryReader { geo in
                    ForEach(0..<50, id: \.self) { _ in
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 20, height: 20)
                            .position(
                                x: CGFloat.random(in: 0...geo.size.width),
                                y: CGFloat.random(in: 0...geo.size.height)
                            )
                    }
                }

                // 壁紙（癒しモード）
                if let wallpaper = iconImage, showWallpaperOnly {
                    Image(uiImage: wallpaper)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width,
                               height: UIScreen.main.bounds.height)
                        .clipped()
                        .ignoresSafeArea()
                }

                // UI 切り替え
                if !showWallpaperOnly {
                    normalUI
                } else {
                    healingModeUI
                }

                wallpaperButtons
                catVoiceUI
            }
        }
        .photosPicker(isPresented: $isPickerPresented,
                      selection: $pickerItem,
                      matching: .images)
        .onChange(of: pickerItem, initial: false) { _, newItem in
            handlePickerItemChange(newItem)
        }

        // ここに追加
        .onChange(of: aiReply) { newValue in
            guard !newValue.isEmpty, let item = pickerItem else { return }
            handlePickerItemChange(item)
        }

        .onAppear {
            handleOnAppear()
        }

    }
    // --- 通常 UI ---
    private var normalUI: some View {
        VStack {
            if wallpaperImage == nil {
                Button {
                    isPickerPresented = true
                } label: {
                    Text("今日の猫顔正面写真を撮るのにゃ")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .padding(.horizontal, 20)
                        .padding(.top, 40)
                }
            }

            Spacer()

            RadarChart(scores: adjustedScores,
                       labels: ["気分","ストレス","体力","睡眠","集中力","不安感"])
            .frame(width: 250, height: 250)
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(y: -30)

            if wallpaperImage == nil {
                ScoreSlidersView(scores: $adjustedScores,
                                 labels: ["気分","ストレス","体力","睡眠","集中力","不安感"])
                .transition(.opacity)
                .animation(.default, value: wallpaperImage)
            }

            Spacer()

            // 「昨日の猫」の写真UIは、まだ写真を撮っていない場合だけ表示
            if wallpaperImage == nil {
                PhotoFolderPreview(userInfo: userInfo, photos: photos)
                    .padding(.bottom, 20)

            }

            if let icon = iconImage {
                CatTalkView(
                    icon: icon,
                    catName: userInfo.catCallName,
                    score: todayScore,
                    day: currentDay,
                    weather: $currentWeather,   // Binding のまま
                    userInfo: userInfo          // ← ここを追加
                )
            }

        }
    }
    // --- 癒しモード UI ---
    private var healingModeUI: some View {
        ZStack {
            // 背景写真
            if let wallpaper = iconImage {
                Image(uiImage: wallpaper)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.height)
                    .clipped()
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                    }
            }

            // 上部固定メッセージ
            VStack {
                Text("チューるくれたら診断してやるにゃ。\n三行で悩みを言えにゃ。\n一日一個までにしろにゃ。")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
                    .padding(.top, 80)
                Spacer()
            }

            // 下部固定コンテナ
            VStack(spacing: 12) {
                Spacer() // 下部に押し出す

                // 吹き出し
                VStack(spacing: 12) {
                    ForEach(submittedMessages, id: \.self) { msg in
                        HStack {
                            if msg.starts(with: "user:") {
                                Spacer()
                                Text(msg.replacingOccurrences(of: "user:", with: ""))
                                    .padding(10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .shadow(radius: 2)
                            } else {
                                Text(msg.replacingOccurrences(of: "ai:", with: ""))
                                    .padding(10)
                                    .background(Color.pink.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .shadow(radius: 2)
                                Spacer()
                            }
                        }
                    }
                }

                // チューるあげる UI
                HStack(spacing: 8) {
                    VStack(spacing: 4) {
                        Text("チューるをあげる")
                            .font(.caption)
                            .foregroundColor(.white)
                        Text("残り \(userInfo.churuCount) 個")
                            .font(.caption)
                            .foregroundColor(.white)
                    }

                    Button {
                        if userInfo.churuCount > 0 {
                            userInfo.useChuru(1)  // churuCount を 1 減らす
                            withAnimation { isInputVisible = true }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                            Image(systemName: "fork.knife")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(userInfo.churuCount > 0 ? .pink : .gray)
                        }
                    }
                    .disabled(userInfo.churuCount == 0)
                }
                .padding()
                .background(Color.pink.opacity(0.7))
                .cornerRadius(12)
                .shadow(radius: 3)


                // 入力欄＋送信ボタン（最初は非表示）
                if isInputVisible {
                    HStack(spacing: 8) {
                        TextEditor(text: $aiInput)
                            .frame(height: 80)
                            .padding(6)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                            .onChange(of: aiInput) { newValue, _ in
                                if newValue.count > 30 { aiInput = String(newValue.prefix(30)) }
                            }


                        Button(action: {
                            let userText = aiInput.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !userText.isEmpty else { return }

                            submittedMessages.append("user:\(userText)")

                            if let lastIndex = photos.indices.last,
                               let lastUserMsg = submittedMessages.last(where: { $0.starts(with: "user:") }) {
                                var updatedPhoto = photos[lastIndex]
                                updatedPhoto.userText = lastUserMsg.replacingOccurrences(of: "user:", with: "")
                                photos[lastIndex] = updatedPhoto
                            }

                            aiInput = ""
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil, from: nil, for: nil
                            )
                            withAnimation { isInputVisible = false }

                            isThinking = true
                            submittedMessages.append("ai:考え中…")

                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                Task {
                                    let aiText = await fetchAIReplyText(for: userText)
                                    if let lastIndex = submittedMessages.lastIndex(where: { $0 == "ai:考え中…" }) {
                                        submittedMessages.remove(at: lastIndex)
                                    }
                                    submittedMessages.append("ai:\(aiText)")
                                    aiReply = aiText   // ← ★ここを追加
                                    isThinking = false
                                }
                            }

                        }) {
                            Text("送信")
                                .bold()
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30 + keyboard.currentHeight)
                    .animation(.easeOut(duration: 0.25), value: keyboard.currentHeight)
                }
            }
            .padding(.bottom, 20)
        }
    }



    // AIからの返答を取得
    private func fetchAIReplyText(for prompt: String) async -> String {
        let fullPrompt = "\(characterSetting)\nユーザー: \(prompt)"

        // 環境ごとにURL切替え
        #if DEBUG
        let baseURL = "http://localhost:8787"
        #else
        let baseURL = "https://my-worker.app-lab-nanato.workers.dev"
        #endif

        guard let url = URL(string: baseURL) else {
            return "URLが無効にゃ"
        }

        let body: [String: Any] = ["prompt": fullPrompt]

        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data

            let (responseData, _) = try await URLSession.shared.data(for: request)
            if let json = (try? JSONSerialization.jsonObject(with: responseData)) as? [String: Any],
               let reply = json["reply"] as? String {
                return reply
            } else {
                return "返答形式が不正にゃ"
            }
        } catch {
            return "サーバに接続できないにゃ: \(error.localizedDescription)"
        }
    }

    // --- 壁紙・写真ボタン ---
    private var wallpaperButtons: some View {
        ZStack {
            // --- 壁紙切替ボタン ---
            VStack {
                Spacer().frame(height: UIScreen.main.bounds.height * 0.12)
                HStack {
                    Spacer()
                    Button { showWallpaperOnly.toggle() } label: {
                        VStack {
                            Image(systemName: "pawprint.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text(showWallpaperOnly ? "戻る" : "癒してやるにゃ")
                                .font(.caption)
                                .foregroundColor(.white)
                                .bold()
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [Color.pink, Color.purple],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.purple.opacity(0.5), radius: 5, x: 0, y: 3)
                    }
                    .padding(.trailing, 20)
                }
                Spacer()
            }

            // --- 写真フォルダボタン ---
            VStack {
                Spacer().frame(height: UIScreen.main.bounds.height * 0.38)
                HStack {
                    Spacer()
                    Button { showPhotoSheet.toggle() } label: {
                        VStack {
                            Image(systemName: "folder.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text("写真")
                                .font(.caption)
                                .foregroundColor(.white)
                                .bold()
                        }
                        .padding(12)
                        .background(
                            LinearGradient(colors: [Color.blue, Color.green],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.blue.opacity(0.5), radius: 5, x: 0, y: 3)
                    }
                    .padding(.trailing, 20)
                }
                Spacer()
            }

            // --- 通常画面右下固定チュールボタン ---
            if !showWallpaperOnly {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: PurchaseChuruView()
                                                        .environmentObject(userInfo)) { // ← ここ追加
                            VStack(spacing: 4) {
                                Image(systemName: "fork.knife")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                                Text("チュール\nを買う")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .bold()
                            }
                            .padding(16)
                            .background(
                                LinearGradient(colors: [Color.blue, Color.green],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                            .clipShape(Circle())
                            .shadow(radius: 2)
                        }
                        .padding(.trailing, 20)
                            .padding(.bottom, 100) // ここで下にずらす
                    }
                }
            }
        }
        .sheet(isPresented: $showPhotoSheet) {
            PhotoListView(photos: $photos)
        }
    }

    private var catVoiceUI: some View {
        VStack {
            Spacer().frame(height: UIScreen.main.bounds.height * 0.2)
            HStack {
                Spacer()
                CatVoiceUI()
                    .padding(.trailing, 20)
            }
            Spacer()
        }
        .onAppear {
            print("[DEBUG] ContentView appeared")
        }
    }

    // --- PhotoFolderPreview ---
    struct PhotoFolderPreview: View {
        var userInfo: UserInfo
        var photos: [PhotoListView.PhotoItem]   // ← 外から受け取る

        var body: some View {
            VStack(spacing: 8) {
                Text("写真フォルダ")
                    .font(.headline)

                if photos.isEmpty {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 100)
                        .cornerRadius(8)
                        .overlay(Text("読み込み中").font(.caption))
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(photos, id: \.id) { item in
                                Image(uiImage: item.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    .frame(height: 100)
                }

                Text("昨日の\(userInfo.catCallName)先生")
                    .font(.subheadline)
                    .foregroundColor(.pink)
            }
        }
    }

    // --- 関数 ---
    private func submitUserInput() {
        let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        submittedMessages.append(trimmed)
        userInput = ""
        hideKeyboard()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }

    // MARK: - PickerItemChange ハンドラ（修正版）
    private func handlePickerItemChange(_ newItem: PhotosPickerItem?) {
        guard let newItem = newItem else { return }
        print("DEBUG: handlePickerItemChange called, aiReply = \(aiReply)")

        Task {
            if let data = try? await newItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {

                let datedImage = addDateToImage(uiImage)
                let finalImage = drawTextOnImage(datedImage, text: aiReply)

                selectedImage = finalImage

                // 同じ画像が photos にある場合は追加しない
                if !photos.contains(where: { $0.image.pngData() == finalImage.pngData() }) {
                    photos.append(
                        PhotoListView.PhotoItem(
                            image: finalImage,
                            selectedDate: Date(),
                            userText: userInput
                        )
                    )
                }

                await generateWallpaperAndIconFaceCenter(
                    from: uiImage,
                    wallpaperBinding: $wallpaperImage,
                    iconBinding: $iconImage
                )

                lastWallpaperDate = DateFormatter.localizedString(
                    from: Date(),
                    dateStyle: .short,
                    timeStyle: .none
                )

                calculateAndScheduleScore()
            }
        }
    }


    private func handleOnAppear() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        if lastWallpaperDate != today {
            wallpaperImage = nil
            iconImage = nil
            isPickerPresented = false
            lastWallpaperDate = today
        }

        // 今日の曜日
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        currentDay = dateFormatter.string(from: Date())

        // 🔹 天気をユーザー住所から取得
        Task {
            currentWeather = await fetchWeather(for: userInfo.address)
        }

        if lastCalculationDate != today {
            calculateAndScheduleScore()
            lastCalculationDate = today
        }

        setAppBadge(0)
        scheduleMidnightReset()
    }

    // --- OpenAI を使って天気を取得する例 ---
    @MainActor
    private func fetchWeather(for location: String) async -> String {
        let prompt = "今日の日本の\(location)の天気を簡単な一言で教えてにゃ"

        #if DEBUG
        let baseURL = "http://localhost:8787"
        #else
        let baseURL = "https://my-worker.app-lab-nanato.workers.dev"
        #endif

        guard let url = URL(string: baseURL) else { return "不明" }

        let body: [String: Any] = ["prompt": prompt]

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
                return "不明"
            }
        } catch {
            return "不明"
        }
    }


    private func addDateToImage(_ image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { ctx in
            image.draw(at: .zero)
            let dateString = DateFormatter.localizedString(from: Date(),
                                                           dateStyle: .short,
                                                           timeStyle: .none)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: image.size.width * 0.05),
                .foregroundColor: UIColor.white,
                .shadow: NSShadow()
            ]
            let text = NSString(string: dateString)
            let textSize = text.size(withAttributes: attrs)
            let textPoint = CGPoint(x: image.size.width - textSize.width - 8,
                                    y: image.size.height - textSize.height - 8)
            text.draw(at: textPoint, withAttributes: attrs)
        }
    }

    private func setAppBadge(_ count: Int) {
        if #available(iOS 17.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(count) { error in
                if let error = error { print("バッジ設定エラー: \(error)") }
            }
        } else {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }

    private func calculateAndScheduleScore() {
        let subjectiveAverage = adjustedScores.reduce(0, +) / Double(adjustedScores.count)
        let weekday = Calendar.current.component(.weekday, from: Date())
        let weekdayFactor: Double = (2...6).contains(weekday) ? -5 : 5
        let locationFactor: Double = {
            switch userInfo.address {
            case let addr where addr.contains("Tokyo"): return -3
            case let addr where addr.contains("Osaka"): return 2
            default: return 0
            }
        }()
        let yesterdayFactor = Double(yesterdayScore - 50) * 0.4
        let total = subjectiveAverage + weekdayFactor + locationFactor + yesterdayFactor
        let score = max(0, min(100, Int(total)))

        todayScore = score
        yesterdayScore = score

        let content = UNMutableNotificationContent()
        content.title = "今日のスコア予測"
        content.body = "\(userInfo.catCallName)の今日の気分は多分\(score)点位だにゃ\nまた明日の朝に連絡するにゃ"
        content.sound = .default


        var dateComponents = DateComponents()
        dateComponents.hour = 5
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "morningScoreNotification",
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print("通知登録エラー: \(error)") }
        }
    }

    private func scheduleMidnightReset() {
        let calendar = Calendar.current
        let now = Date()
        guard let nextMidnight = calendar.nextDate(after: now,
                                                   matching: DateComponents(hour:0, minute:0, second:0),
                                                   matchingPolicy: .nextTime) else { return }
        let interval = nextMidnight.timeIntervalSince(now)

        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            wallpaperImage = nil
            iconImage = nil
            isPickerPresented = false
            lastWallpaperDate = DateFormatter.localizedString(from: Date(),
                                                              dateStyle: .short,
                                                              timeStyle: .none)
            todayScore = 0

            setAppBadge(1)
            scheduleMidnightReset()
        }
    }

    @MainActor
    private func generateWallpaperAndIconFaceCenter(
        from image: UIImage,
        wallpaperBinding: Binding<UIImage?>,
        iconBinding: Binding<UIImage?>
    ) async {
        guard let cgImage = image.cgImage else {
            wallpaperBinding.wrappedValue = image
            iconBinding.wrappedValue = image
            return
        }

        do {
            let request = VNDetectFaceRectanglesRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])

            let imgW = CGFloat(cgImage.width)
            let imgH = CGFloat(cgImage.height)
            let bounds = CGRect(x: 0, y: 0, width: imgW, height: imgH)

            var faceRect = bounds
            if let face = request.results?.first as? VNFaceObservation {
                let bx = face.boundingBox.origin.x * imgW
                let by = (1 - face.boundingBox.origin.y - face.boundingBox.height) * imgH
                let bw = face.boundingBox.width * imgW
                let bh = face.boundingBox.height * imgH
                faceRect = CGRect(x: bx, y: by, width: bw, height: bh).integral
            }

            let screenW = UIScreen.main.bounds.width * UIScreen.main.scale
            let screenH = UIScreen.main.bounds.height * UIScreen.main.scale
            let screenAspect = screenW / screenH

            var wpW = imgW
            var wpH = imgW / screenAspect
            if wpH > imgH {
                wpH = imgH
                wpW = imgH * screenAspect
            }
            let wpX = faceRect.midX - wpW/2
            let wpY = faceRect.midY - wpH/2
            let wallpaperRect = CGRect(x: wpX, y: wpY, width: wpW, height: wpH)
                .intersection(bounds)
                .integral

            let wallpaperCg = cgImage.cropping(to: wallpaperRect) ?? cgImage
            let wallpaperUi = UIImage(cgImage: wallpaperCg, scale: image.scale, orientation: image.imageOrientation)
            wallpaperBinding.wrappedValue = wallpaperUi

            let iconSizePt: CGFloat = 80
            let rendererFormat = UIGraphicsImageRendererFormat()
            rendererFormat.scale = UIScreen.main.scale
            rendererFormat.opaque = false

            let renderer = UIGraphicsImageRenderer(size: CGSize(width: iconSizePt, height: iconSizePt),
                                                   format: rendererFormat)

            let finalIcon = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: CGSize(width: iconSizePt, height: iconSizePt)))
            }

            iconBinding.wrappedValue = finalIcon

        } catch {
            print("顔検出エラー: \(error)")
            wallpaperBinding.wrappedValue = image
            iconBinding.wrappedValue = image
        }
    }


    // MARK: - 拡大用ラップ
    struct IdentifiableImage: Identifiable {
        let id = UUID()
        let image: UIImage
    }

    // MARK: - PhotoListView
    struct PhotoListView: View {

        struct PhotoItem: Identifiable {
            let id = UUID()
            let image: UIImage
            let selectedDate: Date
            var userText: String? // 追加: ユーザー入力文
        }

        @Binding var photos: [PhotoItem]
        @Environment(\.dismiss) private var dismiss
        @State private var selectedImage: IdentifiableImage? = nil

        var body: some View {
            NavigationView {
                ZStack {
                    // 背景：パステルグラデーション
                    LinearGradient(
                        colors: [Color.pink.opacity(0.3), Color.yellow.opacity(0.3), Color.blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    List(photos) { photo in
                        HStack(alignment: .top) {
                            Image(uiImage: photo.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(radius: 2)
                                .onTapGesture { selectedImage = IdentifiableImage(image: photo.image) }

                            VStack(alignment: .leading, spacing: 4) {
                                // 日付
                                Text("📸 \(formattedDate(photo.selectedDate))")
                                    .font(.caption2)
                                    .foregroundColor(.gray)

                                // ユーザー入力文
                                if let userText = photo.userText, !userText.isEmpty {
                                    Text(userText)
                                        .font(.body) // 強調
                                        .foregroundColor(.blue)
                                        .padding(6)
                                        .background(Color.white.opacity(0.7))
                                        .cornerRadius(12)
                                        .fixedSize(horizontal: false, vertical: true) // 複数行対応
                                }
                            }

                            Spacer()
                        }
                        .padding(4)
                        .listRowBackground(Color.clear) // ← ここを追加して透過
                    }
                    .listStyle(PlainListStyle()) // ← ここを追加して余計な背景を消す
                }
                .navigationTitle("診断結果")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            HStack { Image(systemName: "chevron.left"); Text("戻る") }
                        }
                    }
                }
                .sheet(item: $selectedImage) { wrapper in
                    ZoomImageView(image: wrapper.image)
                }
            }
        }

        private func formattedDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: date)
        }
    }

    // MARK: - ZoomImageView
    struct ZoomImageView: View {
        let image: UIImage
        @Environment(\.dismiss) var dismiss

        @State private var scale: CGFloat = 1.0
        @State private var offset: CGSize = .zero
        @State private var lastOffset: CGSize = .zero
        @State private var lastScale: CGFloat = 1.0

        var body: some View {
            NavigationView {
                ZStack {
                    Color.black.opacity(0.9).ignoresSafeArea()
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in scale = lastScale * value }
                                    .onEnded { _ in lastScale = scale },
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(width: lastOffset.width + value.translation.width,
                                                        height: lastOffset.height + value.translation.height)
                                    }
                                    .onEnded { _ in lastOffset = offset }
                            )
                        )
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            HStack { Image(systemName: "chevron.left"); Text("戻る") }
                        }
                    }
                }
            }
        }
    }
}


// --- 共通関数 ---
// ここに置く！（ContentView の } の外）

func drawTextOnImage(_ image: UIImage, text: String) -> UIImage {
    let size = image.size
    let renderer = UIGraphicsImageRenderer(size: size)

    return renderer.image { _ in
        image.draw(at: .zero)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping // 長い文字も改行

        // フォントをかわいい手書き風に変更＆サイズ大きめ
        let fontSize = size.width * 0.08 // 元は36
        let font = UIFont(name: "MarkerFelt-Wide", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.systemPink, // 可愛い色
            .paragraphStyle: paragraphStyle,
            .backgroundColor: UIColor.white.withAlphaComponent(0.6)
        ]

        let padding: CGFloat = 20
        let textHeight = text.height(withConstrainedWidth: size.width - 2 * padding, font: font)
        let textRect = CGRect(
            x: padding,
            y: size.height - textHeight - padding,
            width: size.width - 2 * padding,
            height: textHeight
        )

        text.draw(in: textRect, withAttributes: attributes)
    }
}

// --- String 拡張 ---
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}
