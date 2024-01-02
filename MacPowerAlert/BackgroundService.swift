import Foundation
import UserNotifications
import IOKit.ps

class BackgroundService: ObservableObject {
    static let shared = BackgroundService()
    
    private var lowBatteryNotificationCount = 0
       private var highBatteryNotificationCount = 0

    internal init() {
        startMonitoring()
    }

    func startMonitoring() {
        let timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(checkBatteryLevel), userInfo: nil, repeats: true)
        timer.fire()
    }

    @objc func checkBatteryLevel() {
           let currentLevel = getCurrentBatteryLevel()
           let isCharging = isCharging()

           if currentLevel <= 20 && !isCharging {
               if lowBatteryNotificationCount < 3 {
                   showNotification(message: "È il momento di mettere in carica il Mac, la percentuale della tua batteria è al \(currentLevel)%")
                   lowBatteryNotificationCount += 1
               }
           } else {
               lowBatteryNotificationCount = 0  // Resetta il conteggio quando rientra nel range
           }

           if currentLevel >= 80 && isCharging {
               if highBatteryNotificationCount < 3 {
                   showNotification(message: "Scollega il Mac, la batteria è al \(currentLevel)%")
                   highBatteryNotificationCount += 1
               }
           } else {
               highBatteryNotificationCount = 0  // Resetta il conteggio quando rientra nel range
           }
       }


    func getCurrentBatteryLevel() -> Int {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array

        if let sourceData = IOPSGetPowerSourceDescription(snapshot, sources[0]).takeUnretainedValue() as? [String: AnyObject],
           let currentCapacity = sourceData[kIOPSCurrentCapacityKey] as? Int {
            return currentCapacity
        }

        return 0
    }

    func isCharging() -> Bool {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array

        for source in sources {
            if let sourceData = IOPSGetPowerSourceDescription(snapshot, source).takeUnretainedValue() as? [String: AnyObject] {
                if let isPresent = sourceData[kIOPSIsPresentKey] as? Bool,
                    let state = sourceData[kIOPSPowerSourceStateKey] as? String,
                    isPresent {
                    let isCharging = state == "AC Power"
                    return isCharging
                }
            }
        }

        return false
    }


    func showNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "MacPowerAlert"
        content.body = message
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: "BatteryNotification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

}
