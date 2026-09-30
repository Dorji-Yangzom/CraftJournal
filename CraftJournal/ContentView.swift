import SwiftUI
import CoreData
import UIKit

enum SortOption: String, CaseIterable {
    case newest = "Newest First"
    case oldest = "Oldest First"
    case alphabetical = "A–Z"
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \CraftEntry.date,
                ascending: false
            )
        ],
        animation: .default
    )
    private var entries: FetchedResults<CraftEntry>

    @State private var showingAddEntry = false
    @State private var searchText = ""
    @State private var sortOption: SortOption = .newest

    var filteredAndSortedEntries: [CraftEntry] {
        let filtered = entries.filter { entry in
            searchText.isEmpty ||
            (entry.title ?? "")
                .localizedCaseInsensitiveContains(searchText)
        }

        switch sortOption {
        case .newest:
            return filtered.sorted {
                ($0.date ?? Date.distantPast) >
                ($1.date ?? Date.distantPast)
            }

        case .oldest:
            return filtered.sorted {
                ($0.date ?? Date.distantPast) <
                ($1.date ?? Date.distantPast)
            }

        case .alphabetical:
            return filtered.sorted {
                ($0.title ?? "")
                    .localizedCaseInsensitiveCompare(
                        $1.title ?? ""
                    ) == .orderedAscending
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Journal Entries",
                        systemImage: "book.closed",
                        description: Text(
                            "Tap + to add your first craft entry."
                        )
                    )
                } else {
                    List {
                        ForEach(filteredAndSortedEntries) { entry in
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                EntryRow(entry: entry)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Craft Journal")

            .searchable(
                text: $searchText,
                prompt: "Search by title"
            )

            .safeAreaInset(edge: .top) {
                Text("\(entries.count) entries")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(option.rawValue) {
                                sortOption = option
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }

            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
                    .environment(
                        \.managedObjectContext,
                        viewContext
                    )
            }
        }
    }
}

struct EntryRow: View {
    @ObservedObject var entry: CraftEntry

    var body: some View {
        HStack {
            if let data = entry.photo,
               let uiImage = UIImage(data: data) {

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 8)
                    )

            } else {
                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading) {
                Text(entry.title ?? "Untitled")
                    .font(.headline)

                Text(entry.craftType ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let location = entry.location,
                   !location.isEmpty {

                    Text("Location: \(location)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
