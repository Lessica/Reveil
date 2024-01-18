//
//  GlobalTimer.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import Combine
import Foundation

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

    lazy var timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] _ in
        if observers.isEmpty {
            return
        }
        ticks += 1
        observers.forEach { [unowned self] (key: ModuleName, observer: Observer) in
            observer.value.eventOccurred(globalTimer: self)
        }
    }

    private init() {
        ticks = 0
        timer.fire()
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
