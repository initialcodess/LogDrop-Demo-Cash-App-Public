import LogDropSDK

final class NotificationService: LogDropNotificationServiceExtension {
    override func logDropConfiguration() -> LogDropConfig? {
        LogDropConfig.Builder()
            .setLoggingEnabled(true)
            .setBaseUrl("https://server.logdrop.io")
            .setPushAppGroupSuiteName("group.io.initialcode.LogDropDemoApp")
            .build()
    }
}
