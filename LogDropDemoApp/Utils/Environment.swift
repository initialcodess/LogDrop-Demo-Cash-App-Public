//
//  Environment.swift
//  LogDropDemoApp
//
//  Created by  Initial Code Software Solutions on 2.02.2026.
//


struct Environment {
    enum EnvironmentType {
        case development
        case production
    }

    static let current: EnvironmentType = {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }()

    struct API {
        static var baseURL: String {
            switch Environment.current {
            case .development:
                return "https://cashapp-demo.logdrop.io"
            case .production:
                return "https://cashapp-demo.logdrop.io"
            }
        }
    }
}
