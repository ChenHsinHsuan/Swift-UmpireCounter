//
//  MainViewController.swift
//  UmpireCounter
//
//  Created by Chen Hsin Hsuan on 2015/4/24.
//  Copyright (c) 2015年 aircon. All rights reserved.
//

import UIKit
import AVFoundation



class MainViewController: UIViewController {

    var audioPlayer = AVAudioPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var playballSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("playball", ofType: "mp3")!)
        audioPlayer = AVAudioPlayer(contentsOfURL: playballSound, error: nil)
        audioPlayer.prepareToPlay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        audioPlayer.play()
        vibrate()
    }

    
    //MARK:震動
    func vibrate(){
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

}
