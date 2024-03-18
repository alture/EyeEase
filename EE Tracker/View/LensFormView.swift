//
//  LensFormView.swift
//  EE Tracker
//
//  Created by Alisher on 07.12.2023.
//

import SwiftUI
import Combine
import SwiftData

struct LensFormView: View {
    @FocusState private var focusField: FocusableField?
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Bindable private var viewModel: LensFormViewModel
    private var lensItem: LensItem
    @State private var showingAlert = false
    @State private var defaultLensItem: LensItem?
    @State private var showingSphereSection: Bool = false
    @State private var sheetHeight: CGFloat = .zero
    private var didClose: (LensItem) -> Void
    
    init(
        lensItem: LensItem = LensItem(),
        status: LensFormViewModel.Status,
        _ didClose: @escaping (LensItem) -> Void
    ) {
        self.lensItem = lensItem
        self.viewModel = LensFormViewModel(lensItem: lensItem, status: status)
        self.didClose = didClose
    }
    
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
                    showingSphereSection: $showingSphereSection
                )
            }
            .navigationTitle("Edit")
            .navigationBarTitleDisplayMode(.inline)
            .defaultFocus($focusField, .bc)
            .onChange(of: showingSphereSection, { oldValue, newValue in
                if newValue {
                    self.focusField = nil
                }
            })
            .sheet(isPresented: $showingSphereSection, content: {
                SphereSection(sphere: self.viewModel.sphere) { sphere in
                    self.viewModel.sphere = sphere
                }
                .overlay {
                    GeometryReader { geometry in
                        Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
                    }
                }
                .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                    sheetHeight = newHeight
                }
                .presentationDetents([.height(sheetHeight)])
            })
            .toolbar {
                if focusField != .name {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Button("", systemImage: "chevron.up") {
                                self.focusField?.prev()
                            }
                            .disabled(self.focusField == .bc)
                            
                            Button("", systemImage: "chevron.down") {
                                self.focusField?.next()
                            }
                            .disabled(self.focusField == .axis)
                            
                            Spacer()
                            
                            Button("", systemImage: "keyboard.chevron.compact.down") {
                                self.focusField = nil
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.status.actionTitle) {
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
                            self.focusField = .name
                        }
                    }, message: {
                        Text("Please specify the contact lens brand for accurate tracking.")
                    })
                }
            }
            .defaultFocus($focusField, .name)
        }
    }
    
    private func save() {
        lensItem.name = viewModel.brandName
        lensItem.eyeSide = viewModel.eyeSide
        lensItem.wearDuration = viewModel.wearDuration
        lensItem.startDate = viewModel.initialUseDate
        lensItem.sphere = viewModel.sphere
        lensItem.isWearing = viewModel.isWearing
        lensItem.detail = viewModel.detail
        lensItem.changeDate = viewModel.changeDate
        
        didClose(lensItem)
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
            break
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
            break
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
        .frame(height: 180)
        .padding(.all, -8)
    }
}

struct MainSection: View {
    @FocusState var focusField: FocusableField?
    @Binding var brandName: String
    @Binding var wearDuration: WearDuration
    @Binding var eyeSide: EyeSide
    @Binding var initialUseDate: Date
    @Binding var isWearing: Bool
    
    var body: some View {
        Section {
            LabeledContent("Brand name") {
                TextField("Required", text: $brandName)
                    .autocorrectionDisabled(true)
                    .multilineTextAlignment(.trailing)
                    .focused($focusField, equals: .name)
                    .foregroundStyle(.teal)
                    .submitLabel(.done)
                    .textFieldStyle(.plain)
            }
            
            Picker("Usage Period", selection: $wearDuration) {
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
            
            DatePicker("Initial Use Date", selection: $initialUseDate, in: ...Date.now, displayedComponents: [.date])
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

struct SphereSection: View {
    @State private var sphere: Sphere = Sphere()
    @State private var lastChangedSide: EyeSide = .both
    @Environment(\.dismiss) private var dismiss
    private var completion: (Sphere?) -> Void
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text("Set Sphere")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                Spacer()
                Button(action: {
                    self.dismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                })
            }
            .padding(.bottom)
            HStack {
                VStack {
                    Text("Left Eye")
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
                if self.sphere.left == 0.0, self.sphere.isSame {
                    self.completion(nil)
                } else {
                    self.completion(self.sphere)
                }
                self.dismiss()
            }, label: {
                Text("Save")
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.teal)
                    .cornerRadius(10)
            })
            .padding(.bottom)
            
            Button("Reset") {
                withAnimation {
                    self.sphere.left = 0.0
                    self.sphere.right = 0.0
                }
                
                self.completion(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.red)
        }.padding()
    }
    
    init(sphere: Sphere? = nil, _ completion: @escaping (Sphere?) -> Void) {
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
    @Binding var showingSphereSection: Bool
    
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
                LabeledContent("Sphere(PWR)") {
                    Button(sphere != nil ? sphereDesc : "Set Sphere") {
                        self.showingSphereSection.toggle()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(Color.teal)
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

#Preview("New", body: {
    return LensFormView(lensItem: SampleData.content[1], status: .new) { _ in}
})

#Preview("Editable", body: {
    return LensFormView(lensItem: SampleData.content[2], status: .editable) { _ in}
})

#Preview("Changeable", body: {
    return LensFormView(lensItem: SampleData.content[3], status: .changeable) { _ in}
})

#Preview("Sphere Section", body: {
    return SphereSection() { _ in }
})

