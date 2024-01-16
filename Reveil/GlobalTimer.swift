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

    lazy var timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] _ in
        if observers.isEmpty {
            return
        }
        observers.forEach { [unowned self] (_: ModuleName, observer: Observer) in
            observer.value.eventOccurred(globalTimer: self)
        }
    }

    private init() {
        timer.fire()
    }

    func addObserver(_ observer: some GlobalTimerObserver) {
        let globalName = observer.globalName
        if observers[globalName] != nil {
            observers[globalName]?.registeredCount += 1
            return
        }
        observers[globalName] = Observer(value: observer, registeredCount: 1)
    }

    func removeObserver(_ observer: some GlobalTimerObserver) {
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
