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
    @Binding private var lensItem: LensItem?
    @State private var showingAlert = false
    @State private var showingNameForm: Bool = false
    @State private var sheetHeight: CGFloat = .zero
    
    init(lensItem: Binding<LensItem?> = .constant(nil), status: LensFormViewModel.Status) {
        self._lensItem = lensItem
        self.viewModel = LensFormViewModel(lensItem: lensItem.wrappedValue, status: status)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    MainSection(
                        focusField: _focusField,
                        brandName: $viewModel.brandName,
                        wearDuration: $viewModel.wearDuration,
                        eyeSide: $viewModel.eyeSide,
                        initialUseDate: $viewModel.initialUseDate,
                        isWearing: $viewModel.isWearing,
                        showingNameForm: $showingNameForm
                    )
                    SphereSection(sphere: $viewModel.sphere)
                    DetailSection(detail: $viewModel.detail, focusField: _focusField)
                }
                .navigationTitle(viewModel.lensItem?.name ?? "New Lense")
                .navigationBarTitleDisplayMode(.inline)
                .defaultFocus($focusField, .bc)
                .toolbar {
                    if !showingNameForm {
                        ToolbarItem(placement: .keyboard) {
                            HStack {
                                Spacer()
                                Button {
                                    focusField = nil
                                } label: {
                                    Text("Done")
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
                                self.showingNameForm.toggle()
                            }
                        }, message: {
                            Text("Please specify the contact lens brand for accurate tracking.")
                        })
                    }
                }
                
                if showingNameForm {
                    BlankView(bgColor: .black)
                        .opacity(0.2)
                        .onTapGesture {
                            withAnimation {
                                self.showingNameForm = false
                            }
                        }
                    
                    LensNameFormView(isShow: $showingNameForm, name: $viewModel.brandName)
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
                }
            }
            .animation(.interpolatingSpring(stiffness: 200.0, damping: 25.0, initialVelocity: 10.0), value: showingNameForm)
        }
    }
    
    private func save() {
        if lensItem != nil {
            lensItem?.name = viewModel.brandName
            lensItem?.eyeSide = viewModel.eyeSide
            lensItem?.wearDuration = viewModel.wearDuration
            lensItem?.startDate = viewModel.initialUseDate
            lensItem?.sphere = viewModel.sphere
            lensItem?.isWearing = viewModel.isWearing
            lensItem?.detail = viewModel.detail
            lensItem?.changeDate = viewModel.changeDate
            
            viewModel.createNotification(by: lensItem)
        } else {
            let newLensItem = LensItem(
                name: viewModel.brandName,
                eyeSide: viewModel.eyeSide,
                wearDuration: viewModel.wearDuration,
                startDate: viewModel.initialUseDate,
                sphere: viewModel.sphere,
                isWearing: viewModel.isWearing,
                detail: viewModel.detail
            )
            
            modelContext.insert(newLensItem)
            viewModel.createNotification(by: newLensItem)
        }
    }
}

enum FocusableField:  Hashable {
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
        .frame(height: 100)
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
    @Binding var showingNameForm: Bool
    
    var body: some View {
        Section {
            LabeledContent("Name") {
                Button(brandName.isEmpty ? "Set Name" : brandName) {
                    self.showingNameForm.toggle()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(Color.teal)
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
    @Binding var sphere: Sphere
    @State private var lastChangedSide: EyeSide = .both
    
    var body: some View {
        Section {
            HStack {
                VStack {
                    Text("Left")
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
                    Text("Right")
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
        } header: {
            HStack {
                Image(systemName: "eyes")
                Text("Sphere")
            }
        }
    }
}

struct DetailSection: View {
    @Binding var detail: LensDetail
    @FocusState var focusField: FocusableField?
    
    var body: some View {
        Section {
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
        } header: {
             HStack {
                 Image(systemName: "slider.horizontal.3")
                 Text("Details (Optional)")
             }
         }
    }
}

struct DetailRow: View {
    var name: String
    var predication: String
    @Binding var value: String
    @FocusState var focusField: FocusableField?
    var focusValue: FocusableField
    var body: some View {
        HStack {
            Text(name)
            Spacer()
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
    return LensFormView(lensItem: .constant(nil), status: .new)
})

#Preview("Editable", body: {
    return LensFormView(lensItem: .constant(SampleData.content[0]), status: .editable)
})

#Preview("Changeable", body: {
    return LensFormView(lensItem: .constant(SampleData.content[1]), status: .changeable)
})

