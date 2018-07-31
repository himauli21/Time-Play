//
//  QuestionViewController.swift
//  FBtest
//
//  Created by Jaimin  on 30/07/18.
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
    
    var dbConnect:DatabaseReference!
    var datbaseHandle:DatabaseHandle!
    var questionsList = [ DataSnapshot ]()
   
    
    var dataSnapShot:DataSnapshot!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        print(" Question View Controller ");
       
        limit = UInt(20)
        startTimer()
        queryFirebase( limit )
        
    }
    
    func queryFirebase(_ item: UInt  ){
        
    
        
        dbConnect = Database.database().reference()
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
            alert.addAction(UIAlertAction(title: "We are processign scores.", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            }
           
            
        }
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
