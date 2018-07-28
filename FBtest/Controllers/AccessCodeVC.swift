//
//  AccessCodeVC.swift
//  FBtest
//
//  Created by Himauli Patel on 2018-07-27.
//  Copyright © 2018 robin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Alamofire            // 1. Import AlamoFire and SwiftyJson
import SwiftyJSON

class AccessCodeVC: UIViewController {

    var dbConnect:DatabaseReference!
    
    private static var questions:JSON!
    
    @IBOutlet weak var accessCodeLabel: UILabel!
    
    @IBOutlet weak var screenLabel: UILabel!
    
    let URL = "https://opentdb.com/api.php?amount=20&difficulty=easy&type=multiple"
    
    let url = "https://opentdb.com/api.php?amount=20&difficulty=easy&type=multiple"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.dbConnect = Database.database().reference()
        
        getQuestions(url: URL)
      
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getQuestions(url:String) {
        // Build the URL:
       
        print(url)
        
        
        
        Alamofire.request(url, method: .get, parameters: nil).responseJSON {
            
            (response) in
            
            if response.result.isSuccess {
                if let dataFromServer = response.data {
                    
                    
                    do {
                       // let json = try JSON(data: dataFromServer)
                        let json = try JSONSerialization.jsonObject(with: dataFromServer) as! [String:Any]
                        
                        // TODO: Parse the json response
                        print("============")
                       print(json)
                       // AccessCodeVC.questions = json
                        //print(json)
                        
                      //  let results = json["results"].dictionaryValue
                        //print(results)
                        
                       //let aObject = json["results"] as! [String : AnyObject]
                        //print(aObject)
                        
                        
//                        if let data = json.data(using: .utf8) {
//                            if let json = try? JSON(data: data) {
//                                for item in json["results"].arrayValue {
//                                    print(item["firstName"].stringValue)
//                                }
//                            }
//                        }
                        
                        
                        let accessCode = arc4random()
                        let screen = accessCode % 5
                        
                        print("Screen : ", screen)
                        print("Access Code : ",accessCode)
                        
                       // print("Results : ",AccessCodeVC.questions)
                        
                        self.screenLabel.text = String(screen)
                        self.accessCodeLabel.text = String(accessCode)
                        
                        let data = ["Screen": screen,"Access Code": accessCode,"Questions":json] as [String : Any]
                        self.dbConnect.child("Quiz").child("quizId").child(String(accessCode)).setValue(data)
              
                    }
                    catch {
                        print("error")
                    }
                    
                }
                else {
                    print("Error when getting JSON from the response")
                }
            }
            else {
                // 6. You got an error while trying to connect to the API
                print("Error while fetching data from URL")
            }
            
        }
    }

}
