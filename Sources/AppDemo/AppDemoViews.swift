// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import SkipUI
import SkipKit
import JavaScriptCore
import Foundation
import OSLog

// SKIP INSERT: import androidx.compose.runtime.*
// SKIP INSERT: import androidx.activity.compose.*
// SKIP INSERT: import androidx.compose.ui.*
// SKIP INSERT: import androidx.compose.material.*
// SKIP INSERT: import androidx.compose.ui.unit.*
// SKIP INSERT: import androidx.compose.foundation.*
// SKIP INSERT: import androidx.compose.foundation.layout.*
// SKIP INSERT: import androidx.compose.foundation.lazy.*

let logger: Logger = Logger(subsystem: "app.demo", category: "App")

protocol AppDemoView {
}

#if SKIP
class MainActivity : androidx.appcompat.app.AppCompatActivity, AppDemoView {
    init() {
    }

    override func onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                RootView()
            }
        }
    }
}
#else
public struct DemoApp: Scene {
    public init() {
    }

    public var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

#endif


// SKIP DECLARE: @Composable fun AhoyView()
struct AhoyView : View {
    // SKIP REPLACE: Text("Ahoy Skipper!", style = MaterialTheme.typography.h5)
    var body: some View {
        Text("Ahoy Skipper!")
    }
}

#if SKIP

// SKIP INSERT: @Composable
// @OptIn(ExperimentalFoundationApi::class)
// fun EntriesListView() {
//     LazyColumn(modifier = Modifier.fillMaxSize(), contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp)) {
//         stickyHeader { AhoyView() }
//         //AhoyView()
//         itemsIndexed(entries.toList()) { index, entry ->
//             EntryView(entry = entry)
//             Divider()
//         }
//     }
// }

// SKIP INSERT: @Composable
func RootView() {
    EntriesListView()
}


#else
struct RootView : View {
    var body: some View {
        List {
            Section {
                ForEach(entries) { entry in
                    EntryView(entry: entry)
                }
            } header: {
                AhoyView()
            }
        }
        .listStyle(.automatic)
    }
}
#endif

public struct Entry: Identifiable, Equatable, Hashable {
    public var id: UUID = UUID()
    var title = ""
}

// SKIP DECLARE: @Composable fun EntryView(entry: Entry)
struct EntryView : View {
    #if !SKIP
    let entry: Entry
    #endif

    // SKIP REPLACE: Text(entry.title, style = MaterialTheme.typography.h5)
    var body: some View { Text(entry.title) }
}

/// The list of entries to be displayed in the app
let entries: [Entry] = try! createEntries()

private func createEntries() throws -> [Entry] {
    logger.warning("creating entries")
    var entries: [Entry] = []
    entries += try leadingEntries()

    entries += try systemEntries()

    entries += [Entry(title: "Look how fast we can scroll…")]
    entries += try trailingEntries()

    return entries
}

private func leadingEntries() throws -> [Entry] {
    [
        Entry(title: "Welcome to Skip!"),
        Entry(title: "Greetings Matey…"),
        Entry(title: "Greetings Matey…"),
        Entry(title: "Greetings Matey…"),
        Entry(title: "Greetings Matey…"),
        Entry(title: "This is a native List"),
    ]
}

private func systemEntries() throws -> [Entry] {
    //let hostname = ProcessInfo.processInfo.hostName // Android error: "android.os.NetworkOnMainThreadException" from "java.net.Inet6AddressImpl.lookupHostByName"

    let sum = try SQLDB().query(sql: "SELECT 'lite'").nextRow(close: true)?.first?.textValue ?? "NONE"
    //let jsc = try JSContext().evaluateScript("'Java' + 'Script'")?.toString() ?? "NONE"
    return [
        Entry(title: "Int.max: \(Int.max)"),
        Entry(title: "SQL: \(sum)"),
        //Entry(title: "JSC: \(jsc)"),
    ]
}

// make a bunch of random rows to experiment with scrolling
private func trailingEntries(count: Int = 1000) throws -> [Entry] {
    logger.debug("creating \(count) trailing entries")

    return Array((1...count).map { i in
        Entry(title: "Trailing Entry \(i)")
    })
}

