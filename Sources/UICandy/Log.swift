import os.log
import Foundation


// MARK: - print override

@available(*, deprecated, message: "Use log.info/debug/error/fault instead.")
internal func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let message = Logger.makeMessage(items, separator: separator, terminator: terminator)
    Swift.print(message)
}


// MARK: - Logger

let log = Logger()


struct Logger {

    // MARK: Properties

    private static let osLog = {
        var fullyQualifiedTypeName: String = ""
        debugPrint(Logger.self, to: &fullyQualifiedTypeName)
        let moduleName = fullyQualifiedTypeName.components(separatedBy: ".").first ?? "<Unknown module>"

        let subsystem = Bundle.main.bundleIdentifier ?? moduleName
        return OSLog(subsystem: subsystem, category: moduleName)
    }()

    
    // MARK: Message creation

    static func makeMessage(_ items: [Any], separator: String, terminator: String) -> String {
        items
            .map { "\($0)" }
            .joined(separator: separator)
        + terminator
    }


    // MARK: Logging

    func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(type: .info, items, separator: separator, terminator: terminator)
    }

    func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(type: .debug, items, separator: separator, terminator: terminator)
    }

    func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(type: .error, items, separator: separator, terminator: terminator)
    }

    func fault(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(type: .fault, items, separator: separator, terminator: terminator)
    }

    private func log(type: OSLogType, _ items: [Any], separator: String = " ", terminator: String = "\n") {
        let message = Logger.makeMessage(items, separator: separator, terminator: terminator)
        os_log(type, log: Logger.osLog, "%@", message)
    }
}
