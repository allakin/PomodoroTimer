//
//  ViewController.swift
//  PomodoroTimer
//
//  Created by Megabits on 15/10/8.
//  Copyright © 2015年 ScrewBox. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var pomodoroClass = pomodoro()
    var timer: NSTimer?
    
    @IBAction func start(sender: AnyObject) {
        if pomodoroClass.pomoMode == 0 {
            timer?.invalidate()
            timer = nil
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.pomoing(_:)), userInfo: nil, repeats: true)
        }
        pomodoroClass.start()
        print("Pomodoro Started")
    }
    
    @IBAction func stop(sender: AnyObject) {
        print("Pomodoro Stoped")
        pomodoroClass.stop()
        timer?.invalidate()
        timer = nil
        process.progress = 0
        updateStatus()
    }
    
    @IBAction func continuousTime(sender: UISwitch) {
        if sender.on {
            pomodoroClass.longBreakEnable = true
        } else {
            pomodoroClass.longBreakEnable = false
        }
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var process: UIProgressView!
    
    func pomoing(timer:NSTimer) {  //调整进度条
        process.progress = pomodoroClass.process / 100
        timeLabel.text = pomodoroClass.timerLabel
        updateStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 个性化 Personalized
//        pomodoroClass.pomoTime = 1500
//        pomodoroClass.breakTime = 500
//        pomodoroClass.longBreakTime = 1500
//        pomodoroClass.longBreakCount = 4
        
        //调试模式（加速模式）Debug mode（fast mode）
//        pomodoroClass.isDebug = false
        
        timeLabel.text = pomodoroClass.timerLabel
    }
    
    func updateStatus() {
        switch pomodoroClass.pomoMode {
        case 0:
            statusLabel.text = "Done"
        case 1:
            statusLabel.text = "Working"
        case 2:
            statusLabel.text = "Break"
        case 3:
            statusLabel.text = "Long Break"
        default:break
        }
    }
}

