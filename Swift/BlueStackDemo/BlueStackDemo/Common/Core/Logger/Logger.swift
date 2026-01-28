import Foundation
import os.log

class Logger {
    
    static var application: String = Bundle.main.bundleIdentifier ?? "App"
    static var versionString: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    
    @available(iOS 14.0, *)
    private static var osLogger: os.Logger = {
        let subsystem = Bundle.main.bundleIdentifier ?? "com.app.logger"
        return os.Logger(subsystem: subsystem, category: "default")
    }()
    
    static func debug(_ message: String) {
        Self.log(level: .debug, message: message)
    }
    
    static func info(_ message: String) {
        Self.log(level: .info, message: message)
    }
    
    static func warning(_ message: String) {
        Self.log(level: .warning, message: message)
    }
    
    static func error(_ message: String) {
        Self.log(level: .error, message: message)
    }
    
    private static func log(level: LogLevel,
                            message: String) {
        
        var formattedVersion = versionString
        if !versionString.isEmpty {
            formattedVersion = " - \(versionString)"
        }
        
        if #available(iOS 14.0, *) {
            osLogger.log(
                level: level.osLogType,
                "\(level.prefix)[\(application)\(formattedVersion)] - \(level.description, privacy: .public): \(message, privacy: .public)"
            )
        } else {
            NSLog("%@", "\(level.prefix)[\(application)\(formattedVersion)] - \(level.description): \(message)")
        }
    }
}
