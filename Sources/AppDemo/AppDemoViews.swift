// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import SkipUI
import SkipKit
import JavaScriptCore
import Foundation
import OSLog

// SKIP INSERT: import android.app.Application
// SKIP INSERT: import androidx.appcompat.app.AppCompatActivity
// SKIP INSERT: import androidx.compose.runtime.*
// SKIP INSERT: import androidx.activity.compose.*
// SKIP INSERT: import androidx.compose.ui.*
// SKIP INSERT: import androidx.compose.ui.unit.*
// SKIP INSERT: import androidx.compose.ui.geometry.*
// SKIP INSERT: import androidx.compose.ui.graphics.*
// SKIP INSERT: import androidx.compose.ui.layout.*
// SKIP INSERT: import androidx.compose.ui.text.*
// SKIP INSERT: import androidx.compose.ui.text.style.*
// SKIP INSERT: import androidx.compose.foundation.*
// SKIP INSERT: import androidx.compose.foundation.shape.*
// SKIP INSERT: import androidx.compose.foundation.layout.*
// SKIP INSERT: import androidx.compose.foundation.lazy.*
// SKIP INSERT: import androidx.compose.material.*

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
public class SkipApp : android.app.Application {
    public init() {
    }

    public override func onCreate() {
        super.onCreate()
        ProcessInfo.launch(applicationContext)
    }
}

public class MainActivity : androidx.appcompat.app.AppCompatActivity {
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

/* SKIP INSERT:
@Composable
@OptIn(ExperimentalFoundationApi::class)
fun EntriesListView() {
    Box(modifier = Modifier.fillMaxSize().background(color = Color(0xF1F1F6FF), shape = RoundedCornerShape(0.dp)).padding(16.dp)) {
        Box(modifier = Modifier.fillMaxSize().background(color = Color.White, shape = RoundedCornerShape(16.dp)).padding(8.dp)) {
            LazyColumn(modifier = Modifier.fillMaxSize(), contentPadding = PaddingValues(horizontal = 8.dp, vertical = 8.dp)) {
                stickyHeader {
                    Box {
                        HeaderBackgroundCanvasView()
                        AhoyView()
                    }
                }
                itemsIndexed(entries.toList()) { index, entry ->
                    Box(modifier = Modifier.padding(8.dp)) {
                        EntryView(entry = entry)
                    }
                    Divider()
                }
            }
        }
    }
}
*/

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
                ZStack {
                    HeaderBackgroundCanvasView()
                    AhoyView()
                }
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

// SKIP DECLARE: @Composable fun HeaderBackgroundCanvasView()
struct HeaderBackgroundCanvasView : View {
    #if !SKIP
    var body: some View { skipBody() }
    #endif

    // SKIP DECLARE: run
    public func skipBody() -> some View {
        #if SKIP // Compose Canvas
        Canvas(modifier: Modifier.fillMaxWidth().height(25.dp)) {
            drawRect(color = Color.Yellow, alpha = Float(0.8), size: size)
            drawCircle(color = Color.Red, radius: size.height / 2, center: Offset(size.width - size.height, size.height / 2), alpha: Float(0.5))
        }
        #else // SwiftUI Canvas
        Canvas { ctx, size in
            ctx.fill(Path(roundedRect: CGRect(origin: .zero, size: size), cornerSize: .zero), with: .color(Color.yellow))
            ctx.fill(Path(ellipseIn: CGRect(origin: CGPoint(x: size.width - size.height, y: 0), size: CGSize(width: size.height, height: size.height))), with: .color(Color.red.opacity(0.5)))
        }
        #endif
    }
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

        //logger.warning("ABOUT TO ASSERT")
        //assert(false)
        //logger.warning("DONE WITH ASSERT")
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
        Entry(title: "Today is \(Date())"),
        Entry(title: "OS: \(ProcessInfo.processInfo.operatingSystemVersionString)"),
        //Entry(title: "Name: \(ProcessInfo.processInfo.processName)"),
        Entry(title: "Processor Count: \(ProcessInfo.processInfo.processorCount)"),
    ]
}

private func systemEntries() throws -> [Entry] {
    //let hostname = ProcessInfo.processInfo.hostName // Android error: "android.os.NetworkOnMainThreadException" from "java.net.Inet6AddressImpl.lookupHostByName"

    var entries: [Entry] = []

    do {
        entries.append(Entry(title: "Int.max: \(Int.max)"))
    }

    do {
        let db = try SQLContext()
        defer { db.close() }
        let sum = try db.query(sql: "SELECT 'Li'||'te'").nextRow(close: true)?.first?.textValue ?? "NONE"
        entries.append(Entry(title: "SQL: \(sum)"))
    }

    #if !SKIP // skip.lib.ErrorException: java.lang.UnsatisfiedLinkError: Native library
    do {
        let script = JSContext().evaluateScript("'Scr'+'ipt'").toString() ?? ""
        entries.append(Entry(title: "Java: \(script)"))
    }
    #endif

    #if SKIP
    func addSystemProperty(_ key: String) {
        let value = System.getProperty(key)
        logger.info("addSystemProperty: \(key)=\(value)")
        entries.append(Entry(title: "\(key): \(value)"))
    }

    addSystemProperty("os.name") // "Linux"
    addSystemProperty("os.arch") // "aarch64"
    addSystemProperty("os.version") // device: "4.19.191-26242230-abA037USQU3DWD1" emu: "5.15.41-android13-8-00055-g4f5025129fe8-ab8949913"
    addSystemProperty("java.vendor") // "The Android Project"
    addSystemProperty("java.version") // "0"
    addSystemProperty("user.home") // ""
    addSystemProperty("user.name") // "root"
    addSystemProperty("java.vm.version") // "2.1.0"
    addSystemProperty("java.vm.name") // "Dalvik"
    addSystemProperty("line.separator") // "\n"
    addSystemProperty("java.io.tmpdir") // "/data/user/0/app.demo/cache"
    addSystemProperty("java.library.path") // "/system/lib64:/system/system_ext/lib64"
    addSystemProperty("ro.kernel.qemu") // device: null

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

