//
//  Ranking.swfit.swift
//  MWU
//
//  Created by Abe on R 3/08/07.
//  Copyright © Reiwa 3 Kyushu Sangyo University. All rights reserved.
//

import Foundation
import UIKit

class RankingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var characterLabel: UILabel!
    @IBOutlet var difficultyLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
            pickerView.dataSource = self
        }
    }

    @IBOutlet var rankingTableView: UITableView! {
        didSet {
            rankingTableView.delegate = self
            rankingTableView.dataSource = self
            // カスタムセル登録
            rankingTableView.register(UINib(nibName: "RankingTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        }
    }

    @IBOutlet var ownId: UIButton! {
        didSet {
            ownId.setTitle("じぶんのID : \(UserDefaults.standard.integer(forKey: "userId")) 》", for: .normal)
        }
    }

    @IBOutlet var grayView: UIView!
    @IBOutlet var informationView: UIView!

//    private let cell = "cell"

    struct Content: Codable {
        struct Contents: Codable {
            var japaneseName: String
            var floor: String
            var video: String
            var url: String
            var image: String
            var detail: String
        }

        struct Parameters: Codable {
            var width: Double
            var height: Double
            var jump: Double
            var gravity: Double
        }

        struct Designer: Codable {
            var name: String
            var number: String
        }

        var name: String
        var contents: Contents
        var parameters: Parameters
        var designer: Designer
    }

    var contents = [Content]()

    struct HighScoreContent: Codable {
        var id: Int
        var userId: Int
        var fishCharacter: String
        var difficulty: String
        var score: Int
        var flag: Int
        var modified: String
        var created: String
    }

    var highScoreContents = [HighScoreContent]() {
        didSet {
            rankingTableView.reloadData()
        }
    }

    // 定数はこんな感じで書くことにしましょうか．
    enum Constant {
        static let limit = 20
        static let defaultFishCharacter = "originalCharacter"
        static let difficultyJapaneseData = ["かんたん", "ふつう", "むずかしい"]
        static let difficultyData = ["easy", "normal", "hard"]
        static let typeDate = ["きょう", "こんげつ", "ぜんたい"]
        static let rankingData = ["🥇", "🥈", "🥉"]
        static let sectionLabels = ["じゅんい", "ID", "すこあ", "にちじ"]
    }

    var fishCharacter: String = Constant.defaultFishCharacter
    var difficulty: String = Constant.difficultyData[0]
    var created: String = ""
    var type: String = Constant.typeDate[0]
    var date: String = ""
    var month: String = ""

    private func setDateMonth() {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        date = dateFormatter.string(from: today).replacingOccurrences(of: "/", with: "-")
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMM", options: 0, locale: Locale(identifier: "ja_JP"))
        month = dateFormatter.string(from: today).replacingOccurrences(of: "/", with: "-")
        print(date)
        print(month)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // pickerviewに表示する列数
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // pickerviewに表示するデータの数
        switch component {
        case 0:
            return contents.count
        case 1:
            return Constant.difficultyJapaneseData.count
        case 2:
            return Constant.typeDate.count
        default:
            return 0
        }
    }

//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    // ドラムロールの各タイトル
//        switch component {
//        case 0:
//            return contents[row].contents.japaneseName
//        case 1:
//            return difficultyData[row]
//        case 2:
//            return typeDate[row]
//        default:
//            return "error"
//        }
//    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        // ドラムロールの各タイトル
        switch component {
        case 0:
            label.text = contents[row].contents.japaneseName
        case 1:
            label.text = Constant.difficultyJapaneseData[row]
        case 2:
            label.text = Constant.typeDate[row]
        default:
            print("error")
        }

        label.textAlignment = .center
        label.font = UIFont(name: "HiraMaruProN-W4", size: 18)
        label.textColor = .white

        return label
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return (pickerView.frame.width / 2) - 20
        default:
            return pickerView.frame.width / 4
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            characterLabel.text = contents[row].contents.japaneseName
            fishCharacter = contents[row].name
//            setup()
        case 1:
            difficultyLabel.text = Constant.difficultyJapaneseData[row]
            difficulty = Constant.difficultyData[row]
//            setup()
        case 2:
            typeLabel.text = "\(Constant.typeDate[row])のランキング"
            type = Constant.typeDate[row]
//            setup()

        default:
            break
        }

        loadHighScore()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setDateMonth()
        loadCharacters()
        createPickerView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadHighScore()
    }

//    var characterData = ["カクレクマノミ", "ラッコ", "スナメリ", "イルカ"]
//    let difficultyJapaneseData = ["かんたん", "ふつう", "むずかしい"]
//    let difficultyData = ["easy", "normal", "hard"]
//    let typeDate = ["きょう", "こんげつ", "ぜんたい"]
//    let rankingData: [Int] = Array(1..<11)
//    let rankingData = ["🥇", "🥈", "🥉", " ", " ", " ", " ", " ", " ", " "," ", " ", " ", " ", " ", " ", " ", " ", " ", " "]
//    let rankingData = ["🥇", "🥈", "🥉"]

    func createPickerView() {
        // toolbar
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(RankingViewController.donePicker))
        toolbar.setItems([doneButtonItem], animated: true)
    }

    private func loadHighScore() {
        var highScoreUrl = "http://mwu.apps.kyusan-u.ac.jp:8086/mwu/games/fish/conditionsSearch.php?fishCharacter=\(fishCharacter)&difficulty=\(difficulty)&limit=\(Constant.limit)"

        if type == Constant.typeDate[0] { highScoreUrl += "&created=\(date)" }
        else if type == Constant.typeDate[1] { highScoreUrl += "&created=\(month)" }

        loadHighScoreJson(highScoreUrl)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("highScoreContents.count:\(highScoreContents.count)")

        return highScoreContents.count // + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? RankingTableViewCell {
//            let ranking = rankingData[indexPath.row]
            let userId: String = String(highScoreContents[indexPath.row].userId)
//            let score = highScoreContents[indexPath.row].score
//            let time = highScoreContents[indexPath.row].created
//            var imageView = ""

            if indexPath.row <= 2 {
                cell.rankingImageView?.alpha = 0.0 // いらない？
                cell.rankingImageView?.image = UIImage()
                cell.rankingLabel?.text = Constant.rankingData[indexPath.row]

            } else {
                cell.rankingImageView?.alpha = 1.0 // いらない？
                cell.rankingImageView?.image = UIImage(named: "\(indexPath.row + 1).square.fill")
                cell.rankingLabel?.text = ""
            }

            cell.userIdLabel?.text = userId
            cell.scoreLabel?.text = String(highScoreContents[indexPath.row].score)
            cell.timeLabel?.text = highScoreContents[indexPath.row].created

            cell.rankingLabel?.font = cell.rankingLabel?.font.withSize(30)
            cell.userIdLabel?.font = cell.userIdLabel?.font.withSize(16)
            cell.scoreLabel?.font = cell.scoreLabel?.font.withSize(16)
            cell.timeLabel?.font = cell.timeLabel?.font.withSize(12)

            // userIdが0の人はハイスコア,それ以外の人はuserIdで判定
            let storedUserId = UserDefaults.standard.integer(forKey: "userId")
            if userId == String(storedUserId) || storedUserId == 0 && cell.scoreLabel?.text == "\(UserDefaults.standard.integer(forKey: "\(fishCharacter)\(difficulty)HighScore"))" {
//                cell.view.backgroundColor = UIColor(red: 0, green: 0, blue: 1.0, alpha: 0.3)

                // お知らせと統一
                cell.view.backgroundColor = UIColor(named: "NewsTableViewBackgroundColor1")
                cell.userIdLabel?.textColor = UIColor(named: "NewsTableViewTextColor1")
                cell.scoreLabel?.textColor = UIColor(named: "NewsTableViewTextColor1")
                cell.timeLabel?.textColor = UIColor(named: "NewsTableViewTextColor1")

            } else {
//                cell.view.backgroundColor = .systemBackground

                // お知らせと統一
                cell.view.backgroundColor = UIColor(named: "NewsTableViewBackgroundColor2")
                cell.userIdLabel?.textColor = UIColor(named: "NewsTableViewTextColor2")
                cell.scoreLabel?.textColor = UIColor(named: "NewsTableViewTextColor2")
                cell.timeLabel?.textColor = UIColor(named: "NewsTableViewTextColor2")
            }

            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? RankingTableViewCell {
            cell.rankingLabel?.text = Constant.sectionLabels[0]
            cell.userIdLabel?.text = Constant.sectionLabels[1]
            cell.scoreLabel?.text = Constant.sectionLabels[2]
            cell.timeLabel?.text = Constant.sectionLabels[3]

            cell.rankingLabel?.font = cell.rankingLabel?.font.withSize(18)
            cell.userIdLabel?.font = cell.userIdLabel?.font.withSize(18)
            cell.scoreLabel?.font = cell.scoreLabel?.font.withSize(18)
            cell.timeLabel?.font = cell.timeLabel?.font.withSize(18)

            cell.view.backgroundColor = .lightGray
            cell.rankingLabel?.textColor = .label
            cell.userIdLabel?.textColor = .label
            cell.scoreLabel?.textColor = .label
            cell.timeLabel?.textColor = .label

            cell.rankingImageView?.alpha = 0.0

            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 15,*) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        return 48
    }

    @objc func donePicker() {
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    @IBAction func ownIdButtonTapped(_ sender: UIButton) {
        view.bringSubviewToFront(grayView)
        view.bringSubviewToFront(informationView)
    }

    @IBAction func informationButtonTapped(_ sender: UIButton) {
        view.sendSubviewToBack(informationView)
        view.sendSubviewToBack(grayView)
    }

    private func loadCharacters() {
        // パスの取得
        guard let url = Bundle.main.url(forResource: "Fish", withExtension: "json") else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        contents = try! JSONDecoder().decode([Content].self, from: data)

        contents.insert(contents[0], at: 0)
        contents[0].name = "originalCharacter"
        contents[0].contents.japaneseName = "うちの子"
        contents[0].designer.name = "うちの子"
        contents[0].designer.number = ""
    }

    private func loadHighScoreJson(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        print(url)
        _ = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Error: \(error)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                do {
                    let highScoreContents = try JSONDecoder().decode([HighScoreContent].self, from: data)
                    DispatchQueue.main.async {
                        self.highScoreContents = highScoreContents
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
    }
}
