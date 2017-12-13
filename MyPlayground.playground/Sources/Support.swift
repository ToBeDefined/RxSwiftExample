import Foundation
import UIKit

public func example(description: String, action: () -> ()) {
    printExampleHeader(description)
    action()
}

public func exampleMainQueue(description: String, action: @escaping () -> ()) {
    DispatchQueue.main.async { [description, action] in
        printExampleHeader(description)
        action()
    }
}

public func exampleAfterDelay(description: String, delay: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [description, closure] in
        printExampleHeader(description)
        closure()
    }
}

public func printExampleHeader(_ description: String) {
    print("\n--- \(description) ---")
}
