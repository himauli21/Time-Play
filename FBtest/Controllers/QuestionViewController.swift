//
//  QuestionViewController.swift
//  FBtest
//
//  Created by Himauli Patel on 30/07/18.
//  Copyright © 2018 robin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class QuestionViewController: UIViewController {
    
    @IBOutlet weak var labelTimer: UILabel!
    
    @IBOutlet weak var labelQ: UILabel!
    
    @IBOutlet weak var labelO1: UILabel!
    @IBOutlet weak var labelO2: UILabel!
    @IBOutlet weak var labelO3: UILabel!
    @IBOutlet weak var labelO4: UILabel!
    
    var label = ""
    var message = "in "
    var countdownTimer: Timer!
    var totalTime = 10
    var timeTaken = ""
    var limit:UInt!
    var optionSelected = [Any]()
    var usersJoined = [Any]()
    var users: NSDictionary = [:]
    var scoreArray: NSMutableDictionary = [:]
    
    
    var dbConnect:DatabaseReference!
    var datbaseHandle:DatabaseHandle!
    var questionsList = [ DataSnapshot ]()
   
    
    var dataSnapShot:DataSnapshot!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dbConnect = Database.database().reference()
        self.dbConnect.child("Quiz").child("quizId").child( accessCodeToApply ).child("hasGameStarted").setValue( true )
        //sleep(1)
        
        print(" Question View Controller ");
       
        limit = UInt(5)
        startTimer()
        queryFirebase( limit )
        
    }
    
    func queryFirebase(_ item: UInt  ){
        
        datbaseHandle = dbConnect?.child("Quiz").child("quizId").child( accessCodeToApply ).child("Questions")
            .queryLimited(toFirst: item)
            .observe(.childAdded, with: { (snapshot) in
            
            print( snapshot )
            self.questionsList.append(snapshot)
            self.dataSnapShot = snapshot
            self.showQuestion()
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showQuestion(  ){
       
        var question = dataSnapShot.childSnapshot(forPath: "question").value as! String
        var options = dataSnapShot.childSnapshot(forPath: "options").value as! [NSString:NSString]
        
        question = question.replacingOccurrences(of : "&quot;", with : "'")
        labelQ.text = question
        
        print("=== Question ====")
        print(question)
        
        
        for option in options {
            
            var text = option.value as! String
            text = (option.key as! String)+": "+text
            text = text.replacingOccurrences(of : "&quot;", with : "'")
            if( option.key == "A" ){
                labelO1.text = text
            }else if( option.key == "B" ){
                labelO2.text = text
            }else if( option.key == "C" ){
                labelO3.text = text
            }else if( option.key == "D" ){
                labelO4.text = text
            }
           
        }
        
        totalTime = 10
    }
    

    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTime() {
        let t = "\(timeFormatted(totalTime))"
        labelTimer.text = t
        
         print( "===FUNCTION===" )
        print( t )
        
        if (totalTime > 0) {
            self.totalTime -= 1
            print(totalTime)
            
            print( "===IF===" )
            print( t )
            print( "===totalTime===" )
            print( totalTime )
            
        }
        else {
            
            
           limit = limit-1;
           
           if( limit > 0 ){
                queryFirebase(limit)
                
                print( "===ELSE===" )
                print( t )
                print( "===totalTime===" )
                print( totalTime )
                
                totalTime = 10
           }else{
             print( "===EXIT===" )
            countdownTimer.invalidate()
            
            // Game over alert
            let alert = UIAlertController(title: "Game Over", message: "Time out", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "We are processing scores.", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.calculateScore()
            }
           
            
        }
    }
    
    
    func calculateScore()  {
        datbaseHandle = dbConnect?.child("Quiz").child("quizId").child( accessCodeToApply ).child("Questions")
            .observe(.value, with: { (snapshot) in
                
                print("++++++++")
//                print( snapshot )
                for snap in snapshot.children {
                    //print("snap = \(snap)")
                   
                    let response = snap as! DataSnapshot
                    let val1 = response.childSnapshot(forPath: "correct_option").value as! NSString
                    //print("val1 = \(val1)")
                  
                    
                    self.optionSelected.append(val1)
                    
                    self.users = response.childSnapshot(forPath: "Users").value as! NSDictionary
                    self.usersJoined.append(self.users)
                  
                    
                    
                    for (UserName, User) in self.users
                    {
                        let User1 = User as! NSDictionary
                        let option = User1["option_choosen"] as! NSString
                        let time_taken_in_second = User1["time_taken_in_second"] as! Int
                        print(UserName)
                        print("Option Choosen : \(option)")
                        
                    
                        
                        let keyExists = self.scoreArray[UserName] != nil
                        
                        if( option == val1)
                        {
                            var correct_answer = 0 as! Int;
                            var time_taken = 0 as! Int;
                            var score = 0 as! Int ;
                            
                            // get option, time and score from SCORE ARRAY
                            if( keyExists ){
                                var socre_previous = self.scoreArray[UserName] as! NSDictionary
                                
                                var correct_answers_exist = socre_previous["correct_answers"] != nil
                                var time_taken_exist = socre_previous["time_taken"] != nil
                                var score_exist = socre_previous["score"] != nil
                                
                                if( correct_answers_exist ){
                                    correct_answer = socre_previous["correct_answers"] as! Int;
                                }
                                
                                if( time_taken_exist ){
                                    time_taken = socre_previous["time_taken"] as! Int;
                                }
                            
                                if( score_exist ){
                                    score = socre_previous["score_exist"] as! Int;
                                }
                            }
                            
                            correct_answer = correct_answer+1;
                            time_taken = time_taken+time_taken_in_second
                            score = score+( 10-time_taken_in_second )
                            
                            let correct_answer_cast = correct_answer as! NSString
                            let time_taken_cast = time_taken as! NSString
                            let score_cast = score as! NSString
                            
                            
                            var scoreInternal = [NSString:NSString]();
                            scoreInternal["correct_answers"] = correct_answer_cast ;
                            scoreInternal["time_taken"] = time_taken_cast ;
                            scoreInternal["score_exist"] = score_cast ;
                            
                        
                            self.scoreArray.setValue( scoreInternal, forKey: UserName as! String )
                           
                         }
                       
                    }
                    
    
                }
                
                // get the array of correct_option
                print("Correct Options : \(self.optionSelected)")
                
                // users
                print("Users : \(self.usersJoined)")
                
                // scores
                print("Users : \(self.scoreArray)")
         
            })
    }
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60)
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func countDownString() -> String {
        
        print("\(totalTime) seconds")
        return "\(totalTime) seconds"
    }
    
    
    
    
}
