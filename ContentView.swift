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
                            ForEach(genders, id: \.self) { gender in
                                Text(gender)
                                    .font(.custom("ChalkboardSE-Regular", size: 18))
                                    .tag(gender) // ← tag を明示
                            }
                        }
                        .onAppear {
                            if !genders.contains(userInfo.gender) || userInfo.gender.isEmpty {
                                userInfo.gender = genders.first ?? "男性"
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
                            ForEach(alcoholOptions, id: \.self) { option in
                                Text(option)
                                    .font(.custom("ChalkboardSE-Regular", size: 18))
                                    .tag(option) // ← tag を明示
                            }
                        }
                        .onAppear {
                            if !alcoholOptions.contains(userInfo.alcohol) || userInfo.alcohol.isEmpty {
                                userInfo.alcohol = alcoholOptions.first ?? "なし"
                            }
                        }

                        Picker("喫煙", selection: $userInfo.tobacco) {
                            ForEach(tobaccoOptions, id: \.self) { option in
                                Text(option)
                                    .font(.custom("ChalkboardSE-Regular", size: 18))
                                    .tag(option) // ← tag を明示
                            }
                        }
                        .onAppear {
                            if !tobaccoOptions.contains(userInfo.tobacco) || userInfo.tobacco.isEmpty {
                                userInfo.tobacco = tobaccoOptions.first ?? "なし"
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


// タイトル
struct NeKoLogTitleView: View {
    var body: some View {
        ZStack {
            // 白い文字枠（ずらし重ね）
            ForEach([-1, 1], id: \.self) { x in
                ForEach([-1, 1], id: \.self) { y in
                    Text("〜NeKoLog〜")
                        .font(.custom("SnellRoundhand", size: 36))
                        .foregroundColor(.white)
                        .offset(x: CGFloat(x), y: CGFloat(y))
                }
            }

            // 中央のグラデーション文字
            Text("〜NeKoLog〜")
                .font(.custom("SnellRoundhand", size: 36))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.black, .gray],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .zIndex(10)                  // 常に最前面
        .ignoresSafeArea(edges: .all) // SafeAreaに隠れない
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
        HStack(alignment: .top) {
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
                .fixedSize(horizontal: false, vertical: true) // ← 横幅制限解除・縦折り返し

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading) // ← HStack を画面幅いっぱいに
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
        let request: (Bool) -> Void = { [weak self] granted in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if granted {
                    self.startEngine()
                } else {
                    print("マイク使用が許可されていません")
                }
            }
        }

        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission(completionHandler: request)
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission(request)
        }

    }

    private func startEngine() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            let input = engine.inputNode
            let format = input.inputFormat(forBus: 0)

            input.removeTap(onBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                self.analyzeBuffer(buffer: buffer, format: format)
            }

            engine.prepare()
            try engine.start()
            print("録音開始")
        } catch {
            print("AVAudioEngine start error: \(error)")
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
    private var recordingStartTime: Date?

    func toggleRecording() {
        if isRecording {
            stopRecordingAndTranslate()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        analyzer.startRecording()
        isRecording = true
        recordingStartTime = Date()
        translatedText = "録音中…"
    }

    private func stopRecordingAndTranslate() {
        isRecording = false
        analyzer.stopRecording()
        
        let vol = analyzer.volume
        let pit = analyzer.pitch
        let dur = recordingStartTime.map { Date().timeIntervalSince($0) } ?? 1.0
        
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.translate(volume: vol, pitch: pit, duration: dur)
            DispatchQueue.main.async {
                self.translatedText = result
            }
        }
    }

    private func translate(volume: Float, pitch: Float, duration: Double) -> String {
        var candidates: [String] = []

        if volume < 0.02 { candidates += ["小さな声にゃ", "控えめに呼んでるにゃ"] }
        else if volume < 0.05 { candidates += ["お腹が空いたにゃ", "撫でて欲しいにゃ"] }
        else { candidates += ["元気いっぱいだにゃ！", "大声で呼んでるにゃ！"] }

        if pitch > 300 { candidates += ["遊んで欲しいにゃ", "テンション高いにゃ！"] }
        else if pitch < 150 { candidates += ["眠いにゃ…", "リラックスしてるにゃ"] }
        else { candidates += ["ちょうど良い気分にゃ", "落ち着いてるにゃ"] }

        if duration > 2.0 { candidates += ["長く呼んでるにゃ", "しつこく訴えてるにゃ"] }
        else { candidates += ["ちょっと鳴いただけにゃ", "気まぐれにゃ"] }

        return candidates.randomElement() ?? "にゃ？"
    }
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


func composeCombinedImage(
    aiImage: UIImage,
    aiText: String?,
    userText: String?,
    drawUserText: Bool = false
) -> UIImage? {
    let padding: CGFloat = 16

    let baseWidth = max(aiImage.size.width, 300)
    //AIテキストフォント
    let aiFont = UIFont(name: "RoundedMplus1c-Bold", size: max(14, baseWidth * 0.05))
               ?? UIFont.systemFont(ofSize: max(14, baseWidth * 0.05), weight: .bold)

    let userFont = UIFont.systemFont(ofSize: max(13, baseWidth * 0.045))

    let rightWidth = max(180, baseWidth * 0.6)
    let userTextMaxWidth = rightWidth - 2 * padding

    // ユーザーテキストの高さ
    let userTextHeight: CGFloat = {
        guard drawUserText, let ut = userText, !ut.isEmpty else { return 0 }
        let attr = NSAttributedString(string: ut, attributes: [.font: userFont])
        let rect = attr.boundingRect(
            with: CGSize(width: userTextMaxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return ceil(rect.height)
    }()

    // AIテキストの高さ
    let aiTextHeight: CGFloat = {
        guard let at = aiText, !at.isEmpty else { return 0 }
        let attr = NSAttributedString(string: at, attributes: [.font: aiFont])
        let rect = attr.boundingRect(
            with: CGSize(width: max(100, aiImage.size.width - 2 * padding), height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return ceil(rect.height) + 8
    }()

    // 高さ計算（ユーザーテキスト部分は含めても含めなくてもOK）
    let finalHeight = max(aiImage.size.height, 160)

    // 左側写真のスケール幅
    let leftScaledWidth = aiImage.size.width * (finalHeight / aiImage.size.height)

    // 余白
    let interColumnPadding: CGFloat = padding

    // 横幅計算：ユーザーテキスト部分は含めず、写真＋余白のみ
    let finalWidth = leftScaledWidth + interColumnPadding

    let format = UIGraphicsImageRendererFormat()
    format.scale = aiImage.scale
    format.opaque = false
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: finalWidth, height: finalHeight), format: format)

    return renderer.image { _ in
        // 画像描画
        let leftRect = CGRect(x: 0, y: 0, width: leftScaledWidth, height: finalHeight)
        aiImage.draw(in: leftRect)

        // AIテキスト描画
        if let at = aiText, !at.isEmpty {
            let aiTextRect = CGRect(
                x: leftRect.minX + padding / 2,
                y: leftRect.maxY - aiTextHeight - padding / 2,
                width: max(80, leftRect.width - padding),
                height: aiTextHeight
            )
            let bgRect = aiTextRect.insetBy(dx: -8, dy: -6)
            let bgPath = UIBezierPath(roundedRect: bgRect, cornerRadius: 8)
            UIColor.black.withAlphaComponent(0.5).setFill()
            bgPath.fill()

            let para = NSMutableParagraphStyle()
            para.lineBreakMode = .byWordWrapping
            para.alignment = .left
            let attrs: [NSAttributedString.Key: Any] = [
                .font: aiFont,
                .foregroundColor: UIColor.white,
                .paragraphStyle: para
            ]
            at.draw(with: aiTextRect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }

        // ユーザーテキスト描画
        if drawUserText, let ut = userText, !ut.isEmpty {
            let userBoxHeight = userTextHeight
            let userBoxX = leftScaledWidth + interColumnPadding
            let userBoxY = padding
            let userBoxRect = CGRect(x: userBoxX, y: userBoxY, width: userTextMaxWidth, height: userBoxHeight)
            let bgUserRect = userBoxRect.insetBy(dx: -8, dy: -8)
            let userBgPath = UIBezierPath(roundedRect: bgUserRect, cornerRadius: 12)
            UIColor.white.withAlphaComponent(0.95).setFill()
            userBgPath.fill()

            let para = NSMutableParagraphStyle()
            para.lineBreakMode = .byWordWrapping
            para.alignment = .left
            let attrs: [NSAttributedString.Key: Any] = [
                .font: userFont,
                .foregroundColor: UIColor.black,
                .paragraphStyle: para
            ]
            ut.draw(with: userBoxRect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
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
    @State private var combinedImage: UIImage? = nil
    // --- Keyboard監視 ---
    @StateObject private var keyboard = KeyboardResponder()
    
    @AppStorage("yesterdayScore") private var yesterdayScore: Int = 50
    @State private var showNextDayMessage: Bool = true
    @State private var folderPhotos: [UIImage] = []
    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景：パステルグラデーション
                LinearGradient(
                    colors: [Color.pink.opacity(0.3),
                             Color.yellow.opacity(0.3),
                             Color.blue.opacity(0.3)],
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

                // 🌟 常時タイトル（半透明＋斜め）
                ZStack {
                    Text("〜NeKoLog〜")
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .italic() // 少し斜めの文字
                        .foregroundColor(.black.opacity(0.4))
                        .offset(x: 2, y: 2)
                        .rotationEffect(.degrees(-5)) // 全体を軽く左に傾ける

                    Text("〜NeKoLog〜")
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .italic()
                        .foregroundColor(.white.opacity(0.7))
                        .rotationEffect(.degrees(-5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .allowsHitTesting(false)



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
        .onAppear {
            handleOnAppear()
        }
    }

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
            
            // 最新ひとつ前の画像を取得（UIImage? 型で取得）
            let secondLatestImage = photos.count >= 2 ? photos[photos.count - 2].image : photos.last?.image
            
            // PhotoFolderPreview に渡す
            PhotoFolderPreview(userInfo: userInfo, combinedImage: secondLatestImage)
                .padding(.bottom, 20)
            
            
            
            // ここでまとめる
            if let icon = iconImage {
                CatTalkView(
                    icon: icon,
                    catName: userInfo.catCallName,
                    score: todayScore,
                    day: currentDay,
                    weather: $currentWeather,
                    userInfo: userInfo
                )
            }
        }
    }
    
    // --- 癒しモード UI ---
    private var healingModeUI: some View {
        // 最新ひとつ前の画像を取得
        let secondLatestImage = photos.count >= 2 ? photos[photos.count - 2].image : photos.last?.image

        return ZStack {
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
                Text("チューるくれたら診断してやるにゃ。\n２行で悩みを言えにゃ。\n一日一個までにしろにゃ。")
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
                
                VStack(spacing: 12) {
                    ForEach(submittedMessages, id: \.self) { msg in
                        HStack(alignment: .top) {
                            if msg.starts(with: "user:") {
                                Spacer()
                                Text(msg.replacingOccurrences(of: "user:", with: ""))
                                    .padding(10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .shadow(radius: 2)
                            } else {
                                // AI の吹き出しにアイコンを追加
                                if let icon = secondLatestImage ?? iconImage {
                                    Image(uiImage: icon)
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .shadow(radius: 2)
                                        .padding(.leading, 4)
                                }

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
                            let userTextTrimmed = aiInput.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !userTextTrimmed.isEmpty else { return }
                            
                            submittedMessages.append("user:\(userTextTrimmed)")
                            
                            // 最後の PhotoItem にユーザー入力を反映
                            if let lastPhoto = photos.last {
                                lastPhoto.userText = userTextTrimmed
                            }
                            
                            aiInput = ""
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil, from: nil, for: nil
                            )
                            withAnimation { isInputVisible = false }
                            
                            isThinking = true
                            submittedMessages.append("ai:考え中…")
                            
                            // ----- AI 返信と合成画像更新 -----
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                Task {
                                    // AI 返信取得
                                    let aiText = await fetchAIReplyText(for: userTextTrimmed)
                                    
                                    // --- 前回の AI コメントや「考え中…」を削除 ---
                                    submittedMessages.removeAll { $0.starts(with: "ai:") }
                                    
                                    // --- 新しい AI 返信を追加 ---
                                    submittedMessages.append("ai:\(aiText)")
                                    
                                    // 最新の AI 返信を反映
                                    aiReply = aiText
                                    isThinking = false
                                    
                                    if let img = selectedImage {
                                        // 画面に表示している最新のAI吹き出しを取得
                                        let latestAIText = submittedMessages
                                            .last(where: { $0.starts(with: "ai:") })?
                                            .replacingOccurrences(of: "ai:", with: "") ?? ""

                                        combinedImage = composeCombinedImage(
                                            aiImage: img,
                                            aiText: latestAIText,  // ← AIの吹き出しだけ
                                            userText: nil,         // ← ユーザーは描画しない
                                            drawUserText: false    // ← フラグも false に固定
                                        )
                                    }

                                }
                            }

                            // ユーザー入力送信時
                            if let lastPhoto = photos.last {
                                lastPhoto.userText = userTextTrimmed
                                lastPhoto.combinedImage = composeCombinedImage(
                                    aiImage: lastPhoto.image,
                                    aiText: nil,
                                    userText: userTextTrimmed,
                                    drawUserText: false
                                )
                            }

                            // ----- AI 返信と合成画像更新 -----
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                Task {
                                    let aiText = await fetchAIReplyText(for: userTextTrimmed)

                                    // 更新（UI 表示）
                                    submittedMessages.removeAll { $0.starts(with: "ai:") }
                                    submittedMessages.append("ai:\(aiText)")
                                    aiReply = aiText
                                    isThinking = false

                                    // 最後の PhotoItem を取り直して安全に更新
                                    if let lastPhoto = photos.last {
                                        lastPhoto.aiText = aiText

                                        // ① baseImage を決める（既にユーザー文字入り画像があればそれを使う）
                                        let baseImage: UIImage = {
                                            if let combined = lastPhoto.combinedImage {
                                                return combined
                                            }
                                            // combinedImage が無ければ、userText があればその場で生成しておく
                                            if let ut = lastPhoto.userText, !ut.isEmpty,
                                               let userTextImage = composeCombinedImage(
                                                   aiImage: lastPhoto.image,
                                                   aiText: nil,
                                                   userText: ut,
                                                   drawUserText: true
                                               ) {
                                                // 保存しておく（以降はこれをベースにする）
                                                lastPhoto.combinedImage = userTextImage
                                                return userTextImage
                                            }
                                            // どちらもなければ元画像
                                            return lastPhoto.image
                                        }()

                                        // ② baseImage の上に AI テキストを合成（ユーザーテキストは既に埋め込まれている想定）
                                        lastPhoto.combinedImage = composeCombinedImage(
                                            aiImage: baseImage,
                                            aiText: aiText,
                                            userText: nil,
                                            drawUserText: false
                                        )

                                        // UI 表示用の selectedImage / combinedImage も更新しておく（必要なら）
                                        selectedImage = lastPhoto.combinedImage
                                        combinedImage = lastPhoto.combinedImage
                                    }
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
    
    
    // MARK: - PickerItemChange ハンドラ（吹き出し文をそのまま利用）
    private func handlePickerItemChange(_ newItem: PhotosPickerItem?) {
        guard let newItem = newItem else { return }
        print("DEBUG: handlePickerItemChange called, aiReply = \(aiReply)")
        
        Task {
            if let data = try? await newItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                // --- 日付は描画せず、元画像を使用 ---
                let baseImage = uiImage

                // selectedImage には元画像のみを保持
                selectedImage = baseImage
                
                // photos 配列に追加（重複は避ける）
                let newPhoto = PhotoListView.PhotoItem(
                    image: baseImage,
                    selectedDate: Date(),
                    userText: userInput,
                    aiText: aiReply   // ← ここは新規取得ではなく、吹き出し文をそのまま使用
                )
                
                if !photos.contains(where: { $0.userText == userInput && $0.aiText == aiReply }) {
                    photos.append(newPhoto)
                }
                
                // --- 最新の吹き出し文を使って合成画像を生成 ---
                combinedImage = composeCombinedImage(
                    aiImage: baseImage,
                    aiText: aiReply,
                    userText: userInput
                )
                
                // --- 写真フォルダ一覧用に追加 ---
                folderPhotos.append(baseImage)
                
                // 壁紙やアイコン生成など既存処理
                await generateWallpaperAndIconFaceCenter(
                    from: uiImage,
                    wallpaperBinding: $wallpaperImage,
                    iconBinding: $iconImage
                )
                
                // 最終更新日
                lastWallpaperDate = DateFormatter.localizedString(
                    from: Date(),
                    dateStyle: .short,
                    timeStyle: .none
                )
                
                calculateAndScheduleScore()
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
    
    private func drawTextInsideImage(_ image: UIImage, text: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { ctx in
            image.draw(at: .zero)

            // 最大フォントサイズから始める
            var fontSize = image.size.width * 0.08
            var attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: fontSize),
                .foregroundColor: UIColor.white
            ]

            var textSize = (text as NSString).size(withAttributes: attributes)

            // 画像の幅 − マージン 以内に収まるまでフォントサイズを縮小
            let maxWidth = image.size.width * 0.9
            while textSize.width > maxWidth && fontSize > 8 {
                fontSize -= 1
                attributes[.font] = UIFont.boldSystemFont(ofSize: fontSize)
                textSize = (text as NSString).size(withAttributes: attributes)
            }

            // 位置（ここでは中央下）
            let point = CGPoint(
                x: (image.size.width - textSize.width) / 2,
                y: image.size.height - textSize.height - 12
            )

            (text as NSString).draw(at: point, withAttributes: attributes)
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

        class PhotoItem: ObservableObject, Identifiable {
            let id = UUID()
            let image: UIImage
            let selectedDate: Date
            @Published var userText: String?
            @Published var aiText: String?
            @Published var combinedImage: UIImage?

            init(image: UIImage, selectedDate: Date, userText: String? = nil, aiText: String? = nil, combinedImage: UIImage? = nil) {
                self.image = image
                self.selectedDate = selectedDate
                self.userText = userText
                self.aiText = aiText
                self.combinedImage = combinedImage
            }
        }

        @Binding var photos: [PhotoItem]
        @Environment(\.dismiss) private var dismiss
        @State private var selectedPhotoItem: PhotoItem? = nil // PhotoItem 全体を保持

        var body: some View {
            NavigationView {
                ZStack {
                    LinearGradient(
                        colors: [Color.pink.opacity(0.3), Color.yellow.opacity(0.3), Color.blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    List(photos) { photo in
                        PhotoRowView(photo: photo)
                            .onTapGesture { selectedPhotoItem = photo }
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                    .navigationTitle("診断結果")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(leading:
                                            Button(action: { dismiss() }) {
                        Text("戻る")
                    }
                    )
                    .sheet(item: $selectedPhotoItem) { photoItem in
                        ZoomImageView(
                            image: photoItem.combinedImage ?? photoItem.image
                        )
                    }


                }
            }
        }

        // AI返信確定時に呼び出す関数
        func updatePhotoWithAI(photo: PhotoItem, aiText: String) {
            // PhotoItem 自体が ObservableObject なので直接更新
            photo.aiText = aiText
            photo.combinedImage = composeCombinedImage(
                aiImage: photo.image,
                aiText: aiText,
                userText: photo.userText
            )
        }

        // --- body 外に置く ---
        func formattedDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: date)
        }
    }

    // MARK: - PhotoRowView
    struct PhotoRowView: View {
        @ObservedObject var photo: PhotoListView.PhotoItem
        private func formattedDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: date)
        }
        var body: some View {
            HStack(alignment: .top, spacing: 12) {

                // 左：AI合成済み画像があればそれを表示、なければ元画像
                Image(uiImage: photo.combinedImage ?? photo.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 2)

                // 右：ユーザーコメント＋日付
                VStack(alignment: .leading, spacing: 4) {
                    if let userText = photo.userText, !userText.isEmpty {
                        Text(userText)
                            .font(.body)
                            .foregroundColor(.blue)
                            .padding(6)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(12)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // 日付表示
                    Text(formattedDate(photo.selectedDate))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding(4)
        }
    }

    struct ZoomImageView: View {
        let image: UIImage
        @Environment(\.dismiss) private var dismiss
        @State private var scale: CGFloat = 1.0
        @State private var offset: CGSize = .zero
        @State private var lastOffset: CGSize = .zero
        @State private var lastScale: CGFloat = 1.0

        var body: some View {
            NavigationView {
                ZStack {
                    Color.black.opacity(0.9).ignoresSafeArea()

                    // 元画像のみ表示、AIテキストは描画しない
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
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
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

    // 元に戻す最小構成（呼び出し側と整合）
    struct PhotoFolderPreview: View {
        var userInfo: UserInfo
        var combinedImage: UIImage?  // 呼び出しで渡されている引数に合わせる
        
        var body: some View {
            VStack(spacing: 8) {
                // combinedImage があれば表示、なければプレースホルダ
                if let combined = combinedImage {
                    Image(uiImage: combined)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding(.bottom, 20)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 100)
                        .cornerRadius(8)
                        .overlay(Text("読み込み中").font(.caption))
                }
                
                // 「昨日の〜先生」は元どおり表示
                Text("昨日の\(userInfo.catRealName)先生")
                    .font(.subheadline)
                    .foregroundColor(.pink)
            }
        }
    }
    
}
// --- String 拡張（必ずファイルスコープ・struct/class の外） ---
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
