// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import SkipUI
import SkipKit
import JavaScriptCore
import Foundation
import OSLog

// SKIP INSERT: import androidx.appcompat.app.AppCompatActivity
// SKIP INSERT: import androidx.compose.runtime.*
// SKIP INSERT: import androidx.activity.compose.*
// SKIP INSERT: import androidx.compose.ui.*
// SKIP INSERT: import androidx.compose.material.*
// SKIP INSERT: import androidx.compose.ui.text.*
// SKIP INSERT: import androidx.compose.ui.text.style.*
// SKIP INSERT: import androidx.compose.ui.graphics.*
// SKIP INSERT: import androidx.compose.ui.unit.*
// SKIP INSERT: import androidx.compose.foundation.*
// SKIP INSERT: import androidx.compose.foundation.shape.*
// SKIP INSERT: import androidx.compose.foundation.layout.*
// SKIP INSERT: import androidx.compose.foundation.lazy.*

let logger: Logger = Logger(subsystem: "app.demo", category: "App")

#if !SKIP
public struct DemoApp: Scene {
    public init() {
    }

    public var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
#else
public class MainActivity : AppCompatActivity {
    public init() {
    }

    public override func onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                RootView()
            }
        }
    }
}
#endif


// SKIP DECLARE: @Composable fun AhoyView()
struct AhoyView : View {
    public let text = "🏴‍☠️ Ahoy Skipper!!!! 🏴‍☠️"

    // SKIP REPLACE: Text(text, style = MaterialTheme.typography.subtitle1, modifier = Modifier.fillMaxWidth())
    var body: some View { Text(text).font(.subheadline) }
}

#if SKIP

// SKIP INSERT:
// @Composable
// @OptIn(ExperimentalFoundationApi::class)
// fun EntriesListView() {
//     Box(modifier = Modifier.fillMaxSize().background(color = Color(0xF1F1F6FF), shape = RoundedCornerShape(0.dp)).padding(16.dp)) {
//     Box(modifier = Modifier.fillMaxSize().background(color = Color.White, shape = RoundedCornerShape(16.dp)).padding(8.dp)) {
//     LazyColumn(modifier = Modifier.fillMaxSize(), contentPadding = PaddingValues(horizontal = 8.dp, vertical = 8.dp)) {
//         stickyHeader { AhoyView() }
//         //AhoyView()
//         itemsIndexed(entries.toList()) { index, entry ->
//             Box(modifier = Modifier.padding(8.dp)) {
//                 EntryView(entry = entry)
//             }
//             Divider()
//         }
//     }
//     }
//     }
// }

// SKIP INSERT: @Composable
func RootView() {
    EntriesListView()
}


#else

struct EntriesListView : View {
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
    }
}

struct RootView : View {
    var body: some View {
        EntriesListView()
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

    // SKIP REPLACE: Text(entry.title, maxLines = 1, overflow = TextOverflow.Ellipsis, style = MaterialTheme.typography.subtitle1, modifier = Modifier.fillMaxWidth())
    var body: some View { Text(entry.title).lineLimit(1).truncationMode(.tail).font(.subheadline).frame(maxWidth: .infinity, alignment: .leading) }
}

/// The list of entries to be displayed in the app
let entries: [Entry] = try! createEntries()

private func createEntries() throws -> [Entry] {
    var entries: [Entry] = []
    do {
        logger.info("initializaing app table contents…")
        entries += try leadingEntries()

        entries += try systemEntries()

        entries += [Entry(title: "Look how fast we can scroll…")]
        entries += try trailingEntries()
    } catch {
        logger.error("Error creating entries: \(error)")
        #if SKIP
        //error.printStackTrace()
        #endif
    }
    return entries
}

private func leadingEntries() throws -> [Entry] {
    [
        Entry(title: "Welcome to Skip!"),
        Entry(title: "This is a native List"),
    ]
}

private func systemEntries() throws -> [Entry] {
    //let hostname = ProcessInfo.processInfo.hostName // Android error: "android.os.NetworkOnMainThreadException" from "java.net.Inet6AddressImpl.lookupHostByName"

    var entries: [Entry] = []

    do {
        entries.append(Entry(title: "Int.max: \(Int.max)"))
    }

    do {
        let sum = try SQLDB().query(sql: "SELECT 'Li'||'te'").nextRow(close: true)?.first?.textValue ?? "NONE"
        entries.append(Entry(title: "SQL: \(sum)"))
    }

    #if !SKIP // skip.lib.ErrorException: java.lang.UnsatisfiedLinkError: Native library
    do {
        let script = JSContext().evaluateScript("'Scr'+'ipt'").toString() ?? ""
        entries.append(Entry(title: "Java: \(script)"))
    }
    #endif

    do {
        for (key, value) in ProcessInfo.processInfo.environment {
            entries.append(Entry(title: "ENV: \(key)=\(value)"))
        }
    }
    do {
        //let jsc = try JSContext().evaluateScript("'Java' + 'Script'")?.toString() ?? "NONE"
    }

    return entries
}

// make a bunch of random rows to experiment with scrolling
private func trailingEntries(count: Int = 1000) throws -> [Entry] {
    logger.debug("creating \(count) trailing entries")

    return Array((1...count).map { i in
        Entry(title: "Trailing Entry \(i)")
    })
}

