//
//  CountViewController.swift
//  UmpireCounter
//
//  Created by Chen Hsin Hsuan on 2015/4/24.
//  Copyright (c) 2015年 aircon. All rights reserved.
//

import UIKit
import Spring
import GoogleMobileAds;
import AudioToolbox

let blackUIImage = UIImage(named: "black.png") //黃燈
let yelloUIImage = UIImage(named: "yellow.png") //黃燈
let greenUIImage = UIImage(named: "green.png")  //綠燈
let redUIImage = UIImage(named: "red.png")      //紅燈

let inning_UP = "U"    //上半局
let inning_DOWN = "D"  //下半局
var baseballInningLimit = 9 //棒球局數
var softballInningLimit = 7 //壘球局數

class CountViewController: UIViewController, UIActionSheetDelegate, GADBannerViewDelegate{

    @IBOutlet weak var yellow1: UIButton!
    @IBOutlet weak var yellow2: UIButton!
    @IBOutlet weak var green1: UIButton!
    @IBOutlet weak var green2: UIButton!
    @IBOutlet weak var green3: UIButton!
    @IBOutlet weak var out1: UIButton!
    @IBOutlet weak var out2: UIButton!
    @IBOutlet weak var scoreStepper: UIStepper!
    @IBOutlet weak var inningLabel: UILabel!
    @IBOutlet weak var ballTypeImageView: UIImageView!
    @IBOutlet weak var guestScoreLabel: SpringLabel!
    @IBOutlet weak var homeScoreLabel: SpringLabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var guestScore = 0
    var homeScore = 0
    var inningLimit = 9 //局數上限
    var inningType = "U"
    var inning = 1      //目前局數
    var ball = 0        //壞球數
    var strike = 0      //好球數
    var out = 0         //出局數
    var ballType = "B"  //B:棒球  S:壘球
    
    var changeInningActionSheet = UIActionSheet()
    var isGameOverActionSheet = UIActionSheet()
    var resetActionSheet = UIActionSheet()
    override func viewDidLoad() {
        super.viewDidLoad()

        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        let request = GADRequest()
        request.testDevices = ["ffd5b4c17425a518e4f9c99b1738ae16"]
        bannerView?.loadRequest(request)

        
        
        if(ballType == "B"){
            inningLimit = baseballInningLimit
        }else{
            inningLimit = softballInningLimit
        }
        
        if(inningType == inning_UP){
            inningLabel.text = "\(inning)局 ▲"
            guestLabelButtonPressed(UIButton())
        }else{
            inningLabel.text = "\(inning)局 ▼"
            homeLabelButtonPressed(UIButton())
        }
        out = 0
        initBallNumber()//球數初始化
        refreshLight() //重整燈號

    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func resetButtonPressed(sender: UIButton) {
        resetActionSheet = UIActionSheet(title: "設定", delegate: self, cancelButtonTitle: "繼續", destructiveButtonTitle: "重置", otherButtonTitles: "離開")
        resetActionSheet.showInView(view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (actionSheet == changeInningActionSheet){
            if (buttonIndex == 0) {
                changeInning()
            }else if (buttonIndex == 1) {
                //取消換局(全部歸零)
                out = 0;
                initBallNumber()    //初始化球數
                refreshLight()      //重整燈號
            }
        }else if(actionSheet == isGameOverActionSheet){
            if (buttonIndex == 0) {
                gameOver()          //比賽結束
            }else if (buttonIndex == 1) {
                //取消結束比賽(全部歸零)
                out = 0
                initBallNumber()    //初始化球數
                refreshLight()      //重整燈號
            }
            
        }else if(actionSheet == resetActionSheet){
            if (buttonIndex == 0) {
                //重置
                inning = 1
                inningType = inning_UP
                out = 0
                if(inningType == inning_UP){
                    inningLabel.text = "\(inning)局 ▲"
                }else{
                    inningLabel.text = "\(inning)局 ▼"
                }
                homeScore = 0
                guestScore = 0
                guestScoreLabel.text = "\(guestScore)"
                homeScoreLabel.text = "\(homeScore)"
                scoreStepper.value = Double(guestScore)
                initBallNumber()    //初始化球數
                refreshLight()      //重整燈號
            }else if (buttonIndex == 2) {
                gameOver()
            }
        }
    }
    
    
    // MARK:分數處理
    @IBAction func stepperPressed(sender: UIStepper) {
        vibrate()
        if guestScoreLabel.textColor == UIColor.yellowColor() {
            guestScore = String(format: "%.0f",sender.value).toInt() ?? 0
        }else{
            homeScore = String(format: "%.0f",sender.value).toInt() ?? 0
        }
        
        guestScoreLabel.text = "\(guestScore)"
        homeScoreLabel.text = "\(homeScore)"
        
    }
    
    // MARK:燈號處理
    @IBAction func strikeButtonPressed(sender: SpringButton) {
        vibrate()
        if(strike == 2){
            if(out == 2){
                if(inning >= inningLimit){
                    //最後一局
                    if(inningType == inning_UP){
                        if (homeScore > guestScore){
                            askIsGameOver() //詢問是否結束比賽
                        }else{
                            askWhetherChangeInning() //詢問是否換局
                        }
                    }else{
                        askIsGameOver() //詢問是否結束比賽
                    }
                }else{
                    askWhetherChangeInning() //詢問是否換局
                }
            }else{
                out++
            }
            initBallNumber()//球數重整
        }else{
            strike++
        }
        refreshLight()      //重整燈號
    }

    
    @IBAction func ballButtonPressed(sender: SpringButton) {
        vibrate()
        if(ball == 3){
            initBallNumber()//球數重整
        }else{
            ball++
        }
        refreshLight()      //重整燈號
    }
    
    
    
    @IBAction func outButtonPressed(sender: SpringButton) {
        vibrate()
        if(out == 2){
            
            if(inning >= inningLimit){
                //最後一局
                if(inningType == inning_UP){
                    if (homeScore > guestScore){
                        askIsGameOver() //詢問是否結束比賽
                    }else{
                        askWhetherChangeInning() //詢問是否換局
                    }
                }else{
                    askIsGameOver() //詢問是否結束比賽
                }
            }else{
                askWhetherChangeInning() //詢問是否換局
            }
        }else{
            out++
        }
        initBallNumber()    //球數重整
        refreshLight()      //重整燈號
    }

    @IBAction func HitsButtonPressed(sender: SpringButton) {
        vibrate()
        sender.animation = "pop"
        sender.duration = 1.0
        sender.animate()
        
        initBallNumber()    //球數重整
        refreshLight()      //重整燈號
    }
    
    //MARK: -
    //MARK: 自定義功能
    //MARK: -
    //MARK:棒球初始化
    func initOfBaseball(){
        strike = 0
        ball = 0
    }
    
    //MARK:壘球初始化
    func initOfSoftball(){
        strike = 1
        ball = 1
    }
    
    //MARK:球數重整
    func initBallNumber(){
        if (ballType == "B"){
            initOfBaseball()
        }else{
            initOfSoftball()
        }
    }
    

    //MARK: 變更球種
    @IBAction func changeBallType(sender: SpringButton) {
        sender.duration = 2.0
        sender.animation = "pop"
        sender.animate()
        if (ballType == "B"){
            sender.frame.origin.x += 45
            ballType = "S"
            inningLimit = softballInningLimit
        }else{
            sender.frame.origin.x -= 45
            ballType = "B"
            inningLimit = baseballInningLimit
        }
        initBallNumber()
        refreshLight()
    }

    @IBAction func guestLabelButtonPressed(sender: UIButton) {
        homeScoreLabel.textColor = UIColor.whiteColor()
        guestScoreLabel.textColor = UIColor.yellowColor()
        
        guestScoreLabel.animation = "swing"
        guestScoreLabel.animate()
        
        scoreStepper.value = Double(guestScore)
    }
    
    

    @IBAction func homeLabelButtonPressed(sender: UIButton) {
        guestScoreLabel.textColor = UIColor.whiteColor()
        homeScoreLabel.textColor = UIColor.yellowColor()

        homeScoreLabel.animation = "swing"
        homeScoreLabel.animate()
        
        scoreStepper.value = Double(homeScore)
    }
    
    //MARK: 重整燈號
    func refreshLight(){
        //        println("strike:\(strike), ball:\(ball), out:\(out)")
        switch (strike){
        case 0:
            yellow1.selected = false
            yellow2.selected = false
            
        case 1:
            yellow1.selected = true
            yellow2.selected = false
            
        case 2:
            yellow1.selected = true
            yellow2.selected = true
            
        default:
            yellow1.selected = false
            yellow2.selected = false
            
        }
        
        switch (ball){
        case 0:
            green1.selected = false
            green2.selected = false
            green3.selected = false
        case 1:
            green1.selected = true
            green2.selected = false
            green3.selected = false
            
        case 2:
            green1.selected = true
            green2.selected = true
            green3.selected = false
            
        case 3:
            green1.selected = true
            green2.selected = true
            green3.selected = true
            
        default:
            green1.selected = false
            green2.selected = false
            green3.selected = false
            
        }
        
        switch (out){
        case 0:
            out1.selected = false
            out2.selected = false
        case 1:
            out1.selected = true
            out2.selected = false
            
        case 2:
            out1.selected = true
            out2.selected = true
        default:
            out1.selected = false
            out2.selected = false
        }
    
    }
    
    //MARK: 詢問是否換局
    func askWhetherChangeInning(){
        changeInningActionSheet = UIActionSheet(title: "3人出局", delegate: self, cancelButtonTitle: "不換局", destructiveButtonTitle: "換局")
        changeInningActionSheet.showInView(view)
    }
    
    //MARK:詢問是否結束比賽
    func askIsGameOver(){
        isGameOverActionSheet = UIActionSheet(title: "比賽結束", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: "結束")
        isGameOverActionSheet.showInView(view)
    }
    
    //MARK: 換局
    func changeInning(){
        
        if(inningType == inning_UP){
            inningType = inning_DOWN
            inningLabel.text = "\(inning)局 ▼"
            homeLabelButtonPressed(UIButton())
        }else{
            inningType = inning_UP
            inningLabel.text = "\(++inning)局 ▲"
            guestLabelButtonPressed(UIButton())
        }

        out = 0
        initBallNumber()    //初始化球數
        refreshLight()      //重整燈號
        
    }
    
    
    
    //MARK:比賽結束
    func gameOver(){
        self.dismissViewControllerAnimated(true, completion: {
            self.view.removeFromSuperview()
        })
    }
    

    //MARK:震動
    func vibrate(){
         AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

}
