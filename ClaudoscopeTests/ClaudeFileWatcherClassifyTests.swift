import XCTest
@testable import Claudoscope

final class ClaudeFileWatcherClassifyTests: XCTestCase {
    private let claudeDir = URL(fileURLWithPath: "/Users/x/.claude")
    private var prefix: String { ClaudeFileWatcher.registryDirPrefix(claudeDir: claudeDir) }

    private func kind(_ rel: String) -> ClaudeFileWatcher.PathKind? {
        ClaudeFileWatcher.classify(
            path: claudeDir.appendingPathComponent(rel).path,
            registryDirPrefix: prefix,
            usageDataDirPrefix: ClaudeFileWatcher.usageDataDirPrefix(claudeDir: claudeDir)
        )
    }

    func testSessionTranscripts() {
        XCTAssertEqual(kind("projects/-Users-x-proj/abc.jsonl"), .session)
        XCTAssertEqual(kind("projects/-Users-x-proj/abc/subagents/agent-1.jsonl"), .session)
        XCTAssertNil(kind("history.jsonl"))
    }

    func testNotificationSpool() {
        XCTAssertEqual(kind(".claudoscope-events/1758-123-4.json"), .notificationSpool)
    }

    func testRegistryJsonOnly() {
        XCTAssertEqual(kind("sessions/56010.json"), .registry)
        XCTAssertNil(kind("sessions/56010.abcdef0123.key"), ".key siblings hold secrets")
        XCTAssertNil(kind("projects/-Users-x-sessions/foo.json"), "a project dir named sessions is not the registry")
    }

    func testInsightsUsageDataJsonOnly() {
        XCTAssertEqual(kind("usage-data/facets/0b5f15e5-facb.json"), .insights)
        XCTAssertEqual(kind("usage-data/session-meta/0b5f15e5-facb.json"), .insights)
        XCTAssertNil(kind("usage-data/report.html"), "the /insights HTML report is not facet data")
        XCTAssertNil(kind("plugins/x/usage-data/facets/a.json"), "only the root usage-data dir counts")
    }

    func testConfigFiles() {
        XCTAssertEqual(kind("settings.json"), .config)
        XCTAssertEqual(kind("plugins/x/.mcp.json"), .config)
        XCTAssertEqual(kind("commands/foo.md"), .config)
        XCTAssertNil(kind("daemon.status.json"))
    }
}
