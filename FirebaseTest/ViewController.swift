//
//  ViewController.swift
//  FirebaseTest
//
//  Created by Daisuke Shimizu on 2024/12/14.
//

import UIKit
import FirebaseCore
import FirebaseDatabase

class ViewController: UIViewController {
    @IBOutlet weak var targetIdText: UITextField!   // 接続先ユーザーIDの入力ボックス
    @IBOutlet weak var connectButton: UIButton!     // 接続ボタン
    
    @IBOutlet weak var stateLabel: UILabel!     // 接続状態ラベル
    @IBOutlet weak var userIdLabel: UILabel!    // 接続されたユーザーIDラベル
    @IBOutlet weak var nameText: UITextField!   // DBへリアルタイムに更新する名前の入力ボックス
    @IBOutlet weak var nameLabel: UILabel!      // DBからリアルタイムに参照された名前ラベル
    @IBOutlet weak var ageText: UITextField!    // DBへリアルタイムに更新する年齢の入力ボックス
    @IBOutlet weak var ageLabel: UILabel!       // DBからリアルタイムに参照された年齢ラベル
    @IBOutlet weak var deleteButton: UIButton!  // ユーザーの削除ボタン

    var user: DatabaseReference!    // 参照先DB（Userノード）※UserIdの親ノード
    var userId: DatabaseReference!  // 参照先DB（指定したUserIdノード）
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.user = Database.database().reference().child("user")
    }

    // 「接続」ボタンが押されたら呼ばれる
    @IBAction func userConnect(_ sender: AnyObject) {
        // ターゲットのユーザーIDから参照先DBを取得する
        self.userId = self.user.child(self.targetIdText.text!)
        let name: DatabaseReference = self.userId.child("name")
        let age: DatabaseReference = self.userId.child("age")
        
        // リアルタイムに更新するDBのノードと入力ボックス紐付ける
        name.observe(.value) { (snapshot: DataSnapshot) in
            if !snapshot.exists() { // ノードに値がなければ追加する
                name.setValue("unknown")
            }
            self.nameText.text = (snapshot.value! as AnyObject).description
            self.nameLabel.text = self.nameText.text
        }
        age.observe(.value) { (snapshot: DataSnapshot) in
            if !snapshot.exists() { // ノードに値がなければ追加する
                age.setValue("0")
            }
            self.ageText.text = (snapshot.value! as AnyObject).description
            self.ageLabel.text = self.ageText.text
        }
        self.userIdLabel.text = self.targetIdText.text // 取得したユーザーIDをラベルに表示する
        
        // 入力ボックスと接続状態ラベルを接続状態にする
        self.stateLabel.text = "########## 接続中 ##########"
        self.nameText.isEnabled = true
        self.ageText.isEnabled = true
        self.deleteButton.isEnabled = true
    }
    
    // 「削除」ボタンが押されたら呼ばれる
    @IBAction func userDelete(_ sender: AnyObject) {
        // 入力ボックスとラベル表示を未接続状態に戻す
        self.userIdLabel.text = "---"
        self.nameText.text = ""
        self.nameLabel.text = "---"
        self.ageText.text = ""
        self.ageLabel.text = "---"
        self.stateLabel.text = "########## 未接続 ##########"
        self.nameText.isEnabled = false
        self.ageText.isEnabled = false
        self.deleteButton.isEnabled = false
        
        // リアルタイムに更新されていたDBのノードと入力ボックス紐付けを解除する
        let name: DatabaseReference = self.userId.child("name")
        let age: DatabaseReference = self.userId.child("age")
        name.removeAllObservers()
        age.removeAllObservers()
        self.userId.removeValue() // ここで対象のUserを削除する
    }
    
    // DBへリアルタイムに更新する名前の入力ボックスの内容が変更される度に呼ばれる
    @IBAction func nameChanged(_ sender: AnyObject) {
        let data = ["name": self.nameText.text!]
        self.userId.updateChildValues(data)
    }
    
    // DBへリアルタイムに更新する年齢の入力ボックスの内容が変更される度に呼ばれる
    @IBAction func ageChanged(_ sender: AnyObject) {
        let data = ["age": self.ageText.text!]
        self.userId.updateChildValues(data)
    }


}

