//
//  LensDetailView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI

struct LensDetailView: View {
    @ObservedObject var lensItem: LensItem
    @State var isOptionalSectionShowing: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                switch lensItem.wearDuration {
                case .daily:
                    HStack(alignment: .firstTextBaseline, spacing: 20) {
                        VStack(spacing: 4) {
                            Button(action: {
                                withAnimation {
                                    self.lensItem.decreaseQuantity(for: lensItem)
                                }
                                
                                UIImpactFeedbackGenerator().impactOccurred()
                            }, label: {
                                Image(systemName: "minus.circle")
                                    .font(.largeTitle)
                            })
                            .customDisabled(!(lensItem.usedNumber > 0))
                            
                            Text("Undo")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        
                        ZStack {
                            Text(lensItem.limitDesciption)
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(Color(.systemGray2))
                            CircleProgressView(lensItem: lensItem,
                                               lineWidth: 8.0
                            )
                            .frame(width: 120, height: 120)
                        }
                        VStack(spacing: 4) {
                            Button(action: {
                                withAnimation {
                                    self.lensItem.increaseQuantity(for: lensItem)
                                }
                                UIImpactFeedbackGenerator().impactOccurred()
                            }, label: {
                                Image(systemName: "plus.circle")
                                    .font(.largeTitle)
                            })
                            .customDisabled(lensItem.usedNumber >= lensItem.totalNumber)
                            
                            Text("Pick-up")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                default:
                    ZStack {
                        Text(lensItem.limitDesciption)
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(Color(.systemGray2))
                        CircleProgressView(lensItem: lensItem,
                                           lineWidth: 8.0
                        )
                        .frame(width: 120, height: 120)
                    }
                }
            }
            .padding()
            List {
                Section {
                    LensDetailRow(title: "Name", value: lensItem.name)
                    LensDetailRow(title: "Power", value: "\(lensItem.diopter)")
                    LensDetailRow(title: "Eye Side", value: lensItem.eyeSide.rawValue)
                    LensDetailRow(title: "Wear Duration", value: lensItem.wearDuration.rawValue)
                    LensDetailRow(title: "Start Date", value: formattedDate(lensItem.startDate))
                }
                
                Section(isExpanded: $isOptionalSectionShowing) {
                    //                    ColorPicker(selection: $lensItem.color, label: {
                    //                        Text("Color")
                    //                            .font(.headline)
                    //                            .foregroundColor(.secondary)
                    //                            .padding(.vertical, 10)
                    //                    })
                    
                    if let cylinder = lensItem.cylinder {
                        LensDetailRow(title: "Cylinder", value: "\(cylinder)")
                    }
                    
                    if let axis = lensItem.axis {
                        LensDetailRow(title: "Axis", value: "\(axis)")
                    }
                } header: {
                    Text("Other Information")
                }
            }
            .scrollIndicators(.hidden)
            .listStyle(.sidebar)
            .scrollBounceBehavior(.basedOnSize)
        }
        
        
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct LensDetailRow: View {
    var title: String
    var value: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let value {
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct DisabledButtonStyle: ButtonStyle {
    var disabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(disabled ? Color(.systemGray5) : Color.teal)
    }
}

struct DisabledModifier: ViewModifier {
    var disabled: Bool
    
    func body(content: Content) -> some View {
        content.buttonStyle(DisabledButtonStyle(disabled: disabled))
    }
}

extension Button {
    func customDisabled(_ disabled: Bool) -> some View {
        self.modifier(DisabledModifier(disabled: disabled))
            .disabled(disabled)
    }
}

#Preview {
    LensDetailView(lensItem: LensItem(
        name: "Preview Name",
        eyeSide: .paired,
        wearDuration: .daily,
        startDate: Date(),
        totalNumber: 30,
        usedNumber: 0,
        resolvedColor: .fromColor(.red),
        diopter: 0)
    )
}
