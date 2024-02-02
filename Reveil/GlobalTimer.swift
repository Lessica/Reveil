//
//  GlobalTimer.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import Combine
import UIKit

protocol GlobalTimerObserver {
    var globalName: String { get }
    func eventOccurred(globalTimer timer: GlobalTimer) -> Void
}

final class GlobalTimer: ObservableObject {
    struct Observer {
        let value: any GlobalTimerObserver
        var registeredCount: Int
    }

    static let shared = GlobalTimer()
    private var observers = [ModuleName: Observer]()
    
    @Published var ticks: Int

    private var timer: Timer?

    private init() {
        ticks = 0
        setupTimer()
        registerNotifications()
    }

    deinit {
        unregisterNotifications()
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func applicationWillEnterForeground(_: Notification) {
        setupTimer()
    }

    @objc
    func applicationDidEnterBackground(_: Notification) {
        tearDownTimer()
    }

    func setupTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] _ in
            if observers.isEmpty {
                return
            }
            ticks += 1
            observers.forEach { [unowned self] (key: ModuleName, observer: Observer) in
                observer.value.eventOccurred(globalTimer: self)
            }
        }
        timer?.fire()
    }

    func tearDownTimer() {
        timer?.invalidate()
        timer = nil
    }

    func addObserver<T>(_ observer: T) where T: GlobalTimerObserver {
        let globalName = observer.globalName
        if observers[globalName] != nil {
            observers[globalName]?.registeredCount += 1
            return
        }
        observers[globalName] = Observer(value: observer, registeredCount: 1)
    }
    
    func removeObserver<T>(_ observer: T) where T: GlobalTimerObserver {
        let globalName = observer.globalName
        guard observers[globalName] != nil else {
            return
        }
        observers[globalName]?.registeredCount -= 1
        if observers[globalName]?.registeredCount == 0 {
            observers.removeValue(forKey: globalName)
        }
    }
}
