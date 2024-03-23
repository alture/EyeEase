//
//  LensFormView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI
import Combine
import SwiftData
import TipKit

struct LensFormView: View {
    @FocusState private var focusField: FocusableField?
    @Environment(\.dismiss) var dismiss
    @Environment(\.passStatus) private var passStatus
    @Environment(NavigationContext.self) private var navigationContext
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAlert = false
    @State private var showingSphereSection: Bool = false
    @State private var sheetHeight: CGFloat = .zero
    @State private var initialUseDate: Date = Date.now
    
    @State private var viewModel = LensFormViewModel()
    
    var state: FormState = .new
    var lensItem: LensItem?
    
    var body: some View {
        NavigationStack {
            Form {
                MainSection(
                    focusField: _focusField,
                    brandName: $viewModel.brandName,
                    wearDuration: $viewModel.wearDuration,
                    eyeSide: $viewModel.eyeSide,
                    initialUseDate: $viewModel.initialUseDate,
                    isWearing: $viewModel.isWearing
                )
                
                DetailSection(
                    detail: $viewModel.detail,
                    sphere: $viewModel.sphere,
                    focusField: _focusField,
                    showingSphereRow: $showingSphereSection
                )
            }
            .onAppear {
                let dateByStartOfDay = Date.now.startOfDay
                
                if state == .changeable {
                    self.viewModel.initialUseDate = dateByStartOfDay
                } else {
                    self.viewModel.initialUseDate = lensItem?.startDate ?? Date.now
                }
                
                self.viewModel.brandName = lensItem?.name ?? ""
                self.viewModel.eyeSide = lensItem?.eyeSide ?? .both
                self.viewModel.wearDuration = lensItem?.wearDuration ?? .biweekly
                self.viewModel.isWearing = lensItem?.isWearing ?? false
                self.viewModel.sphere = lensItem?.sphere
                self.viewModel.detail = lensItem?.detail ?? LensDetail()
            }
            .navigationTitle(state.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .defaultFocus($focusField, .name)
            .onChange(of: showingSphereSection, { oldValue, newValue in
                if newValue {
                    self.focusField = nil
                }
            })
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        if passStatus != .notSubscribed {
                            HStack {
                                Button(action: {
                                    self.focusField?.prev()
                                }, label: {
                                    Image(systemName: "chevron.up")
                                })
                                .disabled(self.focusField == .name)
                                
                                Button(action: {
                                    self.focusField?.next()
                                }, label: {
                                    Image(systemName: "chevron.down")
                                })
                                .disabled(self.focusField == .axis)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            self.focusField = nil
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(state.actionTitle) {
                        if viewModel.isNameValid {
                            self.save()
                            self.dismiss()
                        } else {
                            self.showingAlert.toggle()
                        }
                    }
                    .alert("Please enter the name", isPresented: $showingAlert, actions: {
                        Button("Ok", role: .cancel) {
                            self.showingAlert.toggle()
                        }
                    }, message: {
                        Text("Please specify the contact lens brand for accurate tracking.")
                    })
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        self.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    .foregroundStyle(.red)
                }
            }
            .defaultFocus($focusField, .name)
        }
        .tint(Color.teal)
    }
    
    private func save() {
        if let lensItem {
            lensItem.name = viewModel.brandName
            lensItem.eyeSide = viewModel.eyeSide
            lensItem.wearDuration = viewModel.wearDuration
            lensItem.startDate = viewModel.initialUseDate
            lensItem.sphere = viewModel.sphere
            lensItem.isWearing = viewModel.isWearing
            lensItem.detail = viewModel.detail
            lensItem.changeDate = viewModel.changeDate
            
            if passStatus != .notSubscribed {
                viewModel.createNotification(by: lensItem.id)
            }
        } else {
            let newLensItem = LensItem()
            newLensItem.name = viewModel.brandName
            newLensItem.eyeSide = viewModel.eyeSide
            newLensItem.startDate = viewModel.initialUseDate
            newLensItem.isWearing = viewModel.isWearing
            newLensItem.sphere = viewModel.sphere
            newLensItem.detail = viewModel.detail
            newLensItem.changeDate = viewModel.changeDate
            
            modelContext.insert(newLensItem)
            navigationContext.selectedLensItem = newLensItem
            
            if passStatus != .notSubscribed {
                viewModel.createNotification(by: newLensItem.id)
            }
        }
    }
}

enum FocusableField: Hashable {
    case name
    case bc
    case dia
    case cylinder
    case axis
    
    var unitDescription: String {
        switch self {
        case .bc, .dia:
            return "mm"
        case .cylinder:
            return "D"
        case .axis:
            return "°"
        case .name:
            return ""
        }
    }
    
    mutating func next() {
        switch self {
        case .name:
            self = .bc
        case .bc:
            self = .dia
        case .dia:
            self = .cylinder
        case .cylinder:
            self = .axis
        case .axis:
            break
        }
    }
    
    mutating func prev() {
        switch self {
        case .name:
            break
        case .bc:
            self = .name
        case .dia:
            self = .bc
        case .cylinder:
            self = .dia
        case .axis:
            self = .cylinder
        }
    }
}

struct PowerPicker: View {
    var diopterRange: [Float] = Array(stride(from: -12.0, through: 12.0, by: 0.25))
    @Binding var value: Float
    var body: some View {
        Picker("Power", selection: $value) {
            ForEach(diopterRange, id: \.self) { value in
                Text("\(value > 0 ? "+" : "")\(String(format: "%.2f", value))")
            }
        }
        .pickerStyle(WheelPickerStyle())
        .frame(height: 160)
        .padding(.all, -16)
    }
}

struct MainSection: View {
    @FocusState var focusField: FocusableField?
    @Binding var brandName: String
    @Binding var wearDuration: WearDuration
    @Binding var eyeSide: EyeSide
    @Binding var initialUseDate: Date
    @Binding var isWearing: Bool
    var brandNameTip = BrandNameTip()
    var initialDateTip = InitialDateTip()
    
    var body: some View {
        Section {
            LabeledContent("Brand name") {
                TextField("Required", text: $brandName, onEditingChanged: { editingChanged in
                    print("Editing Changed: \(editingChanged)")
                    // TODO: - Configure Tips
                })
                .autocorrectionDisabled(true)
                .multilineTextAlignment(.trailing)
                .focused($focusField, equals: .name)
                .foregroundStyle(.teal)
                .submitLabel(.done)
                .textFieldStyle(.plain)
            }
            // TODO: - Show brandNameTip
            
            Picker("Wearing Type", selection: $wearDuration) {
                ForEach(WearDuration.allCases.filter {
                    $0 != .daily && $0 != .yearly
                }) { duration in
                    Text(duration.description)
                        .tag(duration)
                }
            }
            
            Picker("For Which Eye(s)?", selection: $eyeSide) {
                ForEach(EyeSide.allCases) { side in
                    Text(side.rawValue)
                        .tag(side)
                }
            }
            
            DatePicker("Date first used", selection: $initialUseDate, in: ...Date.now, displayedComponents: [.date])
            // TODO: - Show InitialDateTip
        } header: {
            HStack {
                Image(systemName: "circle.dashed")
                Text("Main")
            }
        } footer: {
            Text("Lens tracking starts automatically from the selected date")
        }
    }
}

struct SphereRowView: View {
    @State private var sphere: Sphere = Sphere()
    @State private var lastChangedSide: EyeSide = .both
    @Binding var showing: Bool
    private var completion: (Sphere?) -> Void

    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Left Eye")
                        .font(.headline)
                        .bold()
                    Divider()
                    PowerPicker(value: $sphere.left)
                        .onChange(of: sphere.left, { oldValue, newValue in
                            if sphere.proportional, newValue != sphere.right {
                                lastChangedSide = .both
                                withAnimation {
                                    sphere.right = newValue
                                }
                            } else {
                                lastChangedSide = .left
                            }
                        })
                }
                
                Button(action: {
                    withAnimation {
                        self.sphere.proportional.toggle()
                        
                        if self.sphere.proportional {
                            switch lastChangedSide {
                            case .left:
                                sphere.right = sphere.left
                            case .right, .both:
                                sphere.left = sphere.right
                            }
                        }
                    }
                }) {
                    Image(systemName: sphere.proportional ? "link.circle.fill" : "link.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(sphere.proportional ? .teal : .gray)
                }
                .buttonStyle(.plain)
                .padding()
                .padding(.top, 44)
                
                VStack {
                    Text("Right Eye")
                        .font(.headline)
                        .bold()
                    Divider()
                    PowerPicker(value: $sphere.right)
                        .onChange(of: sphere.right) { oldValue, newValue in
                            if sphere.proportional, newValue != sphere.left {
                                lastChangedSide = .both
                                withAnimation {
                                    sphere.left = newValue
                                }
                            } else {
                                lastChangedSide = .right
                            }
                        }
                }
            }
            
            Button(action: {
                self.completion(self.sphere)
                self.showing = false
            }, label: {
                Text("Save")
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(8)
            })
            .buttonStyle(.borderedProminent)
        }
    }
    
    init(sphere: Sphere? = nil, showing: Binding<Bool>, _ completion: @escaping (Sphere?) -> Void) {
        self._showing = showing
        self.completion = completion
        self.sphere.left = sphere?.left ?? 0.0
        self.sphere.right = sphere?.right ?? 0.0
        self.sphere.proportional = sphere?.proportional ?? false
    }
}

struct DetailSection: View {
    @Binding var detail: LensDetail
    @Binding var sphere: Sphere?
    @FocusState var focusField: FocusableField?
    @Environment(\.passStatus) private var passStatus
    @State private var presentingPassSheet: Bool = false
    @Binding var showingSphereRow: Bool
    
    private var sphereDesc: String {
        guard let sphere else { return "" }
        if sphere.isSame {
            return "Both: \(sphere.left)"
        } else {
            return "Left: \(sphere.left) | Right: \(sphere.right)"
        }
    }
    
    var body: some View {
        Section {
            Group {
                LabeledContent("Power Range(PWR)") {
                    Button(action: {
                        self.showingSphereRow.toggle()
                    }, label: {
                        Group {
                            if showingSphereRow {
                               Text("Dismiss")
                            } else if sphere == nil {
                                Text("Set Sphere")
                            } else {
                                Text(sphereDesc)
                            }
                        }
                    })
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(showingSphereRow ? .red : .teal)
                    .animation(.easeInOut(duration: 0.2), value: showingSphereRow)
                }
                
                if showingSphereRow {
                    SphereRowView(sphere: sphere, showing: $showingSphereRow) { sphere in
                        self.sphere = sphere
                    }
                    .animation(.default, value: showingSphereRow)
                }
                
                DetailRow(
                    name: "Base Curve(BC)",
                    predication: "8.0 - 9.5",
                    value: $detail.baseCurve,
                    focusField: _focusField,
                    focusValue: .bc
                )
                DetailRow(
                    name: "Diameter(DIA)",
                    predication: "13.0 - 14.5",
                    value: $detail.dia,
                    focusField: _focusField,
                    focusValue: .dia
                )
                DetailRow(
                    name: "Cylinder (CYL)",
                    predication: "-0.75 to -2.75",
                    value: $detail.cylinder,
                    focusField: _focusField,
                    focusValue: .cylinder
                )
                DetailRow(
                    name: "Axis Orientation",
                    predication: "0 - 180",
                    value: $detail.axis,
                    focusField: _focusField,
                    focusValue: .axis
                )
            }
            .availableOnPlus()
        } header: {
            HStack(alignment: .bottom) {
                Image(systemName: "slider.horizontal.3")
                Text("Details")
                
                Spacer()
                
                if passStatus == .notSubscribed {
                    GetPlusButton(didTap: $presentingPassSheet)
                }
            }
        }
        .sheet(isPresented: $presentingPassSheet, content: {
            SubscriptionShopView()
        })
    }
}


struct DetailRow: View {
    var name: String
    var predication: String
    @Binding var value: String
    @FocusState var focusField: FocusableField?
    var focusValue: FocusableField
    var body: some View {
        LabeledContent(name) {
            HStack(spacing: 4) {
                TextField(predication, text: $value)
                    .focused($focusField, equals: focusValue)
                    .keyboardType(.decimalPad)
                    .autocorrectionDisabled(true)
                    .multilineTextAlignment(.trailing)
                    .fixedSize()
                    .onReceive([value].publisher.first()) { currentValue in
                        if focusValue == .cylinder {
                            if currentValue == "-" || currentValue.isEmpty {
                                value = ""
                            } else if !currentValue.hasPrefix("-") {
                                value = "-\(currentValue)"
                            }
                        }
                    }
                
                Text(focusValue.unitDescription)
                    .foregroundStyle(Color(.systemGray))
            }
        }
    }
}

//#Preview("Pro", body: {
//    return LensFormView(lensItem: SampleData.content[1], status: .new) { _ in }
//        .environment(\.passStatus, .yearly)
//})
//
//#Preview("Base", body: {
//    return LensFormView(lensItem: SampleData.content[1], status: .new) { _ in }
//})
//
