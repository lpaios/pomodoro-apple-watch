//
//  InterfaceController.swift
//  pomodoro WatchKit Extension
//
//  Created by MacBookPro on 28/11/16.
//  Copyright © 2016 MacBookPro. All rights reserved.
//

import WatchKit
import Foundation
//import PomodoroTimer


class PomodoroController: WKInterfaceController {
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var btnTimer: WKInterfaceLabel!
    @IBOutlet var groupCircle: WKInterfaceGroup!
    
    var pomodoro = PomodoroTimer()
    var background = PomodoroInterfaceGroup()
    
    //let pomodoroInSecondsTime = TimeInterval(25*60+1)
    var pomodoroInSecondsTime: TimeInterval = 15
    
    enum pomodoroStates: Double {
        case work = 25, restPause = 5, longRestPause = 15
    }
    struct configState  {
        var label = ""
        var color = UIColor(red:0.28, green:0.75, blue:0.98, alpha:1.0)
        var imageNameRoot = "circle-"
    }
    struct configStates {
        static let work = configState(label: "Start", color: UIColor(red:0.28, green:0.75, blue:0.98, alpha:1.0) , imageNameRoot: "circle-")
        static let rest = configState(label: "Rest", color: UIColor(red:0.67, green:1.00, blue:0.00, alpha:1.0), imageNameRoot: "circle-rest-")
        static let longRestPause = configState(label: "Long Rest", color: UIColor(red:0.67, green:1.00, blue:0.00, alpha:1.0), imageNameRoot: "circle-rest-")

        static let getConfigByPomodoroState = {(state: pomodoroStates) -> PomodoroController.configState in
            switch state {
            case pomodoroStates.work:
                return configStates.work
            case pomodoroStates.restPause:
                return configStates.rest
            case pomodoroStates.longRestPause:
                return configStates.longRestPause
            }
        }
    }
    var currentState: pomodoroStates = pomodoroStates.work
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        //groupCircle.setHeight(groupCircle.frame.size.width) //make it square, i don't know how to get the width
        // Configure interface objects here.
        pomodoro.setInterfaceTimer(timer: timer,seconds: pomodoroInSecondsTime, completionStopHandler: self.onTimerFinish)
        background.setGroup(group: groupCircle, totalFrames: 100, imageNameRoot: configStates.work.imageNameRoot)
        
        background.startFastAnimationWithCompletion {
            print ("end animation in startup")
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    @IBAction func onTimerButton() {
        if pomodoro.isPlay() {
            //Lets pause
            let elapsedTime = pomodoro.pause()
            print("elapsedTime \(elapsedTime)")
            btnTimer.setText("Resume")
            background.stopAnimating()
            background.setFramePercentage(p:(elapsedTime*100/pomodoroInSecondsTime))
        } else if(pomodoro.isPause()) {
            //Lets resume
            pomodoro.resume()
            btnTimer.setText("Pause")
            let elapsedTime = pomodoro.getElapsedTime()
            let percentageElapsedTime = elapsedTime*100/pomodoroInSecondsTime
            self.background.startAnimationPercentageProgress(frameFromPercent: percentageElapsedTime, frameToPercent: 100, duration: (pomodoroInSecondsTime - elapsedTime))
        }else{
            //is stop so lets play/start
            pomodoro.play(seconds: pomodoroInSecondsTime)
            btnTimer.setText("Pause")
            //Fast animation
            background.startFastAnimationWithCompletion {
                print ("end animation")
                self.background.startAnimationPercentageProgress(frameFromPercent: 0, frameToPercent: 100, duration: self.pomodoroInSecondsTime-1)
            }
        }
    }
    @IBAction func onMenuReset() {
        pomodoro.stop()
        changeState(futureState: pomodoroStates.work)
    }
    
    func changeState(futureState: pomodoroStates) {
        currentState = futureState
        pomodoroInSecondsTime = futureState.rawValue
        pomodoro.initTimer(seconds: futureState.rawValue)
        background.changeImageName(imageNameRoot: configStates.getConfigByPomodoroState(futureState).imageNameRoot)
        self.btnTimer.setText(configStates.getConfigByPomodoroState(futureState).label)
        self.btnTimer.setTextColor(configStates.getConfigByPomodoroState(futureState).color)
    }
    
    func onTimerFinish(){
        print("RING CONTROLER")
        if pomodoroStates.work == currentState {
            changeState(futureState: pomodoroStates.restPause)
            //TODO: Send it to backend. One pomodoro finished
        }else{
            changeState(futureState: pomodoroStates.work)
        }
    }

}
