//
//  LensHistoryView.swift
//  EE Tracker
//
//  Created by Alisher Altore on 30.04.2024.
//

import SwiftUI

struct FilterView: View {
    @Binding var originalLensType: LensType
    @Binding var originalLensStatus: LensStatus
    
    @State private var selectedLensType: LensType
    @State private var selectedLensStatus: LensStatus
    @Environment(\.dismiss) var dismiss
    
    init(
        originalLensType: Binding<LensType>,
        originalLensStatus: Binding<LensStatus>
    ) {
        self._originalLensType = originalLensType
        self._originalLensStatus = originalLensStatus
        
        self._selectedLensType = State(initialValue: originalLensType.wrappedValue)
        self._selectedLensStatus = State(initialValue: originalLensStatus.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(selection: $selectedLensType) {
                        ForEach(LensType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    } label: {
                        Text("Lens Type:")
                    }
                    
                    Picker(selection: $selectedLensStatus) {
                        ForEach(LensStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    } label: {
                        Text("Lens Status:")
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.originalLensType = self.selectedLensType
                            self.originalLensStatus = self.selectedLensStatus
                            self.dismiss()
                        }, label: {
                            Text("Apply")
                        })
                        Spacer()
                    }
                }
            }
            .scrollDisabled(true)
            .navigationTitle("Filter")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        self.dismiss()
                    }, label: {
                        Image(systemName: "x.circle.fill")
                    })
                    .foregroundStyle(Color(.systemGray4))
                }
                
                if selectedLensType != .all || selectedLensStatus != .all {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Clear") {
                            selectedLensType = .all
                            selectedLensStatus = .all
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}

struct HistoryListView: View {
    @Binding var lensType: LensType
    @Binding var lensStatus: LensStatus
    let allLensUsages: [LensUsage] = [
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -35, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -60, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -70, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -80, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -120, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -160, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -35, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -60, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -70, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -80, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -120, to: Date())!, endDate: Date()),
        LensUsage(type: .biWeekly, status: .current, startDate: Calendar.current.date(byAdding: .day, value: -160, to: Date())!, endDate: Date()),
      
    ]
    
    var filteredLensUsages: [LensUsage] {
        allLensUsages.filter { usage in
            (lensType == .all || usage.type == lensType) &&
            (lensStatus == .all || usage.status == lensStatus)
        }
    }
    
    var groupedData: [Date: [LensUsage]] {
        filteredLensUsages.groupedBy([.year, .month])
    }
    
    var body: some View {
        if filteredLensUsages.isEmpty {
            ContentUnavailableView("No Data Available", systemImage: "exclamationmark.circle", description: nil)
        } else {
            List {
                ForEach(Array(groupedData.keys.sorted()), id: \.self) { key in
                    Section(header: Text(key.startOfDay.formattedDate(with: "MMMM YYYY"))) {
                        ForEach(groupedData[key] ?? []) { usage in
                            Text("\(usage.type.rawValue) lens")
                        }
                    }
                }
            }
        }
    }
}

struct HistoryRowView: View {
    var body: some View {
        Text("Row")
    }
}

struct LensHistoryView: View {
    @State var selectedLensType: LensType = .all
    @State var selectedLensStatus: LensStatus = .all
    @State private var showFilter: Bool = false
    
    var filterAppend: Bool {
        selectedLensType != .all || selectedLensStatus != .all
    }
    
    var body: some View {
        NavigationStack {
            HistoryListView(lensType: $selectedLensType, lensStatus: $selectedLensStatus)
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            self.showFilter.toggle()
                        }, label: {
                            Image(systemName: "slider.vertical.3")
                        })
                    }
                }
                .navigationTitle("Usage History")
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showFilter, content: {
            FilterView(
                originalLensType: $selectedLensType,
                originalLensStatus: $selectedLensStatus
            )
            .presentationDetents([.height(250)] )
            .presentationDragIndicator(.hidden)
        })
        .tint(Color.teal)
    }
}

#Preview("Filter View") {
    FilterView(originalLensType: .constant(.all), originalLensStatus: .constant(.all))
}

#Preview {
    LensHistoryView()
}
