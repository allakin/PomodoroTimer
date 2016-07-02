//
//  Pomodoro.swift
//  PomodoroTimer
//
//  Created by Megabits on 15/9/16.
//  Copyright (c) 2015年 ScrewBox. All rights reserved.
//

import Foundation

class pomodoro : NSObject{
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var pomoMode = 0
    var pomoTime = 1500 { didSet { //预设番茄钟时间
        setDefaults ("pomo.pomoTime",value: pomoTime)
        updateDisplay()
        } }
    var breakTime = 300 { didSet { //预设休息时间
        setDefaults ("pomo.breakTime",value: breakTime)
        updateDisplay()
        } }
    var longBreakTime = 1500 { didSet { //预设长休息时间
        setDefaults ("pomo.longBreakTime",value: longBreakTime)
        updateDisplay()
        } }
    
    var nowTime = 0
    var localCount = 0
    
    var process:Float = 0
    var timerLabel = "00:00"
    
    var longBreakEnable = false { //是否开启连续计时
        didSet{
            setDefaults ("pomo.longBreakEnable",value: longBreakEnable)
            if !longBreakEnable {
                localCount = 0
            }
        }
    }
    
    var longBreakCount = 4 { didSet { setDefaults ("pomo.longBreakCount",value: longBreakCount) } } //几个循环后进入长休息
    
    private var timer: NSTimer?
    private var isDebug = false
    
    override init() {
        super.init()
        if getDefaults("pomo.pomoTime") != nil {  //存储设置
            pomoTime = getDefaults("pomo.pomoTime") as? Int ?? 1500
            breakTime = getDefaults("pomo.breakTime") as? Int ?? 300
            longBreakTime = getDefaults("pomo.longBreakTime") as? Int ?? 1500
            longBreakCount = getDefaults("pomo.longBreakCount") as? Int ?? 4
            longBreakEnable = getDefaults("pomo.longBreakEnable") as? Bool ?? false
        } else {
            setDefaults ("pomo.pomoTime",value: pomoTime)
            setDefaults ("pomo.breakTime",value: breakTime)
            setDefaults ("pomo.longBreakTime",value: longBreakTime)
            setDefaults ("pomo.longBreakCount",value: longBreakCount)
            setDefaults ("pomo.longBreakEnable",value: longBreakEnable)
        }
        
        updateDisplay()
        
//        isDebug = true //调试模式
    }
    
    func updateTimer(timer:NSTimer) { //确定计时状态和调整时间
        if nowTime <= 0{
            stopTimer()
            if pomoMode == 1 {
                if longBreakEnable {
                    if localCount == longBreakCount - 1 {
                        pomoMode = 3
                        nowTime = longBreakTime
                        longBreakStart()
                    } else {
                        pomoMode += 1
                        nowTime = breakTime
                        breakStart()
                    }
                } else {
                    pomoMode += 1
                    nowTime = breakTime
                    breakStart()
                }
            } else if pomoMode == 2 {
                if longBreakEnable {
                    localCount += 1
                    pomoMode = 0
                    start()
                } else {
                    pomoMode = 0
                }
            } else if pomoMode == 3 {
                pomoMode = 0
                localCount = 0
                start()
            }
        } else {
            if isDebug {
                nowTime -= 100
            } else {
                nowTime -= 1
            }
        }
        updateDisplay()
    }
    
    private func updateDisplay() {
        //生成百分比形式的进度
        switch pomoMode {
        case 1:
            process = Float(nowTime) / Float(pomoTime) * 100
        case 2:
            process = Float(nowTime) / Float(breakTime) * 100
        case 3:
            process = Float(nowTime) / Float(longBreakTime) * 100
        default:
            process = 0
        }
        //生成当前时间的文本表示
        var nowUse = 0
        if pomoMode == 0 {
            nowUse = pomoTime
        } else {
            nowUse = nowTime
        }
        var minute = "\((nowUse - (nowUse % 60)) / 60)"
        var second = "\(nowUse % 60)"
        if nowUse % 60 < 10 {
            second = "0" + second
        }
        if (nowUse - (nowUse % 60)) / 60 < 10 {
            minute = "0" + minute
        }
        if Int(minute) > 60 {
            var hour = "\((Int(minute)! - (Int(minute)! % 60)) / 60)"
            minute = "\(Int(minute)! % 60)"
            if Int(hour) < 10 {
                hour = "0" + hour
            }
            if Int(minute) < 10 {
                minute = "0" + minute
            }
            
            timerLabel = hour + ":" + minute
        } else {
            timerLabel = minute + ":" + second
        }
    }
    
    func getStringOfTime(select:Int) -> (Int,String,String,String) { //输出想要获得的时间的文本表示
        var resultCount = 0
        var nowUse = 0
        var timerLabelMin = "0"
        var timerLabelSec = "0"
        var timerLabelHour = "0"
        switch select {
        case 0:nowUse = pomoTime
        case 1:nowUse = breakTime
        case 2:nowUse = longBreakTime
        default:nowUse = pomoTime
        }
        var minute = "\((nowUse - (nowUse % 60)) / 60)"
        let second = "\(nowUse % 60)"
        timerLabelSec = second
        resultCount += 1
        timerLabelMin = minute
        if nowUse >= 60 {
            resultCount += 1
        }
        if Int(minute) > 60 {
            let hour = "\((Int(minute)! - (Int(minute)! % 60)) / 60)"
            minute = "\(Int(minute)! % 60)"
            timerLabelMin = minute
            timerLabelHour = hour
            resultCount += 1
            
        }
        return (resultCount,timerLabelHour,timerLabelMin,timerLabelSec)
    }
    
    func start() {
        if pomoMode == 0 {
            pomoMode = 1
            nowTime = pomoTime
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(pomodoro.updateTimer(_:)), userInfo: nil, repeats: true)
        }
    }
    
    private func breakStart() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(pomodoro.updateTimer(_:)), userInfo: nil, repeats: true)
    }
    
    private func longBreakStart() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(pomodoro.updateTimer(_:)), userInfo: nil, repeats: true)
    }
    
    func stop() {
        stopTimer()
        pomoMode = 0
        nowTime = 0
        localCount = 0
        updateDisplay()
    }
    
    private func getDefaults (key: String) -> AnyObject? {
        if key != "" {
            return defaults.objectForKey(key)
        } else {
            return nil
        }
    }
    
    private func setDefaults (key: String,value: AnyObject) {
        if key != "" {
            defaults.setObject(value,forKey: key)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        process = 0
    }
}