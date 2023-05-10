// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import SwiftUI
import Foundation


#if SKIP


// SKIP INSERT: import androidx.activity.compose.setContent
// SKIP INSERT: class SkipApp : android.app.Application() {
// SKIP INSERT: }
// SKIP INSERT: class SkipRoot : androidx.activity.ComponentActivity() {
// SKIP INSERT:     override fun onCreate(savedInstanceState: android.os.Bundle?) {
// SKIP INSERT:         super.onCreate(savedInstanceState)
// SKIP INSERT:         setContent {
// SKIP INSERT:             HelloSkip()
// SKIP INSERT:         }
// SKIP INSERT:     }
// SKIP INSERT: }
// SKIP INSERT: @androidx.compose.runtime.Composable fun HelloSkip() {
// SKIP INSERT:     androidx.compose.material.Text("Hello Skip!")
// SKIP INSERT: }

// needed or else SKIP INSERT won't insert anything
class DummyItem {

}

#endif

public struct Entry: Identifiable, Equatable, Hashable {
    public var id: UUID = UUID()
    var title = ""
    #if !SKIP
    var font : JournalFont = .font1
    var theme: JournalTheme = .line
    var entryRows: [EntryRow] = [
        EntryRow(count: 1, cards: [CardData(card: .text(value: TextData()), size: .large)])
    ]
    #endif
}

#if !SKIP
extension Entry : Codable {

}
#endif


#if !SKIP
struct RemoveCardButton: View {
    @Binding var entryCopy: Entry
    var card: Card
    var isEditing : Bool
    var row: Int
    var index: Int
    var action: () -> Void = { }

    var body: some View {
        Button() {
            entryCopy.removeCard(cards: entryCopy.entryRows[row].cards, row: row, index: index)
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(card.isPhoto ? .white : .darkBrown)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding([.top, .trailing])
        }
        .opacity(isEditing ? 1 : 0)
    }
}

struct FontButton: View {
    @Binding var entry: Entry
    var font : JournalFont
    var action: () -> Void = { }

    var body: some View {
        Button() {
            entry.font = font
        } label: {
            HStack {
                Image(systemName: entry.font == font ? "circle.fill" : "circle")
                    .font(.caption)
                Text(font.rawValue)
                    .font(font.uiFont(18))
                    .padding(.leading, 5)
                    .foregroundColor(.darkBrown)
            }
        }
    }
}

struct EditingButton: View {
    @Binding var entries: [Entry]
    @Binding var entry: Entry
    @Binding var entryCopy: Entry
    @Binding var isNew: Bool
    @Binding var isEditing : Bool
    var action: () -> Void = { }
    var isAdded: Bool {
        entries.filter({ $0.id == entryCopy.id }).first != nil
    }

    var body: some View {
        Button {
            if isNew && isEditing {
                if !isAdded {
                    entries.append(entryCopy)
                } else {
                    if let index = entries.firstIndex(where: { $0.id == entryCopy.id }){
                        entries[index].update(from: entryCopy)
                    }
                }
            } else if !isNew && isEditing {
                entry.update(from: entryCopy)
            } else if !isNew && !isEditing {
                entryCopy = entry
            }
            withAnimation(.spring()) {
                isEditing.toggle()
            }
        } label: {
            if isNew && isEditing {
                if isAdded {
                    Text("Done")
                        .fontWeight(.medium)
                } else {
                    Text("Add")
                        .fontWeight(.medium)
                }
            } else if !isNew && isEditing {
                Text("Done")
                    .fontWeight(.medium)
            } else if !isEditing {
                Text("Edit")
                    .fontWeight(.medium)
            }
        }
    }
}

struct EntryDetail: View {
    @Binding var entries: [Entry]
    @Binding var entry: Entry

    @State private var isNew: Bool
    @State private var isEditing: Bool
    @State private var entryCopy = Entry()

    init(entries: Binding<[Entry]>, entry: Binding<Entry>, isNew: Bool) {
        self._entries = entries
        self._entry = entry
        self._isNew = State(initialValue: isNew)
        self._isEditing = State(initialValue: isNew ? true : false)
    }

    var body: some View {
        EntryView(entry: isNew ? $entryCopy : $entry, entryCopy: $entryCopy, isEditing: $isEditing)
            .navigationBarBackButtonHidden(isNew ? false: isEditing)
            .toolbar {
                ToolbarItem {
                    EditingButton(entries: $entries, entry: $entry, entryCopy: $entryCopy, isNew: $isNew, isEditing: $isEditing)
                }
                #if canImport(UIKit)
                ToolbarItem (placement: .navigationBarLeading) {
                    if !isNew && isEditing {
                        Button("Cancel") {
                            withAnimation(.spring()) {
                                isEditing.toggle()
                            }
                        }
                    }
                }
                #endif
            }
    }
}

struct SettingsButton: View {
    @Binding var showSettings: Bool
    var currentEntry: Entry = Entry()
    var action: () -> Void = { }

    var body: some View {
        Button() {
            showSettings.toggle()
            action()
        } label: {
            SettingsButtonView(theme: currentEntry.theme)
        }
    }
}

struct SettingsButtonView: View {
    var theme: JournalTheme

    var body: some View {
        VStack (spacing: 0) {
            BackgroundIcon(forTheme: theme)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            Text("Theme >")
                .modifier(FontStyle(size: 12))
        }
        .padding(.vertical)
    }
}

struct NewEntryLabel: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.tanBackground)
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Color.darkBrown, style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
            Text("+ New Entry")
                .modifier(FontStyle(size: 30))
        }
        .frame(height: 80)
    }
}

struct CardView: View {
    @Binding var cardData: CardData
    var isEditing: Bool
    var fontStyle: JournalFont

    var body: some View {
        switch cardData.card {
        case .mood(let value):
            MoodView(value: Binding<String>( get: { value }, set: { cardData.card = .mood(value: $0) } ), isEditing: isEditing, fontStyle: fontStyle, size: cardData.size)
        case .sleep(let value):
            SleepView(value: Binding<Double>( get: { value }, set: { cardData.card = .sleep(value: $0) } ), isEditing: isEditing, fontStyle: fontStyle, size: cardData.size)
        case .sketch(let value):
            SketchView(value: Binding<[Line]>( get: { value }, set: { cardData.card = .sketch(value: $0) } ), isEditing: isEditing, fontStyle: fontStyle, size: cardData.size)
        case .photo(let value):
            PhotoView(value: Binding<ImageModel>( get: { value }, set: { cardData.card = .photo(value: $0) } ), isEditing: isEditing, fontStyle: fontStyle)
        case .text(let value):
            TextView(value: Binding<TextData>( get: { value }, set: { cardData.card = .text(value: $0) } ), isEditing: isEditing, fontStyle: fontStyle)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(cardData: .constant(CardData(card: .mood(value: "😢"))), isEditing: true, fontStyle: .font1)
            .background(CardBackground())
    }
}

public struct EntryList: View {
    @ObservedObject public var journalData: JournalData
    @State private var newEntry = Entry()
    @State private var selection: Entry?

    public init(journalData: JournalData) {
        self.journalData = journalData
    }

    public var body: some View{
        NavigationSplitView {
            VStack(alignment: .leading) {
                JournalAppTitle()
                List(selection: $selection) {
                    NewEntryLabel()
                        .tag(newEntry)
                        .modifier(ListRowStyle())

                    ForEach($journalData.entries){ $entry in
                        TitleView(entry: $entry)
                            .tag(entry)
                            .modifier(ListRowStyle())
                    }
                    .onDelete(perform: { indexSet in
                        journalData.entries.remove(atOffsets: indexSet)
                    })
                }
                .modifier(EntryListStyle())
            }
            .navigationTitle("Journal")
            .toolbar(.hidden)
            .background(
                Image("MenuBackground")
                    .resizable()
                    .modifier(BackgroundStyle())
            )

        } detail: {
            ZStack {
                if let entry = selection, let entryBinding = journalData.getBindingToEntry(entry) {
                    EntryDetail(entries: $journalData.entries, entry: entryBinding, isNew: entry == newEntry)
                } else {
                    SelectEntryView()
                }
            }
        }
    }
}


struct EntryList_Previews : PreviewProvider {
    static var previews: some View {
        EntryList(journalData: JournalData())
    }
}


struct JournalAppTitle: View {
    var body: some View {
        Text("Journal")
            .modifier(FontStyle(size: 50))
            .padding()
            .padding(.top)
    }
}

struct SelectEntryView: View {
    var body: some View {
        Text("Select An Entry")
            .modifier(FontStyle(size: 20))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.tanBackground)
            .ignoresSafeArea()
    }
}



struct EntryView: View {
    @Binding var entry: Entry
    @Binding var entryCopy: Entry
    @Binding var isEditing: Bool

    @State private var showingCardOptions = false
    @State private var showingSettings = false

    private func isSmallView(for entryRow: EntryRow) -> Bool {
        return entryRow.cards[0].size == .small
    }
    private var currentEntry: Entry {
        isEditing ? entryCopy : entry
    }
    private var currentEntryBinding: Binding<Entry> {
        isEditing ? $entryCopy : $entry
    }

    var body: some View {
        ScrollView {
            Grid(alignment: .top) {
                TitleView(entry: currentEntryBinding, isEditing: isEditing)
                    .padding(5)
                ForEach(0..<currentEntry.entryRows.count, id: \.self) { row in
                    if isSmallView(for: currentEntry.entryRows[row]) {
                        GridRow {
                            ForEach(0..<currentEntry.entryRows[row].count, id:\.self) { index in
                                getCardView(row: row, index: index)
                            }
                        }
                    } else {
                        getCardView(row: row, index: 0)
                    }
                }
                GridRow{
                    Color.clear
                        .gridCellUnsizedAxes([.horizontal, .vertical])
                    Color.clear
                        .gridCellUnsizedAxes([.horizontal, .vertical])
                }
            }
            .padding()

            Button() {
                showingCardOptions.toggle()
            } label: {
               AddNewCardLabel()
            }
            .opacity(isEditing ? 1 : 0)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showingCardOptions) {
            PickCardView(entry: currentEntryBinding, showingSheet: $showingCardOptions)
                .presentationDetents([.fraction(0.8)])
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                if isEditing {
                    SettingsButton(showSettings: $showingSettings, currentEntry: currentEntry)
                        .sheet(isPresented: $showingSettings) {
                            VStack {
                                SettingsView(entry: currentEntryBinding, showingSheet: $showingSettings)
                            }
                        }
                }
            }
        }
        .background(
            EntryBackground(forTheme: currentEntry.theme)
                .modifier(BackgroundStyle())
                .opacity(isEditing ? 0.5 : 1)

        )
    }

    @ViewBuilder
    private func getCardView(row: Int, index: Int) -> some View {
        CardView(cardData: currentEntryBinding.entryRows[row].cards[index], isEditing: isEditing, fontStyle: currentEntry.font)
            .overlay(alignment: .topTrailing){
                RemoveCardButton(entryCopy: $entryCopy, card: currentEntry.entryRows[row].cards[index].card, isEditing: isEditing, row: row, index: index)
            }
            .modifier(CardStyle(theme: currentEntry.theme))
    }
}

struct EntryView_Previews : PreviewProvider {
    static var previews: some View {
        EntryView(entry: .constant(Entry()), entryCopy: .constant(Entry()), isEditing: .constant(true))
    }
}

struct AddNewCardLabel: View {
    var body: some View {
        ZStack {
            Image(systemName: "circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.paleOrange)
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.darkBrown)
        }
        .padding(.vertical)
    }
}




struct PickCardView: View {
    @Binding var entry: Entry
    @Binding var showingSheet: Bool

    var body: some View {
        VStack {
            Grid (horizontalSpacing: 15, verticalSpacing: 15) {
                GridRow {
                    Color.clear
                        .gridCellUnsizedAxes([.horizontal, .vertical])
                    Text("Half")
                        .modifier(FontStyle(size: 18))
                    Text("Full")
                        .modifier(FontStyle(size: 18))
                }

                ForEach(Card.allCases, id: \.id){ option in
                    GridRow {
                        Text(Card.title(option))
                            .modifier(FontStyle(size: 18))
                            .gridCellAnchor(.trailing)
                        Button {
                            entry.addCard(card: CardData(card: option, size: .small))
                            showingSheet = false
                        } label: {
                            CardOptionView(icon: Card.icon(option))
                                .frame(maxWidth: 60, maxHeight: 60)
                        }
                        .disabled(SleepView.disableSleepViewHalf &&
                            option == .sleep(value: 0))
                        .opacity(option == .sleep(value: 0) && SleepView.disableSleepViewHalf ? 0.5 : 1)

                        Button {
                            entry.addCard(card: CardData(card: option, size: .large))
                            showingSheet = false
                        } label: {
                            CardOptionView(icon: Card.icon(option))
                                .frame(maxWidth: 100, maxHeight: 60)
                        }
                        .disabled(MoodView.disableMoodViewFull &&
                            option == .mood(value: "😁"))
                        .opacity(option == .mood(value: "😁") && MoodView.disableMoodViewFull ? 0.5 : 1)

                    }
                }
            }
        }
        .padding(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.paleOrange)
        .overlay(alignment: .topTrailing) {
            Button {
                showingSheet.toggle()
            } label: {
                Image(systemName: "xmark")
                    .modifier(FontStyle(size: 16))
            }
            .padding()
        }
    }
}

struct PickCardView_Previews: PreviewProvider {
    static var previews: some View {
        PickCardView(entry: .constant(Entry()), showingSheet: .constant(true))
    }
}

struct CardOptionView: View {
    var icon: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.darkBrown)
            Image(systemName: icon)
                .foregroundColor(.paleOrange)
                .font(.system(size: 25))
        }

    }
}

struct MoodViewHalfPreview: View {
    var body: some View {
        Grid {
            GridRow{
                MoodViewHalf(value: .constant("😁"), isEditing: false, fontStyle: .font1)
                    .modifier(CardStyle())

                MoodViewHalf(value: .constant("😁"), isEditing: true, fontStyle: .font1)
                    .modifier(CardStyle())
            }
        }
        .padding(.horizontal)
    }
}

struct MoodViewFullPreview: View {
    var body: some View {
        ScrollView {
            Grid {
                MoodViewFullSolution(value: .constant("😢"), isEditing: true, fontStyle: .font1)
                    .modifier(CardStyle())

                MoodViewFullSolution(value: .constant("😢"), isEditing: false, fontStyle: .font1)
                    .modifier(CardStyle())

                Divider()

                MoodViewFull(value: .constant("😢"), isEditing: true, fontStyle: .font1)
                    .modifier(CardStyle())

                MoodViewFull(value: .constant("😢"), isEditing: false, fontStyle: .font1)
                    .modifier(CardStyle())
            }
            .padding(.horizontal)
        }
    }
}

struct SleepViewHalfPreview: View {
    var body: some View {
        Grid {
            GridRow{
                SleepViewHalfSolution(value: .constant(5.0), isEditing: false, fontStyle: .font1)
                    .modifier(CardStyle())

                SleepViewHalfSolution(value: .constant(5.0), isEditing: true, fontStyle: .font1)
                    .modifier(CardStyle())

            }

            Divider()

            GridRow{
                SleepViewHalf(value: .constant(5.0), isEditing: false, fontStyle: .font1)
                    .modifier(CardStyle())

                SleepViewHalf(value: .constant(5.0), isEditing: true, fontStyle: .font1)
                    .modifier(CardStyle())

            }
        }
        .padding(.horizontal)
    }
}

struct SleepViewFullPreview: View {
    var body: some View {
        Grid {
            SleepViewFull(value: .constant(5.0), isEditing: true, fontStyle: .font1)
                .modifier(CardStyle())

            SleepViewFull(value: .constant(5.0), isEditing: false, fontStyle: .font1)
                .modifier(CardStyle())

        }
        .padding(.horizontal)
    }
}

struct ViewSizingSolution : View {
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.paleOrange)
                    .frame(maxWidth: 200, maxHeight: 150)
                VStack {
                    Text("Roses are red,")
                    Image("Rose")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 50)
                        .foregroundColor(.themeRed)
                    Text("violets are blue, ")
                }
            }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.paleOrange)
                    .frame(maxWidth: 200, maxHeight: 150)
                VStack {
                    Text("I just love")
                    Image("Heart")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 50)
                        .foregroundColor(.themeRed)
                    Text("coding with you!")
                }
            }
        }
        .font(.headline)
        .foregroundColor(.darkBrown)
    }
}

struct ViewSizingChallengePreview: View {
    var body: some View {
        VStack {
            ViewSizingSolution()
            Divider()
                .frame(height: 4)
                .overlay(Color.paleOrange)
            SizingView()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.darkBrown)
    }
}
struct SleepViewHalfSolution: View {
    @Binding var value: Double
    var isEditing: Bool
    var fontStyle: JournalFont

    var body: some View {
        VStack {
            Text(isEditing ? "How many hours did you sleep?" : "Hours Slept")
                .foregroundColor(.darkBrown)
                .font(fontStyle.uiFont(15))
                .frame(maxWidth: .infinity, alignment: isEditing ? .leading : .center)
            Spacer()

            Text("\(Int(value))")
                .modifier(FontStyle(size: 50))

            Spacer()

            if isEditing {
                Stepper("Hours Slept", value: $value, in: 0...12, step: 1)
                    .labelsHidden()
            }
        }
        .frame(minHeight: 100, maxHeight: 200)
        .padding()
    }
}

struct MoodViewFullSolution: View {
    @Binding var value: String
    var isEditing: Bool
    var fontStyle: JournalFont
    let displayEmojis = 3
    private let emojis = ["😢", "😴", "😁", "😡", "😐"]

    var body: some View {
        VStack {
            Text(isEditing ? "What's your mood?" : "Mood")
                .foregroundColor(.darkBrown)
                .font(fontStyle.uiFont(15))
                .frame(maxWidth: .infinity, alignment: isEditing ? .leading : .center)

            HStack {
                if isEditing {
                    ForEach(emojis, id: \.self) { emoji in
                        Button{
                            value = emoji
                        } label: {
                            VStack {
                                Text(emoji)
                                    .font(.system(size: 35))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.bottom)

                                Image(systemName: value == emoji ? "circle.fill" : "circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(.darkBrown)
                            }
                        }
                    }
                } else {
                    ForEach(0..<displayEmojis, id:\.self) { index in
                        Text(value)
                            .font(.system(size: 50))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)

        }
        .frame(minHeight: 100, maxHeight: 200)
        .padding()
    }
}

struct YourTitleBannerSolutionView : View {
    var body: some View {
        HStack {
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 25)
                        .foregroundColor(.bannerBlue)
                    Circle()
                        .frame(width: 15)
                        .foregroundColor(.bannerYellow)
                        .offset(x:-10, y:-5)
                }
                ZStack {
                    Circle()
                        .frame(width: 30)
                        .foregroundColor(.bannerPink)
                        .offset(x:-5)
                    Circle()
                        .frame(width: 20)
                        .foregroundColor(.bannerOrange)
                        .offset(x: 10, y: 5)
                }
            }
            Spacer()
            ZStack {
                 Circle()
                     .frame(width: 40)
                     .foregroundColor(.bannerBlue)
                     .offset(x: 5, y:-10)
                Circle()
                    .frame(width: 30)
                    .foregroundColor(.bannerPink)
                    .offset(x: 6, y: 5)

                Circle()
                    .frame(width: 18)
                    .foregroundColor(.bannerOrange)
                    .offset(y: 20)
            }
        }
    }
}

struct TitleBannerPreview: View {
    var body: some View {
        VStack {
            YourTitleBannerSolutionView()
                .modifier(EntryBannerStyle(theme: .line))
            YourTitleBannerView()
                .modifier(EntryBannerStyle(theme: .line))
        }
        .padding()
    }
}

struct PatternChallengeSolutionView: View {
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.themeBlue)
                Circle()
                    .foregroundColor(.themePink)
            }
            ZStack {
                Rectangle()
                    .foregroundColor(.themeBlue)
                HStack {
                    Circle()
                        .foregroundColor(.themeRed)
                    Circle()
                        .foregroundColor(.themeOrange)
                }
            }
        }
    }
}

struct PatternChallengePreview: View {
    var body: some View {
        VStack {
            PatternChallengeSolutionView()
            Divider()
            LayingOutContainersView()
        }
        .padding()
    }
}

struct SettingsView: View {
    @Binding var entry: Entry
    @Binding var showingSheet: Bool

    var body: some View {
        ScrollView {
            VStack (alignment: .leading, spacing: 10) {
                Text("Font")
                    .modifier(FontStyle(size: 20))
                    .padding(.top)
                ForEach(JournalFont.allCases, id: \.self) { font in
                    FontButton(entry: $entry, font: font)
                }
                Text("Theme")
                    .modifier(FontStyle(size: 20))
                    .padding(.top)
                Grid (horizontalSpacing: 5, verticalSpacing: 10){
                    GridRow {
                        getBackgroundButton(theme: .line)
                        getBackgroundButton(theme: .curve)
                        getBackgroundButton(theme: .wave)
                    }
                    GridRow {
                        getBackgroundButton(theme: .dot)
                        getBackgroundButton(theme: .ray)
                    }
                }
            }
        }
        .frame(maxWidth: 500)
        .padding(30)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topTrailing) {
            Button {
                showingSheet.toggle()
            } label: {
                Text("Done")
                    .modifier(FontStyle(size: 20))
                    .padding()
            }
        }
        .background(Color.paleOrange)
    }

    @ViewBuilder
    func getBackgroundButton(theme: JournalTheme) -> some View {
        Button {
            entry.theme = theme
        } label: {
            VStack (spacing: 5){
                BackgroundIcon(forTheme: theme)
                    .scaledToFill()
                    .cornerRadius(10.0)
                    .shadow(color: Color.shadow, radius: 4)
                    .padding(5)

                Image(systemName: entry.theme == theme ? "circle.fill" : "circle")
                    .font(.callout)
            }
        }
    }
}

struct SettingsView_Previews : PreviewProvider {
    static var previews: some View {
        SettingsView(entry: .constant(Entry()), showingSheet: .constant(true))
    }
}


struct EntryBannerTheme: View {
    var forTheme: JournalTheme
    var body: some View {
        switch forTheme {
        case .line:
            YourTitleBannerView()
        case .curve:
            CurveThemeView()
        case .dot:
            DotThemeView()
        case .ray:
            RayThemeView()
        case .wave:
            WaveThemeView()
        }
    }
}

struct BackgroundIcon: View {
    var forTheme: JournalTheme
    var body: some View {
        switch forTheme {
        case .line:
            Image("LineIcon")
                .resizable()
        case .curve:
            Image("CurveIcon")
                .resizable()
        case .dot:
            Image("DotIcon")
                .resizable()
        case .ray:
            Image("RayIcon")
                .resizable()

        case .wave:
            Image("WaveIcon")
                .resizable()
        }
    }
}

struct EntryBackground: View {
    var forTheme: JournalTheme
        var body: some View {
            switch forTheme {
            case .line:
                Image("LineBackground")
                    .resizable()
            case .curve:
                Image("CurveBackground")
                    .resizable()
            case .dot:
                Image("DotBackground")
                    .resizable()
            case .ray:
                Image("RayBackground")
                    .resizable()
            case .wave:
                Image("WaveBackground")
                    .resizable()
            }
        }
}

struct CardBackground: View {
    var theme: JournalTheme = .line
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .foregroundColor(getCardBackground(forTheme: theme))
            .shadow(color: Color.shadow, radius: 4)
    }

    func getCardBackground(forTheme: JournalTheme) -> Color {
        switch forTheme {
        case .line:
            return Color.paleOrange
        case .curve:
            return Color.curveCard
        case .dot:
            return Color.dotCard
        case .ray:
            return Color.rayCard
        case .wave:
            return Color.waveCard
        }
    }
}

struct CardStyle: ViewModifier {
    var theme: JournalTheme = .line
    func body(content: Content) -> some View {
        content
            .background(CardBackground(theme: theme))
            .padding(5)
    }
}

extension JournalFont {
    func uiFont( _ size: CGFloat) -> Font{
        switch self {
        case .font1:
            return Font.system(size:size,weight: .medium, design: .rounded)
        case .font2:
            return Font.custom(rawValue, size: size)

        case .font3:
            return Font.custom(rawValue, size: size)
        }
    }
}

struct FontStyle: ViewModifier {
    var size: CGFloat
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .medium, design: .rounded))
            .foregroundColor(.darkBrown)
    }
}

struct EntryBannerStyle: ViewModifier {
    var theme: JournalTheme
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .background(CardBackground(theme: theme))
    }
}

struct BackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .ignoresSafeArea()
    }
}

struct ListRowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

struct EntryListStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .navigationTitle("Journal")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar(.hidden)
    }
}

struct MoodView: View {
    @Binding var value: String
    var isEditing: Bool
    var fontStyle: JournalFont
    var size: CardSize

    static var disableMoodViewFull = false

    var body: some View {
        if size == .small {
            MoodViewHalf(value: $value, isEditing: isEditing, fontStyle: fontStyle)
        } else {
            MoodViewFull(value: $value, isEditing: isEditing, fontStyle: fontStyle)
        }

    }
}




struct MoodViewFull: View {
    @Binding var value: String
    var isEditing: Bool
    var fontStyle: JournalFont
    let displayEmojis = 3
    private let emojis = ["😢", "😴", "😁", "😡", "😐"]

    var body: some View {
        VStack {
            Text(isEditing ? "What's your mood?" : "Mood")
                .foregroundColor(.darkBrown)
                .font(fontStyle.uiFont(15))
                .frame(maxWidth: .infinity, alignment: isEditing ? .leading : .center)


            HStack {
                if isEditing {
                    ForEach(emojis, id: \.self) { emoji in
                        Button {
                            value = emoji
                        } label: {
                            VStack {
                                Text(emoji)
                                    .font(.system(size: 35))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.bottom)
                                Image(systemName: value == emoji ? "circle.fill" : "circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(.darkBrown)
                            }
                        }
                    }
                } else {
                    ForEach(0..<displayEmojis, id:\.self) { index in
                        Text(value)
                            .font(.system(size: 50))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(minHeight: 100, maxHeight: 200)
        .padding()
    }
}

struct MoodViewFull_Previews : PreviewProvider {
    static var previews: some View {
        MoodViewFullPreview()
    }
}

struct MoodViewHalf: View {
    @Binding var value: String
    var isEditing: Bool
    var fontStyle: JournalFont
    private let emojis = ["😢", "😴", "😁", "😡", "😐"]
    @State private var emojiIndex = 2

    var body: some View {
        VStack(alignment: .leading) {
            Text("Mood")
                .foregroundColor(.darkBrown)
                .font(fontStyle.uiFont(15))
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                if isEditing {
                    Button {
                        emojiIndex -= 1
                        value = emojis[emojiIndex]
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.darkBrown)
                            .font(.system(size: 17))
                    }
                    .disabled(emojiIndex-1 < 0)
                    .opacity(emojiIndex-1 < 0 ? 0.5 : 1)
                }

                Text(value)
                    .font(.system(size: isEditing ? 40 : 60))

                if isEditing {
                    Button {
                        emojiIndex += 1
                        value = emojis[emojiIndex]
                    } label: {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.darkBrown)
                            .font(.system(size: 17))

                    }
                    .disabled(emojiIndex+1 > 4)
                    .opacity(emojiIndex+1 > 4 ? 0.5 : 1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minHeight: 100, maxHeight: 200)
        .padding()
    }
}

struct MoodViewHalf_Previews : PreviewProvider {
    static var previews: some View {
        MoodViewHalfPreview()
    }
}
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

/*
See the License.txt file for this sample’s licensing information.
*/


import SwiftUI
import PhotosUI

struct PhotoView: View {
    @Binding var value: ImageModel
    @State private var imageState: ImageState = .empty
    @State private var imageSelection: PhotosPickerItem?
    var isEditing: Bool
    var fontStyle: JournalFont

    var body: some View {
        ZStack {
            Group {
                RoundedRectangle(cornerRadius: 10)
                    .frame(minHeight: 100, maxHeight: 200)
                    .foregroundColor(.clear)

                Image(systemName: "photo.fill")
                    .foregroundColor(.darkBrown)
                    .font(.system(size: 30))
            }
            .opacity(isEditing ? 0 : 1)
            VStack {
                PhotosPicker(selection: $imageSelection, matching: .images, photoLibrary: .shared()) {
                    if isEditing {
                        getImg(imageState: imageState)
                            .scaledToFill()
                            .frame(minWidth: 20, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                    }
                }
                .onChange(of: imageSelection) { newItem in
                    updateImageState(newItem: newItem)
                }
                .task {
                    initializeImageState()
                }
            }

            if !isEditing, let url = value.url {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 20, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                } placeholder: {
                    Text("Loading Image...")
                        .modifier(FontStyle(size: 12))
                }

            }
            Image(systemName: "photo.fill")
                .foregroundColor(.white)
                .font(.system(size: 16))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .opacity(isEditing ? 1 : 0)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func getImg(imageState: ImageState) -> some View {
        switch imageState {
        case .success(let url):
            AsyncImage(url: url) { image in
                image
                    .resizable()
            } placeholder: {
                Text("Loading Image...")
                    .modifier(FontStyle(size: 12))
            }
        case .loading:
            Text("Loading Image...")
                .modifier(FontStyle(size: 12))
        case .empty:
            Image(systemName: "plus")
                .font(.system(size: 30))
        case .failure(_):
            Image("errorloadingimage")
                .resizable()
                .scaledToFit()
                .frame(height: 35)
        }
    }

    private func initializeImageState() {
        if let url = value.url {
            imageState = .success(url)
        }
    }

    private func updateImageState(newItem: PhotosPickerItem?) {
        Task {
            do {
                imageState = .loading
                guard let photoFile = try await newItem?.loadTransferable(type: PhotoFile.self),
                      let url = try FileManager.default.copyItemToDocumentDirectory(from: photoFile.url) else {
                     imageState = .empty
                     return
                 }
                print("image saved to: \(url)")
                value.fileName = url.lastPathComponent
                print("image file name: \(url.lastPathComponent)")
                imageState = .success(url)

            } catch {
                print("Image download failed with error \(error.localizedDescription)")
                imageState = .failure(error)
            }
        }
    }
}

struct PhotoView_Previews : PreviewProvider {
    static var previews: some View {
        PhotoView(value: .constant(ImageModel()), isEditing: true, fontStyle: .font1)
            .background(CardBackground())
    }
}




struct SketchView: View {
    @Binding var value: [Line]
    var isEditing: Bool
    var fontStyle: JournalFont

    var size: CardSize
    @State private var penColor = Color.darkBrown

    private var penColors: [Color] {
        if size == .small {
            return [Color.darkBrown]
        } else {
            return
               [.themePink,
                .themeRed,
                .themeOrange,
                .themeGreen,
                .themeBlue,
                .themeTeal,
                .darkBrown]
        }
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                if isEditing {
                    Text("Draw a sketch")
                        .foregroundColor(.darkBrown)
                        .font(fontStyle.uiFont(15))
                }

                Canvas { context, size in
                    for line in value {
                        var path = Path()
                        path.addLines(line.points)
                        context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                    }
                }
                .frame(minHeight: size == .small ? 100 : 250, maxHeight: 250)
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ line in
                    let newPoint = line.location
                    if line.translation.width + line.translation.height == 0 {
                        value.append(Line(points: [newPoint], color: penColor, lineWidth: 5))
                    } else {
                        let index = value.count - 1
                        value[index].points.append(newPoint)
                    }
                }))
                .disabled(!isEditing)

                if isEditing {
                    HStack {
                        ForEach(penColors, id:\.self) { color in
                            Button {
                                penColor = color
                            } label: {
                                Image(systemName: penColor == color ? "circle.fill" : "circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(color)
                            }
                        }
                        Spacer()
                        Button {
                            value.removeLast()
                            while let lastLine = value.last {
                                if lastLine.points.count <= 1 {
                                    value.removeLast()
                                } else {
                                    break
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .foregroundColor(.darkBrown)
                                .font(.system(size: 20, weight: .bold))
                                .opacity(value.isEmpty ? 0.3 : 1)
                        }
                        .disabled(value.isEmpty)
                    }
                }

            }
            .padding()
        }
    }
}


struct SketchView_Previews : PreviewProvider {
    static var previews: some View {
        SketchView(value: .constant([Line(points: [CGPoint(), CGPoint()], color: Color.black, lineWidth: 5)]), isEditing: true, fontStyle: .font1, size: .large)
            .background(CardBackground())
    }
}
struct SleepView: View {
    @Binding var value: Double
    var isEditing: Bool
    var fontStyle: JournalFont
    var size: CardSize

    static var disableSleepViewHalf = false


    var body: some View {
        if size == .small {
            SleepViewHalf(value: $value, isEditing: isEditing, fontStyle: fontStyle)
        } else {
            SleepViewFull(value: $value, isEditing: isEditing, fontStyle: fontStyle)
        }
    }
}



struct SleepViewFull: View {
    @Binding var value: Double
    var isEditing: Bool
    var fontStyle: JournalFont


    var body: some View {
        VStack(alignment: .leading) {
            Text(isEditing ? "How many hours did you sleep?" : "Hours Slept: \(Int(value))")
                .foregroundColor(.darkBrown)
                .font(fontStyle.uiFont(15))

            if isEditing {
                HStack (spacing: 10) {
                    Text("\(Int(value))")
                        .foregroundColor(.darkBrown)

                    ZStack(alignment: .center) {
                        Slider(value: $value, in: 0...12, step: 1)
                            .padding(.horizontal)
                            //.accentColor(Color(UIColor.systemTeal))
                    }
                    Text("12")
                        .foregroundColor(.darkBrown)
                }
                .frame(maxHeight: .infinity)

            } else {
                HStack {
                    Image(systemName: "moon.zzz.fill")
                        .foregroundColor(.darkBrown)
                        .font(.system(size: 30))
                    Grid (horizontalSpacing: 0) {
                        GridRow {
                           ForEach(0..<12) { column in
                               Rectangle()
                                   .frame(height: 15)
                                   .foregroundColor( column < Int(value) ? .themeBlue: .darkBrown.opacity(0.5))
                           }
                        }
                    }
                    .cornerRadius(45.0)
                }
                .frame(maxWidth: .infinity,maxHeight: .infinity)
            }
        }
        .frame(minHeight: 100, maxHeight: 300)
        .padding()
    }
}

struct SleepViewFull_Previews : PreviewProvider {
    static var previews: some View {
        SleepViewFullPreview()
    }
}

struct SleepViewHalf: View {
    @Binding var value: Double
    var isEditing: Bool
    var fontStyle: JournalFont

    var body: some View {
        VStack {
            Text("Hours Slept")
                .foregroundColor(.darkBrown)
                .font(fontStyle.uiFont(15))
            //#-learning-code-snippet(6.frameAlignment)

            Text("\(Int(value))")
                .foregroundColor(.darkBrown)
                .modifier(FontStyle(size: 50))
            //#-learning-code-snippet(5.paddingSleep)

            //#-learning-code-snippet(5.stepper)
        }
        //#-learning-code-snippet(5.sleepFrame)
        //#-learning-code-snippet(6.paddingCard)
    }
}

struct SleepViewHalf_Previews : PreviewProvider {
    static var previews: some View {
        SleepViewHalfPreview()
    }
}

struct TextView: View {
    @Binding var value: TextData
    var isEditing: Bool
    var fontStyle: JournalFont = .font1

    var placeHolderText = "Write Something"
    var containsPlaceHolderText: Bool {
        value.text == placeHolderText
    }

    var body: some View {
        VStack(alignment: .leading) {
            if isEditing {
                TextEditor(text: $value.text)
                    .font(fontStyle.uiFont(value.fontSize.rawValue))
                    .foregroundColor(
                        Color("dark-brown")
                            .opacity(containsPlaceHolderText ? 0.7 : 1)
                    )
                    .onTapGesture {
                        if containsPlaceHolderText {
                            value.text = ""
                        }
                    }
                    .padding(.top)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 50, maxHeight: .infinity)
                HStack {
                    ForEach(FontSize.allCases, id: \.self) { fs in
                        Button {
                            value.fontSize = fs
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundColor(value.fontSize == fs ? .darkBrown : .clear)
                                    .frame(width: 20, height: 24)
                                Text("A")
                                    .foregroundColor(value.fontSize == fs ? .paleOrange : .darkBrown)
                                    .font(.system(size: fs.rawValue, weight: .medium, design: .rounded))
                                    .frame(width: 20, height: 24, alignment: .center)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity,  alignment: .center)

            } else {
                Text(value.text)
                    .font(fontStyle.uiFont(value.fontSize.rawValue))
                    .foregroundColor(
                        Color("dark-brown")
                            .opacity(containsPlaceHolderText ? 0 : 1)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        .onAppear {
            #if canImport(UIKit)
            UITextView.appearance().backgroundColor = .clear
            #endif
        }
    }

}

struct TextView_Previews : PreviewProvider {
    static var previews: some View {
        TextView(value: .constant(TextData()), isEditing: true)
            .background(CardBackground())
    }
}


struct TitleView: View {
    @Binding var entry: Entry
    var isEditing: Bool = false
    var body: some View {
        ZStack {
            EntryBannerTheme(forTheme: entry.theme)
                .modifier(EntryBannerStyle(theme: entry.theme))

            if isEditing {
                TextField("Add title", text: $entry.title)
                    .font(entry.font.uiFont(30))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.darkBrown)
            } else {
                Text(entry.title)
                    .font(entry.font.uiFont(30))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.darkBrown)
            }
        }
    }
}


struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(entry: .constant(Entry()), isEditing: false)
    }
}

struct AmazingAlignment: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 40))
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 10)
            VStack (alignment: .trailing){
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 40))

                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 10)
            }
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 40))
                .frame(maxWidth: .infinity, alignment: .trailing)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 10)
            HStack(spacing: 20) {
                Spacer()
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 40))
                    .background(Color.yellow)
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 40))
                    .padding(.trailing, 20)
            }
            .background(Color.mint)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 10)
        }
        .padding(.horizontal)
        .frame(width: 250)
        .border(Color.black)
    }
}

struct AmazingAlignment_Previews: PreviewProvider {
    static var previews: some View {
        AmazingAlignment()
    }
}

struct HalfCard: View {
    var body: some View {
        VStack {
            Image(systemName: "crown.fill")
                .font(.system(size: 80))
        }
        //#-learning-code-snippet(6.debugFrameCorrection)
        .overlay (alignment: .topLeading) {
            VStack {
                Image(systemName: "crown.fill")
                    .font(.body)
                Text("Q")
                    .font(.largeTitle)
                Image(systemName: "heart.fill")
                    .font(.title)
            }
            .padding()
        }
        //#-learning-code-snippet(6.debugFrameQuestion)
        //#-learning-code-snippet(6.debugFrame)
        //#-learning-code-snippet(6.debugBorder)
    }
}

struct DebuggingView: View {
    var body: some View {
        VStack {
            HalfCard()
            HalfCard()
                .rotationEffect(.degrees(180))
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black)
        )
        .aspectRatio(0.70, contentMode: .fit)
        .foregroundColor(.red)
        .padding()
    }
}

struct DebuggingView_Previews: PreviewProvider {
    static var previews: some View {
        DebuggingView()
    }
}

struct FunWithFrames: View {

    var body: some View {
        HStack {
            //#-learning-code-snippet(3.rectangle)
            //#-learning-code-snippet(3.framesBasic)
            //#-learning-code-snippet(3.maxWidth)
        }
        //#-learning-code-snippet(3.modifiersIntro)
        //#-learning-code-snippet(3.maxWidthEffect)

    }
}

struct FunWithFrames_Previews: PreviewProvider {
    static var previews: some View {
        FunWithFrames()
    }
}

struct LayingOutContainersView: View {
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.themeBlue)
                Circle()
                    .foregroundColor(.themePink)
            }
            ZStack {
                Rectangle()
                    .foregroundColor(.themeBlue)
                HStack {
                    Circle()
                        .foregroundColor(.themeRed)
                    Circle()
                        .foregroundColor(.themeOrange)
                }
            }
        }
    }
}

struct LayingOutContainersView_Previews: PreviewProvider {
    static var previews: some View {
        LayingOutContainersView()
    }
}

struct OrganizingViews: View {
    var body: some View {
        VStack {
            Circle()
            Circle()
            //#-learning-code-snippet(2.containers)
            //#-learning-code-snippet(4.containers)
            //#-learning-code-snippet(5.containers)
            //#-learning-code-snippet(6.containers)
        }
    }
}



struct OrganizingViews_Previews : PreviewProvider {
    static var previews: some View {
            OrganizingViews()
    }
}
struct SizingView: View {
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.paleOrange)
                    .frame(maxWidth: 200, maxHeight: 150)
                VStack {
                    Text("Roses are red,")
                    Image("Rose")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 50)
                        .foregroundColor(.themeRed)
                    Text("violets are blue, ")
                }
            }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.paleOrange)
                    .frame(maxWidth: 200, maxHeight: 150)
                VStack {
                    Text("I just love")
                    Image("Heart")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 50)
                        .foregroundColor(.themeRed)
                    Text("coding with you!")
                }
            }
        }
        .font(.headline)
        .foregroundColor(.darkBrown)
    }
}

struct SizingView_Previews: PreviewProvider {
    static var previews: some View {
        SizingView()
    }
}

struct ViewSizing: View {

    var body: some View {
        HStack {

            //#-learning-code-snippet(2.viewSizing)
        }
    }
}

struct ViewSizing_Previews : PreviewProvider {
    static var previews: some View {
            ViewSizing()
    }
}
import CoreTransferable
import Foundation
import PhotosUI

enum Card: Equatable, CaseIterable, Codable {
    case mood(value: String)
    case sleep(value: Double)
    case sketch(value: [Line])
    case text(value: TextData)
    case photo(value: ImageModel)

    static var allCases: [Card] {
        return [.sleep(value: 0), .mood(value: "😁"), .text(value: TextData()), .photo(value: ImageModel()), .sketch(value: [Line]())]}

    var id: UUID { UUID() }

    var isPhoto: Bool {
        switch self {
        case .photo(_): return true
        default: return false
        }
    }

    static func title(_ card: Card) -> String {
        switch card {
        case mood(_):
            return "Mood Tracker"
        case sleep(_):
            return "Sleep Tracker"
        case sketch(_):
            return "Doodle"
        case text(_):
            return "Text Field"
        case photo(_):
            return "Photo"
        }
    }

    static func icon(_ card: Card) -> String {
        switch card {
        case mood(_):
            return "face.smiling.fill"
        case sleep(_):
            return "moon.zzz.fill"
        case sketch(_):
            return "pencil.tip"
        case text(_):
            return "textformat"
        case photo(_):
            return "photo.fill"
        }
    }

    static func == (lhs: Card, rhs: Card) -> Bool {
        switch (lhs, rhs) {
        case (.mood(let valueL), .mood(let valueR)):
            return valueL == valueR
        case (.sleep(let valueL), .sleep(let valueR)):
            return valueL == valueR
        case (.sketch(let valueL), .sketch(let valueR)):
            return valueL == valueR
        case (.text(let valueL), .text(let valueR)):
            return valueL == valueR
        case (.photo(let valueL), .photo(let valueR)):
            return valueL.url == valueR.url
        default:
            return false
        }
    }
}

struct CardData: Equatable, Codable {
    var card: Card
    var size: CardSize = .large

    mutating func updateSize(from newsize: CardSize){
        size = newsize
    }
}

enum CardSize: String, CaseIterable, Codable {
    case small
    case large
}

enum ImageState {
    case empty, loading, success(URL), failure(Error)
}

struct ImageModel: Codable {

    enum Location: String, Codable {
        case resources, documents
    }
    var fileName: String?
    var location = Location.documents

    var url: URL? {
        if location == .resources {
            if let jpegImage = Bundle.main.url(forResource: fileName, withExtension: "jpeg") {
                return jpegImage
            } else {
                return Bundle.main.url(forResource: fileName, withExtension: "png")
            }
        } else {
            guard let fileName else {
                return nil
            }
            let documentDirectory = FileManager.default.documentDirectory
            return documentDirectory.appendingPathComponent(fileName)
        }

    }
}
struct PhotoFile: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .image, shouldAttemptToOpenInPlace: false) { data in
            SentTransferredFile(data.url, allowAccessingOriginalFile: true)
        } importing: { received in
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = received.file.lastPathComponent
            let destinationURL = tempDirectory.appendingPathComponent(fileName)
            try FileManager.default.copyItem(at: received.file, to: destinationURL)
            return Self.init(url: destinationURL)
        }
    }
}

struct Line: Identifiable, Equatable, Codable {
    var points: [CGPoint]
    var color: Color {
        return Color(rgbaColor)
    }
    private var rgbaColor: RGBAColor
    var lineWidth: CGFloat
    var id = UUID()

    init(points: [CGPoint], color: Color, lineWidth: CGFloat) {
        self.points = points
        self.rgbaColor = color.rgbaColor
        self.lineWidth = lineWidth
    }
}

struct TextData: Equatable, Codable {
    var text: String = "Write Something"
    var fontSize: FontSize = .medium
}

enum FontSize: CGFloat, CaseIterable, Codable {
    case small = 12
    case medium = 16
    case large = 20
}

struct RGBAColor: Codable, Hashable {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var a: CGFloat
}

extension Color {
    var r: CGFloat { cgColor?.components?.first ?? 0.0 }
    var g: CGFloat { cgColor?.components?.dropFirst(1).first ?? 0.0 }
    var b: CGFloat { cgColor?.components?.dropFirst(2).first ?? 0.0 }
    var a: CGFloat { cgColor?.alpha ?? 1.0 }

    var rgbaColor: RGBAColor {
        RGBAColor(r: self.r, g: self.g, b: self.b, a: self.a)
    }

    init(_ rgbaColor: RGBAColor) {
        self.init(red: rgbaColor.r, green: rgbaColor.g, blue: rgbaColor.b, opacity: rgbaColor.a)
    }
}


extension Color {
    static let bannerBlue = Color("banner-blue")
    static let bannerOrange = Color("banner-orange")
    static let bannerPink = Color("banner-pink")
    static let bannerYellow = Color("banner-yellow")

    static let curveBlue = Color("curve-blue")
    static let curveBrown = Color("curve-brown")
    static let curveOrange = Color("curve-orange")
    static let curveRed = Color("curve-red")

    static let darkBrown = Color("dark-brown")
    static let tanBackground = Color("tan-background")
    static let shadow = Color("shadow")

    static let paleOrange = Color("pale-orange")
    static let rayCard = Color("ray-card")
    static let curveCard = Color("curve-card")
    static let dotCard = Color("dot-card")
    static let waveCard = Color("wave-card")

    static let dotBrown = Color("dot-brown")
    static let dotGreen = Color("dot-green")
    static let dotYellow = Color("dot-yellow")

    static let rayMauve = Color("ray-mauve")
    static let rayOrange = Color("ray-orange")
    static let rayPeach = Color("ray-peach")
    static let rayYellow = Color("ray-yellow")

    static let themeBlue = Color("theme-blue")
    static let themeOrange = Color("theme-orange")
    static let themeGreen = Color("theme-green")
    static let themePink = Color("theme-pink")
    static let themeRed = Color("theme-red")
    static let themeTeal = Color("theme-teal")
}

extension Entry {
   mutating func addCard(card: CardData) {
        if entryRows.count == 0 {
            entryRows.append(EntryRow(count: 1, cards: [card]))
        } else {
            if var entryRow = entryRows.last {
                if card.size == .small && entryRow.cards[0].size == card.size  {
                    if entryRow.count == 2 {
                        entryRows.append(EntryRow(count: 1, cards: [card]))
                    } else {
                        entryRow.cards.append(card)
                        let card = EntryRow(count: entryRow.count+1, cards:  entryRow.cards)
                        entryRows.removeLast()
                        entryRows.append(card)
                    }
                } else {
                    entryRows.append(EntryRow(count: 1, cards: [card]))
                }
            }
        }
    }
    mutating func update(from entry: Entry) {
        title = entry.title
        font = entry.font
        theme = entry.theme
        entryRows = entry.entryRows
    }

    mutating func removeCard(cards: [CardData], row: Int, index: Int) {
        if cards.count == 1 {
            entryRows.remove(at: row)
        } else {
            entryRows[row].cards.remove(at: index)
            entryRows[row].count =  entryRows[row].count-1
        }
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct EntryRow: Equatable, Codable {
    var count: Int
    var cards: [CardData]
}

enum JournalFont: String, CaseIterable, Codable {
    case font1 = "SF Pro Rounded"
    case font2 = "Bradley Hand"
    case font3 = "Times New Roman"
}


enum JournalTheme: String, CaseIterable, Codable {
    case line
    case curve
    case dot
    case ray
    case wave
}


// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

/*
See the License.txt file for this sample’s licensing information.
*/

import Foundation

extension FileManager {

    /// The URL of the document directory.
    var documentDirectory: URL {
        do {
             return try self.url(for: .documentDirectory, in: .userDomainMask,  appropriateFor: nil, create: true)
          }
          catch let error {
              fatalError("Unable to get the local documents url. Error: \(error)")
          }
    }

    /// Copies the specified file URL to a file with the same name in the document directory.
    ///
    /// - parameter url: The file URL to be copied.
    ///
    /// - returns: The URL of the copied or existing file in the documents directory, or nil if the copy failed.
    ///
    func copyItemToDocumentDirectory(from sourceURL: URL) throws -> URL? {
        let fileName = sourceURL.lastPathComponent
        let destinationURL = documentDirectory.appendingPathComponent(fileName)
        if self.fileExists(atPath: destinationURL.path) {
            return destinationURL
        } else {
            try self.copyItem(at: sourceURL, to: destinationURL)
            return destinationURL
        }
    }

    /// Removes an item with the specified file URL from the document directory, if present.
    ///
    /// - parameter url: The file URL to be removed.
    ///
    func removeItemFromDocumentDirectory(url: URL) {
        let fileName = url.lastPathComponent
        let fileUrl = documentDirectory.appendingPathComponent(fileName)
        if self.fileExists(atPath: fileUrl.path) {
            do {
                try self.removeItem(at: url)
            } catch let error {
                print("Unable to remove file: \(error.localizedDescription)")
            }
        }
    }
}
public class JournalData: ObservableObject {

    @Published public var entries: [Entry] = [
        Entry(
            title: "Home Garden",
            font: .font2 ,
            theme: .dot,
            entryRows:
                [
                EntryRow(count: 2,
                         cards: [
                            CardData(card: .photo(value: ImageModel(fileName: "Peony", location: .resources)), size: .small),
                            CardData(card: .text(value: TextData(text: "Some lovely pink Peonies I found in the garden today." )), size: .small)]),
                EntryRow(count: 2,
                         cards:[
                            CardData(card: .photo(value: ImageModel(fileName: "Daisy", location: .resources)), size: .small),
                            CardData(card: .text(value: TextData(text: "I’m going to bring some of these dasies to the neighbors as a housewarming present.")), size: .small)]),
                EntryRow(count: 1,
                         cards:[
                            CardData(card: .photo(value: ImageModel(fileName: "WhiteRose", location: .resources)), size: .large)]),
                EntryRow(count: 1,
                         cards: [
                         CardData(card: .text(value: TextData(text: "I need a little help identifying some of these flowers. I think steve has a coffee table book on flowers I might be able to borrow.")), size: .large)]),
                EntryRow(count: 2,
                         cards: [
                         CardData(card: .photo(value: ImageModel(fileName: "LemonBloom", location: .resources)), size: .small),
                         CardData(card: .mood(value: "😁"), size: .small)])
                ]
        ),
        Entry(
            title: "Japan Trip",
            font: .font3,
            theme: .curve,
            entryRows:
                [
                EntryRow(count: 1,
                         cards: [
                                CardData(card: .text(value: TextData(text: "I spent the day packing for the trip and making sure I have everything! Less than a week until we leave and I'm super excited for it!") ), size: .large)]),
                EntryRow(count: 2,
                         cards: [
                            CardData(card: .text(value: TextData(text: "Booked a cabin up north and I’m going to go Skiing for the first time!")), size: .small),
                            CardData(card: .photo(value: ImageModel(fileName: "Mountain", location: .resources)), size: .small)]),
                EntryRow(count: 1,
                         cards: [
                            CardData(card: .sleep(value: 7), size: .large)])
                ]
        )
    ]

    public init() {
        setup()
    }

    func getBindingToEntry(_ entry: Entry) -> Binding<Entry>? {
        Binding<Entry>(
            get: {
                guard let index = self.entries.firstIndex(where: { $0.id == entry.id }) else { return Entry()}
                return self.entries[index]
            },
            set: { entry in
                guard let index = self.entries.firstIndex(where: { $0.id == entry.id }) else { return }
                self.entries[index] = entry
            }
        )
    }

    private static func getDataFileURL() throws -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("entries.data")
    }

    public func load() {
        do {
            let fileURL = try JournalData.getDataFileURL()
            let data = try Data(contentsOf: fileURL)
            entries = try JSONDecoder().decode([Entry].self, from: data)
            print("Entry loaded: \(entries.count)")
        } catch {
            print("Failed to load from file. Backup data used")
        }
    }

    public func save() {
        do {
            let fileURL = try JournalData.getDataFileURL()
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save")
        }
    }

    func setup() {
        do {
            let fileURL = try JournalData.getDataFileURL()
            let data = try Data(contentsOf: fileURL)
            entries = try JSONDecoder().decode([Entry].self, from: data)
        } catch {
            save()
        }
    }
}

struct CurveThemeView: View {
    var body: some View {
        HStack {
            VStack{
                ZStack {
                    Circle()
                        .frame(width: 25)
                        .foregroundColor(.curveOrange)
                    Circle()
                        .frame(width: 15)
                        .foregroundColor(.curveRed)
                        .offset(x: -10, y: -5)
                }
                ZStack {
                    Circle()
                        .frame(width: 30)
                        .foregroundColor(.curveBrown)
                        .offset(x: -5)

                    Circle()
                        .frame(width: 20)
                        .foregroundColor(.curveBlue)
                        .offset(x: 10, y: 5)
                }
            }
            Spacer()
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 40)
                        .foregroundColor(.curveBlue)
                        .offset(x: 5, y: -10)
                    Circle()
                        .frame(width: 30)
                        .foregroundColor(.curveOrange)
                        .offset(x: 6, y: 5)
                    Circle()
                        .frame(width: 18)
                        .foregroundColor(.curveRed)
                        .offset(x: 0, y: 20)
                }
            }
        }
    }
}

struct CurveThemeView_Previews: PreviewProvider {
    static var previews: some View {
        CurveThemeView()
            .modifier(EntryBannerStyle(theme: .curve))
    }
}

struct DotThemeView: View {
    var body: some View {
        HStack {
            VStack{
                ZStack {
                    Circle()
                        .frame(width: 25)
                        .foregroundColor(.dotGreen)
                        .offset(x: -5, y: -5)
                    Circle()
                        .frame(width: 15)
                        .foregroundColor(.dotBrown)
                        .offset(x: 5, y: 5)
                }
                ZStack {
                    Circle()
                        .frame(width: 25)
                        .foregroundColor(.dotGreen)
                        .offset(x: 5, y: 5)
                    Circle()
                        .frame(width: 20)
                        .foregroundColor(.dotYellow)
                        .offset(x: -5, y: -5)
                }
            }
            Spacer()
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 40)
                        .foregroundColor(.dotGreen)
                        .offset(x: 5, y: 12)
                    Circle()
                        .frame(width: 30)
                        .foregroundColor(.dotBrown)
                        .offset(x: 7, y: -3)
                    Circle()
                        .frame(width: 18)
                        .foregroundColor(.dotYellow)
                        .offset(x: 2, y: -20)
                }
            }
        }
    }
}

struct DotThemeView_Previews: PreviewProvider {
    static var previews: some View {
        DotThemeView()
            .modifier(EntryBannerStyle(theme: .dot))
    }
}

struct RayThemeView: View {
    private var lineColor = ["ray-yellow","ray-peach","ray-orange","ray-mauve"]
    var body: some View {
        HStack {
            ZStack {
                ForEach(0..<lineColor.count,  id: \.self) { index in
                    AngledLine()
                        .rotation(Angle(degrees: 15))
                        .foregroundColor(Color(lineColor[index]))
                        .frame(width: 15, height: 150)
                        .offset(x: CGFloat(8*index-31))
                }
            }
            Spacer()
            ZStack {
                ForEach(0..<lineColor.count,  id: \.self) { index in
                    AngledLine()
                        .rotation(Angle(degrees: -15))
                        .foregroundColor(Color(lineColor[index]))
                        .frame(width: 15, height: 150)
                        .offset(x: CGFloat(8*index)+2)
                }
            }
        }
    }
}


struct AngledLine : Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}

struct RayThemeView_Previews: PreviewProvider {
    static var previews: some View {
        RayThemeView()
            .modifier(EntryBannerStyle(theme: .ray))
    }
}

struct WaveThemeView: View {
    var body: some View {
        HStack {
            Image("wave-orange")
                .resizable()
                .scaledToFill()
                .frame(width: 20)
                .offset(x: -10)
            Image("wave-peach")
                .resizable()
                .scaledToFill()
                .frame(width: 20)
                .offset(x: -28)
            Spacer()
            Image("wave-copper")
                .resizable()
                .scaledToFill()
                .frame(width: 20)
                .offset(x: 28)
            Image("wave-brown")
                .resizable()
                .scaledToFill()
                .frame(width: 20)
                .offset(x: 10)
        }
    }
}


struct WaveThemeView_Previews: PreviewProvider {
    static var previews: some View {
        WaveThemeView()
            .modifier(EntryBannerStyle(theme: .wave))
    }
}


struct YourTitleBannerView: View {
    var body: some View {
        HStack {
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 25)
                        .foregroundColor(.bannerBlue)
                    Circle()
                        .frame(width: 15)
                        .foregroundColor(.bannerYellow)
                        .offset(x: -10, y: -5)

                }
                ZStack {
                    Circle()
                        .frame(width: 30)
                        .foregroundColor(.bannerPink)
                        .offset(x: -5)
                }
            }
            Spacer()
            ZStack {
                 Circle()
                     .frame(width: 40)
                     .foregroundColor(.bannerBlue)
                     .offset(x: 5, y: -10)
                Circle()
                    .frame(width: 30)
                    .foregroundColor(.bannerPink)
                    .offset(x: 6, y: 5)

            }
        }
    }
}

struct YourTitleBannerView_Previews: PreviewProvider {
    static var previews: some View {
        TitleBannerPreview()
    }
}

#endif

