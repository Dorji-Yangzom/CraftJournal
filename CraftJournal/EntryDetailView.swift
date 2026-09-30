import SwiftUI
import UIKit

struct EntryDetailView: View {
    @ObservedObject var entry: CraftEntry
    @State private var showingEdit = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                if let data = entry.photo,
                   let uiImage = UIImage(data: data) {

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }

                Text(entry.title ?? "Untitled")
                    .font(.largeTitle)
                    .bold()

                Text(entry.craftType ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                if let date = entry.date {
                    Text(date, style: .date)
                }

                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.body)
                }
                
                if let location = entry.location, !location.isEmpty {
                    Text("Location: \(location)")
                        .font(.body)
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditEntryView(entry: entry)
                .environment(\.managedObjectContext, entry.managedObjectContext!)
        }
    }
}
