//
//  GameViewController.swift
//  Lonely Fish
//
//  Created by Abe on R 3/06/06.
//

import UIKit
import SpriteKit
import GameplayKit
import APNGKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var gamePlayView: SKView!
    @IBOutlet weak var backgroundImageView: APNGImageView!{
        didSet{
//            backgroundImageView.autoStartAnimation = true
            backgroundImageView.autoStartAnimationWhenSetImage = true
        }
    }
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var grayView: UIView!
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    private var gameScene: GameScene?
    
    
    // 定数はこんな感じで書くことにしましょうか．
    enum Constant {
        static let backgroundImageName = "backgroundAnimated.png"
        static let clearImageName = "congratulationAnimated.png"
        static let gameSceneName = "GameScene"
        static let scoreLabelText = "すこあ："
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCharacter()
    }
    
    private func setCharacter() {
        
        UserDefaults.standard.register(defaults: ["difficulty": "easy"])
        UserDefaults.standard.register(defaults: ["character": "clownfish"])
        UserDefaults.standard.register(defaults: ["characterWidth": 90.0])
        UserDefaults.standard.register(defaults: ["characterHeight": 70.0])
        UserDefaults.standard.register(defaults: ["characterJump": 60.0])
        UserDefaults.standard.register(defaults: ["characterGravity": 5.0])
        UserDefaults.standard.register(defaults: ["characterJapaneseName": "カクレクマノミ"])
    }
    
    // viewDidLoad: viewがロードされた後に呼び出される　初期表示時に必要な処理を設定
    // viewWillAppear: viewが表示される直前に呼ばれる　viewDidLoadとは異なり毎回呼び出される
    // viewDidAppear: 完全に遷移が行われ、スクリーン上に表示されたときに呼ばれる　毎回呼び出される
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.sendSubviewToBack(backgroundView)
        view.sendSubviewToBack(alertView)
        view.sendSubviewToBack(grayView)
        setupGamePlayView()
        colorsByDifficulty()
    }
    
    private func setupGamePlayView() {
        
        // ここでviewをgamePlayViewに設定
        if let view = gamePlayView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: Constant.gameSceneName) {
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                setDelegate(scene as! GameScene)
                
                setupGamePlayView(view: view, scene: scene)
                setupBackgroundImageView(Constant.backgroundImageName)
//                setupClearImageView(Constant.clearImageName)
            }
        }
    }
    
    private func setupGamePlayView(view: SKView, scene: SKScene) {
        // Present the scene
        view.presentScene(scene)
        
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        view.backgroundColor = .clear
    }
    
    private func setupBackgroundImageView(_ backgroundImageName: String) {
        backgroundImageView.image = nil
        backgroundImageView.image = try? APNGImage(named: backgroundImageName)
    }
    
    private func setupClearImageView(_ clearImageName: String) {
        backgroundImageView.image = nil
        backgroundImageView.image = try? APNGImage(named: clearImageName)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func colorsByDifficulty(){
        let difficulty = UserDefaults.standard.string(forKey: "difficulty")
        
        switch difficulty {
        case "easy":
            self.navigationItem.title = "ミニゲーム"
            if #available(iOS 15.0, *) {
                self.navigationController?.navigationBar.backgroundColor = .systemMint
            } else {
                self.navigationController?.navigationBar.backgroundColor = .systemTeal
            }
            
        case "normal":
            self.navigationItem.title = "ミニゲーム"
            if #available(iOS 15.0, *) {
                self.navigationController?.navigationBar.backgroundColor = .systemTeal
            } else {
                self.navigationController?.navigationBar.backgroundColor = .systemBlue
            }
            
        case "hard":
            self.navigationItem.title = "ミニゲーム"
            self.navigationController?.navigationBar.backgroundColor = .systemIndigo
            
        default: break
        
        }
    }
    
    @IBAction func yesButtonTapped(_ sender: UIButton) {
        
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let character = UserDefaults.standard.string(forKey: "character")
        let difficulty = UserDefaults.standard.string(forKey: "difficulty")
        
        guard let character: String = character else { return }
        guard let difficulty: String = difficulty else { return }
        
        let score = UserDefaults.standard.integer(forKey: "\(character)\(difficulty)HighScore")
        let url = URL(string: "http://mwu.apps.kyusan-u.ac.jp:8086/mwu/games/fish/registration.php?userId=\(userId)&fishCharacter=\(character)&difficulty=\(difficulty)&score=\(score)")
        DispatchQueue.global().async { _ = try? Data(contentsOf: url!) }
        
        view.sendSubviewToBack(alertView)
        view.sendSubviewToBack(grayView)
        
    }
    
    @IBAction func noButtonTapped(_ sender: UIButton) {
        view.sendSubviewToBack(alertView)
        view.sendSubviewToBack(grayView)
    }
    
}

extension GameViewController : GameSceneDelegate {

    func setDelegate(_ gameScene: GameScene) {

        gameScene.gameSceneDelegate = self
    }
    
    func clearScreen(in gameScene: GameScene) {
        setupClearImageView(Constant.clearImageName)
        view.bringSubviewToFront(backgroundView)
        view.bringSubviewToFront(gamePlayView)
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(alertViewDisplay), userInfo: nil, repeats: false)
    }
    
    func titleScreen(in gameScene: GameScene) {
        setupBackgroundImageView(Constant.backgroundImageName)
        view.sendSubviewToBack(backgroundView)
        view.sendSubviewToBack(alertView)
        view.sendSubviewToBack(grayView)
    }
    
    func gameOverScreen(in gameScene: GameScene) {
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(alertViewDisplay), userInfo: nil, repeats: false)
    }
    
    @objc private func alertViewDisplay() {
        // 2秒後に実行
        view.bringSubviewToFront(grayView)
        view.bringSubviewToFront(alertView)
    }

}
