//
//  DummyData.swift
//  LogDropDemoApp
//
//  Copyright (c) 2025 LogDrop.
//  @author Initial Code Software Solutions
//

import Foundation

struct DummyData {
    static let pinCode = "1234"
    
    static let failedApiResponse = """
    --- REQUEST ---------------------------------
    POST https://api.logdrop.dev/v1/account/manage
    Headers:
        Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
        Content-Type: application/json
        X-Request-Id: 123e4567-e89b-12d3-a456-426614174000
        Device-OS: iOS 18.1
        App-Version: 1.0.0 (100)

    Body:
    {
        "accountId": "acc_2025_001",
        "action": "updateLimits",
        "limits": {
            "daily": 5000,
            "monthly": 20000
        }
    }

    --- RESPONSE --------------------------------
    Status: 500 Internal Server Error
    Timestamp: 2025-08-16T12:34:56Z
    Trace-Id: srv-abc-123-xyz
    Response Headers:
        Content-Type: application/json; charset=utf-8
        Server: nginx/1.21.6
        Connection: close
        Content-Length: 214

    Body:
    {
        "status": 500,
        "error": "Internal Server Error",
        "message": "Something went wrong while processing your request.",
        "details": {
            "traceId": "srv-abc-123-xyz",
            "timestamp": "2025-08-16T12:34:56Z",
            "hint": "NullPointerException at AccountService.updateLimits()"
        }
    }
    ---------------------------------------------
    """

}

