//
//  ViewController.swift
//  taskApp2
//
//  Created by HEIBEI KATO on 2017/02/08.
//  Copyright © 2017年 DT.Products. All rights reserved.
//

import UIKit

// A)Realm
import RealmSwift

import UserNotifications    // 追加

//１）tableViewのデリゲート追加
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txt_SelectCategory: UITextField!
    @IBOutlet weak var btn_ChoiceCategory: UIButton!
    
    var txt_string:String!
    
////////////////////////////////////////////////////////////////////B）Realmの設定
    // Realmインスタンスを取得する
    let realm = try! Realm()  // ←追加

    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    let taskArray = try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)   // ←追加
    let ChoiseTask = try! Realm().objects(Task.self).filter(txt_string).sorted(byProperty: "date", ascending: false)
    
////////////////////////////////////////////////////////////////////B）Realmの設定
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //２）tableViewのデリゲート設定
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }
    
    // segue で画面遷移するに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
////////////////////////////////////////////////////////////////////３）tableViewの必須設定
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // [UITableViewDelegateプロトコルのメソッドで、セルが削除可能なことを伝える]
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Cellに値を設定する.
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // [UITableViewDelegateプロトコルのメソッドで、セルをタップした時にタスク入力画面に遷移させる]
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // [UITableViewDelegateプロトコルのメソッドで、Deleteボタンが押されたときにローカル通知をキャンセルし、データベースからタスクを削除する]
    // taskappでは削除を可能にするため、UITableViewCellEditingStyle.Deleteを返します。
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
////////////////////////////////////////////////////////////////////tableViewの必須設定

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ChoiceCategory(_ sender: Any) {
        
        txt_string=txt_SelectCategory.text
        
    }

}

