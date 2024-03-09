//
//  LensNameFormView.swift
//  EE Tracker
//
//  Created by Alisher Altore on 06.03.2024.
//

import SwiftUI

struct LensNameFormView: View {
    enum FocusedField {
        case name
    }
    
    @Binding var isShow: Bool
    
    @Binding var name: String
    @State private var formValue: String = ""
    @State private var isEmpty: Bool = false
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                HStack {
                    Text("Enter the name")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    Button(action: {
                        self.closeForm()
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.teal)
                            .font(.headline)
                    })
                    
                }
                
                TextField("Brand, color etc.", text: $formValue, onEditingChanged: { editingChanged in
                    self.isEditing = editingChanged
                })
                .submitLabel(.return)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8.0)
                .overlay {
                    if isEmpty {
                        withAnimation {
                            RoundedRectangle(cornerRadius: 8.0)
                                .stroke(.red, style: .init(lineWidth: 1.0))
                                .transition(.opacity)
                        }
                    }
                }
                .onChange(of: formValue, { _, _ in
                    isEmpty = false
                })
                .padding(.bottom)
                
                Button(action: {
                    guard self.formValue.trimmingCharacters(in: .whitespaces) != "" else {
                        isEmpty = true
                        return
                    }
                    
                    self.name = formValue
                    self.closeForm()
                }, label: {
                    Text("Done")
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.teal)
                        .cornerRadius(10)
                })
                .padding(.bottom)
                
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10, antialiased: true)
            .padding(.bottom, isEditing ? 320 : 0)
            .animation(.easeInOut(duration: 0.2), value: isEditing)
        }
        .onAppear {
            self.formValue = self.name
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func closeForm() {
        self.isEditing = false
        self.isShow = false
    }

}

#Preview {
    LensNameFormView(isShow: .constant(false), name: .constant(""))
}
