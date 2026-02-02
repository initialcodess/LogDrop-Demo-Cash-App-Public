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
                return "http://5.75.130.193:3005"
                //return "http://localhost:3000"
            case .production:
                return "http://5.75.130.193:3005"
            }
        }
    }
}
