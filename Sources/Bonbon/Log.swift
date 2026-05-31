@_exported import struct os.Logger
import Foundation


// MARK: - print override

@available(*, deprecated, message: "Use log.[notice|debug|trace|info|error|warning|fault|critical] instead.")
internal func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    Swift.print(items, separator: separator, terminator: terminator)
}


// MARK: - Logger

let log: os.Logger = {
    var fullyQualifiedTypeName: String = ""
    debugPrint(Logger.self, to: &fullyQualifiedTypeName)
    let moduleName = fullyQualifiedTypeName.components(separatedBy: ".").first ?? "<Unknown module>"

    let subsystem = Bundle.main.bundleIdentifier ?? moduleName
    return os.Logger(subsystem: subsystem, category: moduleName)
}()
