//
//  SettingViewController.swift
//  Lonely Fish
//
//  Created by Abe on R 3/06/20.
//
import UIKit
import SpriteKit
import SwiftyGif

class SettingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var normalButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var addCharacterButton: UIButton! {
        didSet {
            addCharacterButton.isHidden = true
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    var difficultySection: String = "easy"
    var characterSelection: String = "clownfish"
    var characterWidthSelection: Double = 90.0
    var characterHeightSelection: Double = 70.0
    var characterJumpSelection: Double = 60.0
    var characterGravitySelection: Double = -5.5
    var characterJapaneseNameSelection: String = "クマノミ"
    
    let characterUrl = "http://mwu.apps.kyusan-u.ac.jp:8086/mwu/games/fish/characters/\(UserDefaults.standard.integer(forKey: "userId")).png"
//    let characterUrl = "http://mwu.apps.kyusan-u.ac.jp:8086/mwu/games/fish/characters/10.png"
    var originalCharacter: UIImage!
    
    struct Content : Codable {
        
        struct Contents : Codable {
            var japaneseName : String
            var floor : String
            var video : String
            var url : String
            var image : String
            var detail : String
        }
        
        struct Parameters : Codable {
            var width : Double
            var height : Double
            var jump : Double
            var gravity : Double
        }
        
        struct Designer : Codable {
            var name : String
            var number : String
        }
        
        var name : String
        var contents : Contents
        var parameters : Parameters
        var designer : Designer
    }
    var settingContents = [Content]()
    
    var decisionButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    private var gameScene: GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadJson()
        if UserDefaults.standard.integer(forKey: "userId") != 0 {
//            addCharacterButton.isHidden = false
//            searchCharacter(characterUrl)
//        }
//        if UserDefaults.standard.integer(forKey: "userId") == 430 {
            addCharacterButton.isHidden = true
            searchCharacter(characterUrl)
        }
        setCellsView()
        setup()
        buttonColor()
        //        collectionView.reloadData()
    }
    
    private func setup() {
        
        difficultySection = UserDefaults.standard.string(forKey: "difficulty") ?? "easy"
        if difficultySection == "" { difficultySection = "easy" }
        characterSelection = UserDefaults.standard.string(forKey: "character") ?? "clownfish"
        if characterSelection == "" { characterSelection = "clownfish" }
        characterWidthSelection = UserDefaults.standard.double(forKey: "characterWidth")
        characterHeightSelection = UserDefaults.standard.double(forKey: "characterHeight")
        characterJumpSelection = UserDefaults.standard.double(forKey: "characterJump")
        characterGravitySelection = UserDefaults.standard.double(forKey: "characterGravity")
        characterJapaneseNameSelection = UserDefaults.standard.string(forKey: "characterJapaneseName") ?? "クマノミ"
        if characterJapaneseNameSelection == "" { characterJapaneseNameSelection = "クマノミ" }
        
        decisionButton = UIBarButtonItem(title: "けってい", style: .done, target: self, action: #selector(decisionButtonTapped(_:))) // .plain:デフォルト .done:太字
        //        decisionButton.tintColor = .white
        cancelButton = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(cancelButtonTapped(_:)))
        
        if #available(iOS 15.0, *) {
            self.navigationController?.navigationBar.backgroundColor = .systemCyan
        }
        
        self.navigationItem.rightBarButtonItem = decisionButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        //        buttonImage()
    }
    
    func setCellsView(){
        
        // for Debug
        print("collectionView.frame.size.width: \(collectionView.frame.size.width)")
        print("collectionView.bounds.size.width: \(collectionView.bounds.size.width)")
        print("self.collectionView.bounds.size.width: \(self.collectionView.bounds.size.width)")
        print("self.view.frame.width: \(self.view.frame.width)")
        
        //        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let flowLayout = UICollectionViewFlowLayout()
        if (UIDevice.modelName.contains("iPad"))
        {
            let width = (collectionView.frame.size.width)
            flowLayout.itemSize = CGSize(width: width, height: width)
        } else {
            flowLayout.itemSize = CGSize(width: self.view.frame.width / 2, height: self.view.frame.width / 2)
        }
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        collectionView.collectionViewLayout = flowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(settingContents.count)
        return settingContents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Identifierが"CollectionViewCell"でCollectionViewCellクラスのcellを取得
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        
        if let originalCharacter = originalCharacter, settingContents[indexPath.item].name == "originalCharacter" {
            cell.characterImageView.setImage(originalCharacter)
        } else {
            guard let image = try? UIImage(imageName: settingContents[indexPath.item].name + "Animated.gif") else { return cell }
            cell.characterImageView.setGifImage(image)
        }
        
        if settingContents[indexPath.item].designer.number.isEmpty {
            cell.designerLabel.text = "\(settingContents[indexPath.item].designer.name) \n "
        } else {
            cell.designerLabel.text = "\(settingContents[indexPath.item].designer.name) \n ( \(settingContents[indexPath.item].designer.number) )"
        }
        
        let easyHighScore: Int = UserDefaults.standard.integer(forKey: "\(settingContents[indexPath.item].name)easyHighScore")
        let normalHightScore: Int = UserDefaults.standard.integer(forKey: "\(settingContents[indexPath.item].name)normalHighScore")
        let hardHighScore: Int = UserDefaults.standard.integer(forKey: "\(settingContents[indexPath.item].name)hardHighScore")
        
        cell.characterHighScore.text = "ハイスコア:\(String(describing: easyHighScore)).\(String(describing: normalHightScore)).\(String(describing: hardHighScore))"
        
        if characterSelection == settingContents[indexPath.row].name{
            cell.backgroundColor = UIColor(red: 0.6745, green: 0.980, blue: 0.97647, alpha: 0.3)
        }else{
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    // cell選択時に呼ばれる関数
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        characterSelection = settingContents[indexPath.item].name
        characterWidthSelection = settingContents[indexPath.item].parameters.width
        characterHeightSelection = settingContents[indexPath.item].parameters.height
        characterJumpSelection = settingContents[indexPath.item].parameters.jump
        characterGravitySelection = settingContents[indexPath.item].parameters.gravity
        characterJapaneseNameSelection = settingContents[indexPath.item].contents.japaneseName
        
        let allCells = settingContents.count
        
        for i in 0 ..< allCells {
            // indexpath rowどこか
            let indexPath = IndexPath(row: i, section: 0)
            collectionView.cellForItem(at: indexPath)?.backgroundColor = .clear
        }
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        cell?.backgroundColor = UIColor(red: 0.6745, green: 0.980, blue: 0.97647, alpha: 0.3)
        
        buttonColor()
    }
    
    
    @IBAction func easyButtonTapped(_ sender: UIButton) {
        difficultySection = "easy"
        buttonColor()
    }
    
    @IBAction func normalButtonTapped(_ sender: UIButton) {
        difficultySection = "normal"
        buttonColor()
    }
    
    @IBAction func hardButtonTapped(_ sender: UIButton) {
        difficultySection = "hard"
        buttonColor()
    }
    
    @objc
    func decisionButtonTapped(_ sender: UIBarButtonItem) {
        
        UserDefaults.standard.set(difficultySection, forKey: "difficulty")
        UserDefaults.standard.set(characterSelection, forKey: "character")
        UserDefaults.standard.set(characterWidthSelection, forKey: "characterWidth")
        UserDefaults.standard.set(characterHeightSelection, forKey: "characterHeight")
        UserDefaults.standard.set(characterJumpSelection, forKey: "characterJump")
        UserDefaults.standard.set(characterGravitySelection, forKey: "characterGravity")
        UserDefaults.standard.set(characterJapaneseNameSelection, forKey: "characterJapaneseName")
        
        if characterSelection == "originalCharacter" {
            // UIImageをData型へ変換
            let characterImage = originalCharacter
            let data = characterImage?.pngData()
            // UserDefaultsへ保存
            UserDefaults.standard.set(data, forKey: "originalCharacter")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //    func buttonImage() {
    //        fishButton.imageView?.contentMode = .scaleAspectFit
    //        fishButton.contentHorizontalAlignment = .fill
    //        fishButton.contentVerticalAlignment = .fill
    //
    //        seaOtterButton.imageView?.contentMode = .scaleAspectFit
    //        seaOtterButton.contentHorizontalAlignment = .fill
    //        seaOtterButton.contentVerticalAlignment = .fill
    //
    //        finlessPorpoiseButton.imageView?.contentMode = .scaleAspectFit
    //        finlessPorpoiseButton.contentHorizontalAlignment = .fill
    //        finlessPorpoiseButton.contentVerticalAlignment = .fill
    //
    //        dolphinButton.imageView?.contentMode = .scaleAspectFit
    //        dolphinButton.contentHorizontalAlignment = .fill
    //        dolphinButton.contentVerticalAlignment = .fill
    //    }
    
    func buttonColor(){
        let selectionColor = UIColor(red: 0.6745, green: 0.980, blue: 0.97647, alpha: 0.3)
        
        switch difficultySection {
        case "easy":
            easyButton.backgroundColor = selectionColor
            normalButton.backgroundColor = .clear
            hardButton.backgroundColor = .clear
            
        case "normal":
            easyButton.backgroundColor = .clear
            normalButton.backgroundColor = selectionColor
            hardButton.backgroundColor = .clear
            
        case "hard":
            easyButton.backgroundColor = .clear
            normalButton.backgroundColor = .clear
            hardButton.backgroundColor = selectionColor
            
        default:
            print("")
        }
    }
    
    private func searchCharacter(_ urlString: String) {
        
        if urlString == "" { return }
        guard let url =  URL(string: urlString) else { return }
        
        let request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData) // キャッシュ無視
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil, response != nil else { return }
            
            print("originalCharacter!: \(data)")
            
            // オリジナルキャラがなかったらその後の処理はしない
            guard let originalCharacter = UIImage(data: data) else { return }
            
            self.originalCharacter = originalCharacter
            self.settingContents.insert(self.settingContents[1], at: 0) // ラッコと同じ大きさ
            self.settingContents[0].name = "originalCharacter"
            self.settingContents[0].contents.japaneseName = "うちの子"
            self.settingContents[0].designer.name = "うちの子"
            self.settingContents[0].designer.number = ""
            self.settingContents[0].parameters.height = 90.0
            // jumpはGameSceneでmass(質量)によって決定
            
            DispatchQueue.main.async {
                
                self.collectionView.reloadData()
                
            }
            
        }.resume()
    }
    
    private func loadJson(){
        // パスの取得
        guard let url = Bundle.main.url(forResource: "Fish", withExtension: "json") else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        self.settingContents = try! JSONDecoder().decode([Content].self, from: data)
        print("aaa \(settingContents.count)")
    }
}
