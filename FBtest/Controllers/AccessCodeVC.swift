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

var accessCodeToApply = "" ;

class AccessCodeVC: UIViewController {

    var dbConnect:DatabaseReference!
    
    private static var questions:JSON!
    
    @IBOutlet weak var accessCodeLabel: UILabel!
    
    @IBOutlet weak var screenLabel: UILabel!
    
   
    let URL = "https://opentdb.com/api.php?amount=5&difficulty=easy&type=multiple"
    
    let url = "https://opentdb.com/api.php?amount=5&difficulty=easy&type=multiple"
    
    
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
                       var json = try JSON(data: dataFromServer)
                       //let json = try JSONSerialization.jsonObject(with: dataFromServer) as! [String:Any]
                        
                        var results:Array<JSON> = json["results"].arrayValue
                        var new_results = [Any]();
                        
                        for i in 0..<results.count{
                        
                            print("=====ITEM START====")
                            
                            var new_item = [NSString:Any]();
                            var correct_option:NSString!
                            
                            var item = results[i]
                            var option = item["correct_answer"]
                            var option_string = item["correct_answer"].string as! NSString;
                            var list: Array<JSON> = item["incorrect_answers"].arrayValue
                            list.append(option)
                            print( list )
                            
                            var shuffled = [NSString]();
                            
                            for i in 0..<list.count
                            {
                                let rand = Int(arc4random_uniform(UInt32(list.count)))
                                
                                var list_item = list[rand].string as! NSString;
                                shuffled.append( list_item )
                                
                                list.remove(at: rand)
                            }
                            
                            var new_lsit = [NSString:NSString]();
                            for i in 0..<shuffled.count
                            {
                                var list_item = shuffled[i];
                                if( i == 0 ){
                                    if( option_string == list_item ){
                                        correct_option = "A" ;
                                    }
                                    new_lsit["A"] = list_item;
                                }else if( i == 1 ){
                                    if( option_string == list_item ){
                                        correct_option = "B" ;
                                    }
                                    new_lsit["B"] = list_item;
                                }else if( i == 2 ){
                                    if( option_string == list_item ){
                                        correct_option = "C" ;
                                    }
                                    new_lsit["C"] = list_item;
                                }else if( i == 3 ){
                                    if( option_string == list_item ){
                                        correct_option = "D" ;
                                    }
                                    new_lsit["D"] = list_item;
                                }
                            }
                            
                        
                            new_item["category"] = item["correct_answer"].string as! NSString;
                            new_item["type"] = item["type"].string as! NSString;
                            new_item["difficulty"] = item["difficulty"].string as! NSString;
                            new_item["question"] = item["question"].string as! NSString;
                            new_item["correct_answer"] = item["correct_answer"].string as! NSString;
                            new_item["options"] = new_lsit;
                            new_item["correct_option"] = correct_option;
                            
                            print(new_lsit)
                            
                            print("======ITEM END======")
                            
                            new_results.append( new_item )
                        }
                        
                        print(new_results)
                        
                        
                        
                        let accessCode = arc4random()
                        let screen = accessCode % 5
                        
                        print("Screen : ", screen)
                        print("Access Code : ",accessCode)
                        
                       // print("Results : ",AccessCodeVC.questions)
                        
                        self.screenLabel.text = String(screen)
                        self.accessCodeLabel.text = String(accessCode)
                        
                        
                        let data = ["Screen": screen,"Access Code": accessCode,"Questions":new_results,"hasGameStarted":false] as [String : Any]
                        
                       // print("Data : \(data)")
                        self.dbConnect.child("Quiz").child("quizId").child(String(accessCode)).setValue(data)
                        questions_from_api = new_results;
                        accessCodeToApply = String(accessCode) ;
                        
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
