import SwiftUI
import UserNotifications

@main
struct MacPowerAlertApp: App {
    @StateObject private var backgroundService = BackgroundService()

    init() {
        // Richiesta autorizzazione notifiche
        requestNotificationAuthorization()

        // Inizia il servizio di background
        backgroundService.startMonitoring()
    }

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Autorizzazione alle notifiche ottenuta")
            } else if let error = error {
                print("Errore nell'ottenere l'autorizzazione alle notifiche:", error)
            } else {
                print("Autorizzazione alle notifiche non ottenuta")
            }
        }
    }

    var body: some Scene {
        // Non includere alcuna finestra principale
        Settings {
            EmptyView()
        }
    }
}
