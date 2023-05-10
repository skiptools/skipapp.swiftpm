// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import App

#if !SKIP
@main
struct SkipApp: App {
    @StateObject var journalData = JournalData()
    var body: some Scene {
        WindowGroup {
            EntryList(journalData: journalData)
                .task {
                    journalData.load()
                }
                .onChange(of: journalData.entries) { _ in
                    journalData.save()
                }
        }
    }
}
#endif
