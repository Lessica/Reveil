//
//  GlobalTimer.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import Combine
import Foundation

protocol GlobalTimerObserver {
    func globalTimerEventOccurred(_ timer: GlobalTimer) -> Void
}

final class GlobalTimer: ObservableObject {
    static let shared = GlobalTimer()
    private var observers = Set<AnyHashable>()

    lazy var timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] _ in
        self.observers.forEach { observer in
            (observer as? GlobalTimerObserver)?.globalTimerEventOccurred(self)
        }
    }

    private init() {
        timer.fire()
    }

    func addObserver<T>(_ observer: T) where T: GlobalTimerObserver, T: Hashable {
        observers.insert(AnyHashable(observer))
    }
    
    func removeObserver<T>(_ observer: T) where T: GlobalTimerObserver, T: Hashable {
        observers.remove(AnyHashable(observer))
    }
}
