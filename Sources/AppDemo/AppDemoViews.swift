// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import SwiftUI
import Foundation

// SKIP INSERT: import androidx.compose.runtime.*
// SKIP INSERT: import androidx.activity.compose.*
// SKIP INSERT: import androidx.compose.ui.*
// SKIP INSERT: import androidx.compose.material.*
// SKIP INSERT: import androidx.compose.ui.unit.*
// SKIP INSERT: import androidx.compose.foundation.*
// SKIP INSERT: import androidx.compose.foundation.layout.*
// SKIP INSERT: import androidx.compose.foundation.lazy.*

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
            DemoAppBaseView()
        }
    }
}

public struct DemoAppBaseView: View {
    public var body: some View {
        RootView()
    }
}

#endif


// SKIP DECLARE: @Composable fun AhoyView()
struct AhoyView : View {
    // SKIP REPLACE: Text("Ahoy Skipper!", style = MaterialTheme.typography.h3)
    var body: some View {
        Text("Ahoy Skipper!")
    }
}

#if SKIP

// SKIP INSERT: @Composable
// SKIP INSERT: @OptIn(ExperimentalFoundationApi::class)
// SKIP INSERT: fun EntriesListView() {
// SKIP INSERT:     LazyColumn(modifier = Modifier.fillMaxSize(), contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp)) {
// SKIP INSERT:         stickyHeader { AhoyView() }
// SKIP INSERT:         items(entries.toList()) { entry ->
// SKIP INSERT:             EntryView(entry = entry)
// SKIP INSERT:             Divider()
// SKIP INSERT:         }
// SKIP INSERT:     }
// SKIP INSERT: }

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
        Entry(title: "This is a native List"),
    ]
}

private func systemEntries() throws -> [Entry] {
    //let hostname = ProcessInfo.processInfo.hostName // Android error: "android.os.NetworkOnMainThreadException" from "java.net.Inet6AddressImpl.lookupHostByName"

    return [
        //Entry(title: "Hostname: \(hostname)")
    ]
}

private func trailingEntries(count: Int = 1000) throws -> [Entry] {
    Array((1...count).map { i in
        Entry(title: "Trailing Entry \(i)")
    })
}

