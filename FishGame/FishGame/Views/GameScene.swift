//
//  GameScene.swift
//  Lonely Fish
//
//  Created by Abe on R 3/06/06.
//  不要なselfはつけない
// 

import SpriteKit
import GameplayKit
import ImageIO

/*
 protocol プロトコル名{
 var プロパティ名: 型{set get}
 func メソッド名（引数名；型） -> 戻り値の型
 }
 */
// delegateで使用するメソッドやプロパティを定義しておく
// delegate: ２つのクラスの間で処理を跨ぐ
protocol GameSceneDelegate: AnyObject {
    //    func didTapMainMenuButton(in gameScene: GameScene)
    //    func updateScore(withScore score: Int, in gameScene:GameScene)
    func clearScreen(in gameScene: GameScene)
    func titleScreen(in gameScene: GameScene)
    func gameOverScreen(in gameScene: GameScene)
}

class GameScene: SKScene, SKPhysicsContactDelegate {
        
    //weak: Aにnilを設定したとき、A→Bの参照数は0となり、ARCが自動破棄
    weak var gameSceneDelegate: GameSceneDelegate?
    
    //    @IBOutlet weak var scoreLabel: UILabel!
    //    var mainCharNode:SKSpriteNode = SKSpriteNode(imageNamed: "fish.gif")
    
    var ground:SKShapeNode = SKShapeNode()
    let titleLabel = SKLabelNode(fontNamed: "HiraMaruProN-W4")
    let startLabel = SKLabelNode(fontNamed: "HiraMaruProN-W4")
    let gameOverLabel = SKLabelNode(fontNamed: "HiraMaruProN-W4")
    let resetLabel = SKLabelNode(fontNamed: "HiraMaruProN-W4")
    let scoreLabel = SKLabelNode(fontNamed: "HiraMaruProN-W4")
    let highScoreLabel = SKLabelNode(fontNamed: "HiraMaruProN-W4")
    var spottedGardenEel:SKSpriteNode = SKSpriteNode()
    var tenjinNowGameOverImage = SKSpriteNode()
    
    var gameScene = GoScene.title // title, play, gameOver
    var score = -1 {
        didSet {
            print("すこあ: \(score)")
            if score < 0 {
                scoreLabel.text = "すこあ：０"
            } else {
                scoreLabel.text = "すこあ：\(score)"
            }
        }
    }
    var upperSeaweed:SKSpriteNode = SKSpriteNode()
    var lowerSeaweed:SKSpriteNode = SKSpriteNode()
    
    let clownfishNode: UInt32 = 0x1 << 0
    let upperSeaweedNode: UInt32 = 0x1 << 1
    let lowerSeaweedNode: UInt32 = 0x1 << 2
   // let spottedGardenEelNode: UInt32 = 0x1 << 3
    let groundNode: UInt32 = 0x1 << 3
    let seaSurfaceNode: UInt32 = 0x1 << 4
    let notHitNode: UInt32 = 0x1 << 5
    
    // Main Character Parameters
    var difficulty = UserDefaults.standard.string(forKey: "difficulty")
    var character = UserDefaults.standard.string(forKey: "character")
    var characterWidth = UserDefaults.standard.double(forKey: "characterWidth")
    var characterHeight = UserDefaults.standard.double(forKey: "characterHeight")
    var characterJump = UserDefaults.standard.double(forKey: "characterJump")
    var characterGravity = UserDefaults.standard.double(forKey: "characterGravity")
    let characterJapaneseName = UserDefaults.standard.string(forKey: "characterJapaneseName")

    var mainCharacterNode:SKSpriteNode = SKSpriteNode()
    var mainCharacterSize:CGSize = CGSize()
    var mainCharacterJump = 100.0
    var mainCharacterGravity = 5.0
    var japaneseName: String = "カクレクマノミ"

    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height

//    var identifier = ""
    
    // ここのSettingは頭文字大文字　Intみたいなもん
    enum GoScene {
        case title
        case play
        case gameOver
        case clear
    }
    
    enum Constant {
        
        // かんたんのクリアスコア
        static let clearScore = 20 // 注意
        
        // 海藻の表示時間のパラメータ（デフォルト）
        static let seaweedBaseTime = 3.5
        
        // 海藻の表示時間のパラメータ（ふつう）
        static let normalBaseReduceTime = 0.0
        static let normalDecreaseTime = 0.05
        static let normalMaxReduceTime = 2.0
        
        // 海藻の表示時間のパラメータ（むずかしい）
        static let hardBaseReduceTime = 1.0
        static let hardDecleaseReduceTime = 0.05
        static let hardMaxReduceTime = 2.5
        
//        static let hardFirstPhase = 1.2
//        static let hardSecondPhase = 1.5
//        static let hardThirdPhase = 1.8
//        static let hardForthPhase = 2.1
    }

    //didMoveの前に呼ばれる
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        setCharacterParameters()
    }
    
    private func setSeaweed() {
        
        var imageName: String = "seaweed"
        
        upperSeaweed = SKSpriteNode()
        lowerSeaweed = SKSpriteNode()
        upperSeaweed.name = "seaweeds" // ?
        
        //        var systemInfo = utsname()
        //        uname(&systemInfo)
        //        let machineMirror = Mirror(reflecting: systemInfo.machine)
        //        identifier = machineMirror.children.reduce("") { identifier, element in
        //            guard let value = element.value as? Int8, value != 0 else { return identifier }
        //            return identifier + String(UnicodeScalar(UInt8(value)))
        //        }
        //        print (identifier)
        //
        //        if identifier.contains("iPhone8") || identifier.contains("iPhone9"){
        
        // A10以前では，アニメーションさせない
        if !( UIDevice.modelName.contains("iPhone SE (1st generation)")
                || UIDevice.modelName.contains("iPhone 6")
                || UIDevice.modelName.contains("iPhone 7")
                || UIDevice.modelName.contains("iPad mini 4")
                || UIDevice.modelName.contains("iPad (5th generation)")
                || UIDevice.modelName.contains("iPad (6th generation)")
                || UIDevice.modelName.contains("iPad (7th generation)")
                || UIDevice.modelName.contains("iPad Air 2")
                || UIDevice.modelName.contains("iPad Pro (9.7-inch)")
                || UIDevice.modelName.contains("iPad Pro (10.5-inch)")
                || UIDevice.modelName.contains("iPad Pro (12.9-inch) (1nd generation)")
                || UIDevice.modelName.contains("iPad Pro (12.9-inch) (2nd generation)") )
        {
            imageName += "Animated" // 上記以外なら，Animated Gifで
        }
        
        let seaweedImageData = try? Data(contentsOf: Bundle.main.url(forResource: imageName, withExtension: "gif")!)
        upperSeaweed = SKSpriteNode.sprite(from: seaweedImageData!)!
        lowerSeaweed = SKSpriteNode.sprite(from: seaweedImageData!)!
        upperSeaweed.run(SKAction.rotate(byAngle: .pi, duration: 0.0))
    }
    
    private func setCharacterParameters() {
        
        guard let character: String = character else { return }
        print("character:\(character)")
        
        var data: URL
        
        if character == "originalCharacter" {
            
            guard let characterData = UserDefaults.standard.data(forKey: "originalCharacter") else { return }
            mainCharacterNode = SKSpriteNode.sprite(from: characterData)!
            
        } else {
            if let characterData = Bundle.main.url(forResource: "\(character)Animated", withExtension: "gif") {
                data = characterData
            } else {
                data = setDefaultCharacter()
            }
            
            let url = try? Data(contentsOf: data)
            mainCharacterNode = SKSpriteNode.sprite(from: url!)!
        }
        
        
        mainCharacterSize = CGSize(width: characterWidth, height: characterHeight)
        mainCharacterJump = characterJump
        mainCharacterGravity = characterGravity
        japaneseName = characterJapaneseName ?? "カクレクマノミ"
    }
    
    override func didMove(to view: SKView) {
        
        //衝突の後にdidBeginContactメソッドが呼ばれるよ！の設定
        print(mainCharacterNode.position)
        self.physicsWorld.contactDelegate = self
        
        mainCharacterNode.size = mainCharacterSize
        mainCharacterNode.alpha = 1.0
        //mainCharacterNode.position = CGPoint(x: width / -2.0 + 50.0 , y: 0.0)
        mainCharacterNode.position = CGPoint(x: -128.0 , y: 0.0)
        //mainCharacterNode.position = CGPoint(x: 0.0 , y: 0.0)
        
        //当たり判定の大きさ
        //        mainCharNode.physicsBody = SKPhysicsBody(rectangleOf: mainCharNode.frame.size)
        if let texture = mainCharacterNode.texture{mainCharacterNode.physicsBody = SKPhysicsBody(texture: texture, size: mainCharacterNode.size)}
        
        
        
        if character == "originalCharacter", mainCharacterNode.physicsBody != nil {
            mainCharacterJump = mainCharacterNode.physicsBody!.mass * 500.0
            print("mass: \(mainCharacterNode.physicsBody!.mass)")
            print("jump: \(mainCharacterJump)")
        }
        
        //重力の設定
        let gravility = (Double(mainCharacterGravity) * Double.random(in: 0.7 ..< 1.3)) * -1.0
//        let gravility = (Double(mainCharacterGravity) * -1
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: gravility)
        
        //重力無効
        mainCharacterNode.physicsBody?.affectedByGravity = false
        //回転させないように指定
        mainCharacterNode.physicsBody?.allowsRotation = false
        //カテゴリ
        mainCharacterNode.physicsBody?.categoryBitMask = clownfishNode
        //衝突 この値とぶつかってくる相手のcategoryBitMaskの値とをAND算出結果が1で衝突する
        mainCharacterNode.physicsBody?.collisionBitMask = upperSeaweedNode | lowerSeaweedNode | groundNode | seaSurfaceNode | notHitNode
        //物体と衝突した時に、通知として送る値
        mainCharacterNode.physicsBody?.contactTestBitMask = upperSeaweedNode | lowerSeaweedNode | groundNode | seaSurfaceNode | notHitNode
        
        addChild(mainCharacterNode)
        
        titleLabel.text = "かいそうをよけよう！"
        titleLabel.fontSize = 60.0
        titleLabel.fontColor = .blue
        titleLabel.position = CGPoint(x: 0.0, y: 100.0)
        titleLabel.alpha = 1.0
        addChild(titleLabel)
        
        // 行数が可変となる
        startLabel.numberOfLines = 0
        let startLabelText = "したはんぶんの\nがめんをタッチ"
        startLabel.text = startLabelText
        // NSMutableAttributedString テキストを装飾するためのクラス NSAttributedStringクラスを継承している
        let attributedString = NSMutableAttributedString(string: startLabelText)
        // 行間
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        // 範囲
        let range = NSRange(location: 0, length: startLabelText.count)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.white,
                                        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 50.0)], range: range)
        
        startLabel.attributedText = attributedString
        startLabel.horizontalAlignmentMode = .center
        //        startLabel.fontSize = 50.0
        //        startLabel.fontColor = .black
        startLabel.position = CGPoint(x: 0.0, y: -250.0)
        startLabel.alpha = 1.0
        startLabel.fontName = "HiraMaruProN-W4"
        addChild(startLabel)
        
        gameOverLabel.text = "ゲームオーバー！"
        gameOverLabel.fontSize = 70.0
        gameOverLabel.fontColor = .orange
        gameOverLabel.position = CGPoint(x: 0.0, y: 0.0)
        gameOverLabel.alpha = 0.0
        addChild(gameOverLabel)
        
        resetLabel.text = "タッチしてリセット"
        resetLabel.fontSize = 50.0
        resetLabel.fontColor = .white
        resetLabel.position = CGPoint(x: 0.0, y: -150.0)
        resetLabel.alpha = 0.0
        addChild(resetLabel)
    
        
        scoreLabel.fontSize = 60.0
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x:  ((frame.height * view.frame.width / view.frame.height / 2.0) * 0.8) ,
                                      y: (frame.height / 2.0) * 0.6)
        
        scoreLabel.alpha = 0.0
        //.top .center .bottom .baseline
        scoreLabel.verticalAlignmentMode = .top
        //.right　.center .left
        scoreLabel.horizontalAlignmentMode = .right
        addChild(scoreLabel)
        
        highScoreLabel.fontSize = 40.0
        highScoreLabel.position = CGPoint(x: 0.0, y: -350)
        highScoreLabel.alpha = 0.0
        highScoreLabel.numberOfLines = 0
        addChild(highScoreLabel)
        
        //        let ground = SKShapeNode(rectOf: CGSize(width: view.frame.width * 2.0, height: view.frame.height/5))
        //        ground.position = CGPoint(x: 0.0, y: view.frame.height / -2.0 - 150)
        ground = SKShapeNode(rectOf: CGSize(width: view.frame.width * 3.0, height: (frame.height * ( 1/10 ))))
        ground.position = CGPoint(x: 0.0, y: frame.height / -2.0 * ( 9/10 ))
        ground.fillColor = UIColor(red: 0.8, green: 0.5647, blue: 0.0745, alpha: 1.0)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.frame.size)
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.categoryBitMask = groundNode
        ground.physicsBody?.collisionBitMask = notHitNode
        addChild(ground)
        
        // てんじんNOW用
        let tenjinNowGameOverImageData = try? Data(contentsOf: Bundle.main.url(forResource: "tenjinNowGameOver", withExtension: "png")!)
        tenjinNowGameOverImage = SKSpriteNode.sprite(from: tenjinNowGameOverImageData!)!
        tenjinNowGameOverImage.position = CGPoint(x: 0.0, y: 200.0)
        tenjinNowGameOverImage.alpha = 0.0
//        addChild(tenjinNowGameOverImage)
        // ここまで
        
        let seaSurface = SKShapeNode(rectOf: CGSize(width: view.frame.width * 2.0, height: 100.0))
        seaSurface.position = CGPoint(x: 0.0, y: view.frame.height / 2.0 + 270.0)
        seaSurface.alpha = 0.0
        seaSurface.physicsBody = SKPhysicsBody(rectangleOf: seaSurface.frame.size)
        seaSurface.physicsBody?.affectedByGravity = false
        seaSurface.physicsBody?.categoryBitMask = seaSurfaceNode
        seaSurface.physicsBody?.collisionBitMask = notHitNode
        addChild(seaSurface)
        
        backgroundColor = .clear
        
        // supported by Yota Tamai(19RS077)
        // ☆以下チンアナゴ画像処理
        // spottedGardenEelのサイズの値(サイズの縦横変化可)
        let SGESize = 100
        // spottedGardenEelの位置の値
        var SGEWidth = -width / 2.0
        var SGEHeight = -height / 2.0
        // 難易度取得
//        let difficulty = UserDefaults.standard.string(forKey: "difficulty")
        // iPad対応
        if (UIDevice.modelName.contains("iPad"))
        {
            SGEWidth = -width / 3.0 + 20.0
            SGEHeight = -height / 3.0 - 10.0
        }// SE対応
        else if(UIDevice.modelName.contains("iPhone SE (1st generation)")
                || UIDevice.modelName.contains("iPhone SE (2nd generation)")
                || UIDevice.modelName.contains("iPhone 8")
                || UIDevice.modelName.contains("iPhone 8 Plus")){
            SGEWidth = -(width / 1.5 + 40.0)
            SGEHeight = -(height / 1.5 + 40.0)
        }
        // case文で難易度ごとに画像を表示
        switch difficulty {
        
        case "easy":
            spottedGardenEel = SKSpriteNode(imageNamed: "oneSpottedGardenEel.png")
            spottedGardenEel.size = CGSize(width: SGESize, height: SGESize)
            spottedGardenEel.position = CGPoint(x: SGEWidth,y: SGEHeight)
            spottedGardenEel.zPosition = -2
            addChild(spottedGardenEel)
            
        case "normal":
            spottedGardenEel = SKSpriteNode(imageNamed: "twoSpottedGardenEel.png")
            spottedGardenEel.size = CGSize(width: SGESize, height: SGESize)
            spottedGardenEel.position = CGPoint(x: SGEWidth,y: SGEHeight)
            spottedGardenEel.zPosition = -2
            addChild(spottedGardenEel)
            
        case "hard":
            spottedGardenEel = SKSpriteNode(imageNamed: "threeSpottedGardenEel.png")
            spottedGardenEel.size = CGSize(width: SGESize, height: SGESize)
            spottedGardenEel.position = CGPoint(x: SGEWidth,y: SGEHeight)
            spottedGardenEel.zPosition = -2
            addChild(spottedGardenEel)
            
        default: break
        }
        // ☆ ここまで
        
        print(view.frame.width)
        print(mainCharacterNode.position)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if(location.y < frame.midY){
                if gameScene == .title { // Title
                    titleTouchAction()
                }
                
                if gameScene == .title || gameScene == .play { // Play
                    playTouchAction()
                }
                else if gameScene == .gameOver { // GameOver
                    gameOverTouchAction()
                }
                else if gameScene == .clear { // clear
                    gameClearTouchAction()
                }
            }
        }
    }
    
    func titleTouchAction() {
        
        titleLabel.alpha = 0.0
        startLabel.alpha = 0.0
        scoreLabel.alpha = 1.0
        gameScene = .play
        mainCharacterNode.physicsBody?.affectedByGravity = true        
        let firstSeaweed = SKAction.run { self.addSeaweed() }
        let  firstAddSeaweeds = SKAction.sequence([SKAction.wait(forDuration: 1.0), firstSeaweed])
        run(firstAddSeaweeds)
    }
    
    func gameOverTouchAction() {
        
        if resetLabel.alpha == 1.0 {
            initialize()
        }
    }
    
    func playTouchAction() {
        // 初期速度を設定
        mainCharacterNode.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        
        //Nodeの質量を無視して力を加える
        mainCharacterNode.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: mainCharacterJump))
        
        let rotationAction = SKAction.rotate(byAngle: .pi/4.0, duration: 0.0)
        let returnRotationAction = SKAction.rotate(byAngle: .pi/(-4.0), duration: 1.0)
        
        mainCharacterNode.run(SKAction.sequence([rotationAction, returnRotationAction]))
        
    }
    
    func gameClearTouchAction(){
        
        guard let character: String = character else { return }
        //保存
        UserDefaults.standard.set(score, forKey: "\(character)easyHighScore")
        if resetLabel.alpha == 1.0 {
            self.gameSceneDelegate?.titleScreen(in: self)
            initialize()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func update(_ currentTime: TimeInterval) {}
    
    func addSeaweed(){
        
        setSeaweed() // 再利用すると，iPad Proでエラー
        
        upperSeaweed.size = CGSize(width: 150.0, height: 820.0)
        //        upperSeaweed.run(SKAction.rotate(byAngle: .pi, duration: 0.0))
        //        upperSeaweed.physicsBody = SKPhysicsBody(rectangleOf: upperSeaweed.frame.size)
        if let texture = upperSeaweed.texture{upperSeaweed.physicsBody = SKPhysicsBody(texture: texture, size: upperSeaweed.size)}
        upperSeaweed.physicsBody?.affectedByGravity = false
        upperSeaweed.physicsBody?.categoryBitMask = upperSeaweedNode
        upperSeaweed.physicsBody?.collisionBitMask = notHitNode
        
        lowerSeaweed.size = CGSize(width: upperSeaweed.frame.width, height: upperSeaweed.frame.height)
        //        lowerSeaweed.physicsBody = SKPhysicsBody(rectangleOf: lowerSeaweed.frame.size)
        if let texture = lowerSeaweed.texture{lowerSeaweed.physicsBody = SKPhysicsBody(texture: texture, size: lowerSeaweed.size)}
        lowerSeaweed.physicsBody?.affectedByGravity = false
        lowerSeaweed.physicsBody?.categoryBitMask = lowerSeaweedNode
        lowerSeaweed.physicsBody?.collisionBitMask = notHitNode
        
        if(gameScene == .play){
            // upperSeaweed.position = CGPoint(x: self.view!ここ.frame.width, y: bottomYPos)
            // force-unwrapは，できるだけつかわない．view = nullだとアプリが落ちる view!はnullが入るかもだけど強制的にunwrapする　String?だとnullを代入できる
            
            guard let view = view else { return }
            
//            let difficulty = UserDefaults.standard.string(forKey: "difficulty")
            
            var lowerPositionY = CGFloat()
            var upperPositionY  = CGFloat()
            
            switch difficulty {
            
            case "easy":
                
                lowerPositionY = CGFloat(Int.random(in: Int(view.frame.height / -2.0 - 350.0)  ..< Int(view.frame.height / -2.0 - 100)))
                lowerSeaweed.position = CGPoint(x: view.frame.width, y: lowerPositionY)
                
                upperPositionY = CGFloat(Int.random(in: Int(lowerSeaweed.position.y + 1300.0) ..< Int(lowerSeaweed.position.y + 1500.0)))
                upperSeaweed.position = CGPoint(x: lowerSeaweed.position.x, y: upperPositionY)
                
            case "normal":
                
                lowerPositionY = CGFloat(Int.random(in: Int(view.frame.height / -2.0 - 350.0)  ..< Int(view.frame.height / -2.0 + 150)))
                lowerSeaweed.position = CGPoint(x: view.frame.width, y: lowerPositionY)
                
                upperPositionY = CGFloat(Int.random(in: Int(lowerSeaweed.position.y + 1200.0) ..< Int(lowerSeaweed.position.y + 1300.0)))
                upperSeaweed.position = CGPoint(x: lowerSeaweed.position.x, y: upperPositionY)
                
            case "hard":
                
                lowerPositionY = CGFloat(Int.random(in: Int(view.frame.height / -2.0 - 350.0)  ..< Int(view.frame.height / -2.0 + 150)))
                lowerSeaweed.position = CGPoint(x: view.frame.width, y: lowerPositionY)
                
                upperPositionY = CGFloat(Int.random(in: Int(lowerSeaweed.position.y + 1100.0) ..< Int(lowerSeaweed.position.y + 1200.0)))
                upperSeaweed.position = CGPoint(x: lowerSeaweed.position.x, y: upperPositionY)
                
            default: break
            }
            
            lowerSeaweed.zPosition = -1
            upperSeaweed.zPosition = -1
            
            addChild(lowerSeaweed)
            addChild(upperSeaweed)
            
//            let moveAction = SKAction.moveTo(x: view.frame.width * -1.5, duration: 3.5 * deviceDurationRatio())
//            lowerSeaweed.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
//            upperSeaweed.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
            
            // 海藻の表示時間
            var durationTime = Constant.seaweedBaseTime
            
            // easyは変化なし
            if difficulty == "normal" {
                
                durationTime -= reduceTime(score: Double(score), baseReduceTime: Constant.normalBaseReduceTime, decleaseReduceTime: Constant.normalDecreaseTime, maxReduceTime: Constant.normalMaxReduceTime)
            }
            else if difficulty == "hard" {
                
                // 0~5は2.3秒 6~10は2.0秒 11~15は1.7秒 16~は1.4秒
                // Nodesが13以下
                
                durationTime -= reduceTime(score: Double(score), baseReduceTime: Constant.hardBaseReduceTime, decleaseReduceTime: Constant.hardDecleaseReduceTime, maxReduceTime: Constant.hardMaxReduceTime)
            }
            
            let moveAction = SKAction.moveTo(x: view.frame.width * -1.5, duration: durationTime * deviceDurationRatio())
            lowerSeaweed.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
            upperSeaweed.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
            // 次のを呼び出す
            let nextSeaweed = SKAction.run { self.addSeaweed() }
            // 4秒待って+1
            let newSeaweed = SKAction.sequence([SKAction.wait(forDuration: 4.0 * deviceDurationRatio()),nextSeaweed])
            run(newSeaweed)
            
            
            score += 1
            
            //view.frame.width * -1.5 : -562.5
            print(view.frame.width * -1.5) //375.0
            print(durationTime)
            
//            // 次のを呼び出す
//            let nextSeaweed = SKAction.run { self.addSeaweed() }
//            // 4秒待って+1
//            let newSeaweed = SKAction.sequence([SKAction.wait(forDuration: 4.0),nextSeaweed])
//            run(newSeaweed)
//
//            score += 1
            
            if difficulty == "easy", score == Constant.clearScore {

                // まずスコアを保存
                if let character = character, let difficulty = difficulty {
                    UserDefaults.standard.set(score, forKey: "\(character)\(difficulty)HighScore")
                }
                clear()
                self.gameSceneDelegate?.clearScreen(in: self)
            }
            
            //            self.gameSceneDelegate?.updateScore(withScore: score,in: self)
        }
    }
    
    private func reduceTime(score: Double,
                            baseReduceTime: Double,
                            decleaseReduceTime: Double,
                            maxReduceTime: Double) -> Double {
        
        let reduceTime = score * decleaseReduceTime + baseReduceTime
        if reduceTime < maxReduceTime {
            return reduceTime * Double.random(in: 0.7 ..< 1.3)
        } else {
            return maxReduceTime * Double.random(in: 0.7 ..< 1.3)
        }
    }
    
    private func clear(){
        
        gameScene = .clear
        
        mainCharacterNode.alpha = 0.0
        upperSeaweed.alpha = 0.0
        lowerSeaweed.alpha = 0.0
        ground.alpha = 0.0
        scoreLabel.alpha = 0.0
        spottedGardenEel.alpha = 0.0
        
        resetLabel.fontColor = .white
        //        resetLabel.position = CGPoint(x: 0.0, y: -400.0)
        resetLabel.position = CGPoint(x: 0.0, y: (frame.height / 2.0) * -0.8)
        
        let resetLabelDisplay = SKAction.run{
            self.resetLabel.alpha = 1.0
        }
        
        let resetLabelDisplayAction = SKAction.sequence([SKAction.wait(forDuration: 3.0), resetLabelDisplay])
        run(resetLabelDisplayAction)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameScene == .play {
            gameScene = .gameOver
            gameOverLabel.alpha = 1.0
            tenjinNowGameOverImage.alpha = 1.0
            
            // 難易度読み込み
//            let difficulty: String = UserDefaults.standard.string(forKey: "difficulty") ?? "easy"
            // キャラクター読み込み
            guard let character: String = character else { return }
            guard let difficulty: String = difficulty else { return }
            
            let highScore = UserDefaults.standard.integer(forKey: "\(character)\(difficulty)HighScore")
            
            if highScore < score {
                //保存
                UserDefaults.standard.set(score, forKey: "\(character)\(difficulty)HighScore")
                highScoreLabel.text = "新記録！ \(japaneseName)\nベストスコア \(score)"
                highScoreLabel.fontColor = .orange
                self.gameSceneDelegate?.gameOverScreen(in: self)
                
            } else {
                highScoreLabel.text = "\(japaneseName)ベスト \(highScore)"
                highScoreLabel.fontColor = .white
                
                // for TANAKA
                if UserDefaults.standard.string(forKey: "userId") == "1" ,
                   character.contains("3") {
                    //最近の値を保存
                    UserDefaults.standard.set(score, forKey: "\(character)\(difficulty)HighScore")
                    self.gameSceneDelegate?.gameOverScreen(in: self)
                }
            }
            
            highScoreLabel.alpha = 1.0
            
            let resetLabelDisplay = SKAction.run{
                self.resetLabel.alpha = 1.0
            }
            
            let resetLabelDisplayAction = SKAction.sequence([SKAction.wait(forDuration: 3.0), resetLabelDisplay])
            run(resetLabelDisplayAction)
        }
    }
    
    private func initialize(){
        //設定したアクションをすべて止める
        removeAllActions()
        resetLabel.alpha = 0.0
        resetLabel.position = CGPoint(x: 0.0, y: -150.0)
        resetLabel.fontColor = .white
        gameOverLabel.alpha = 0.0
        tenjinNowGameOverImage.alpha = 0.0
        titleLabel.alpha = 1.0
        startLabel.alpha = 1.0
        //mainCharacterNode.position = CGPoint(x: (width * width / height / -2.0) * 0.4 , y: 0.0)
        mainCharacterNode.position = CGPoint(x: -128.0 , y: 0.0)
        //        mainCharNode.physicsBody = SKPhysicsBody(rectangleOf: mainCharNode.frame.size)
        if let texture = mainCharacterNode.texture{mainCharacterNode.physicsBody = SKPhysicsBody(texture: texture, size: mainCharacterNode.size)}
        mainCharacterNode.physicsBody?.affectedByGravity = false
        mainCharacterNode.physicsBody?.allowsRotation = false
        mainCharacterNode.physicsBody?.categoryBitMask = clownfishNode
        mainCharacterNode.physicsBody?.collisionBitMask = upperSeaweedNode | lowerSeaweedNode | groundNode | seaSurfaceNode | notHitNode
        mainCharacterNode.physicsBody?.contactTestBitMask = upperSeaweedNode | lowerSeaweedNode | groundNode | seaSurfaceNode | notHitNode
        mainCharacterNode.alpha = 1.0
        upperSeaweed.alpha = 1.0
        lowerSeaweed.alpha = 1.0
        ground.alpha = 1.0
        highScoreLabel.alpha = 0.0
        scoreLabel.alpha = 1.0
        score = -1
        gameScene = .title
        print(mainCharacterNode.position)
    }
    
    private func setDefaultCharacter() -> URL {
        
        let difficultySection: String = "easy"
        let characterSelection: String = "clownfish"
        let characterWidthSelection: Double = 90.0
        let characterHeightSelection: Double = 70.0
        let characterJumpSelection: Double = 60.0
        let characterGravitySelection: Double = 5.0
        let characterJapaneseName = "カクレクマノミ"

        UserDefaults.standard.set(difficultySection, forKey: "difficulty")
        UserDefaults.standard.set(characterSelection, forKey: "character")
        UserDefaults.standard.set(characterWidthSelection, forKey: "characterWidth")
        UserDefaults.standard.set(characterHeightSelection, forKey: "characterHeight")
        UserDefaults.standard.set(characterJumpSelection, forKey: "characterJump")
        UserDefaults.standard.set(characterGravitySelection, forKey: "characterGravity")
        UserDefaults.standard.set(characterJapaneseName, forKey: "characterJapaneseName")
        
        // Main Character Parameters
        difficulty = UserDefaults.standard.string(forKey: "difficulty")
        character = UserDefaults.standard.string(forKey: "character")
        characterWidth = UserDefaults.standard.double(forKey: "characterWidth")
        characterHeight = UserDefaults.standard.double(forKey: "characterHeight")
        characterJump = UserDefaults.standard.double(forKey: "characterJump")
        characterGravity = UserDefaults.standard.double(forKey: "characterGravity")
        japaneseName = UserDefaults.standard.string(forKey: "characterJapaneseName") ?? characterJapaneseName
        
        return Bundle.main.url(forResource: "\(characterSelection)Animated", withExtension: "gif")!
    }
    
}

extension GameScene {
    
    private func deviceDurationRatio() -> Double {
        
        if UIDevice.current.userInterfaceIdiom == .pad { return 2.0 }
        else { return 1.0 }
    }
}
