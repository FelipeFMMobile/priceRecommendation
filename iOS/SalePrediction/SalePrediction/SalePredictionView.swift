//
//  SalePredictionView.swift
//  SalePrediction
//
//  Created by Felipe Menezes on 14/07/25.
//


import SwiftUI


struct SalePredictionView: View {
    enum Field {
        case currency
    }
    
    private struct SellerSelectionView: View {
        @Binding var selectedSeller: SellerObj
        @Environment(\.dismiss) private var dismiss
        private let source = DataSource.shared
        var body: some View {
            List(source.sellers, id: \.self) { seller in
                Group {
                    Button(seller.seller_id) {
                        selectedSeller = seller
                        dismiss()
                    }.foregroundColor(.blue)
                    Text(seller.payment_type)
                    Text(seller.seller_city)
                    Text("\(daysOfWeek[seller.dow])")
                    Text("Hora \(seller.hour)h")
                    Text("Price \(seller.price)")
                }
            }
            .listStyle(.plain)
            .navigationTitle("Select Seller")
        }
    }

    @FocusState private var focusedField: Field?
    @State private var currencyInput: String = ""
    @State private var selectedHour: Int = 11
    @State private var selectedDay: Int = 3
    @State private var selectedSeller: SellerObj = SellerObj.otherUser()
    @State private var selectedCity: String = "franca"
    @State private var selectedPayment: String = "boleto"
    
    @State private var selectedPredictionIndex: Int = 0
    
    private let hours = Array(0...23)
    
    @StateObject var salePredict = SalePrediction()
    
    @State var predictions: [Double] = [0.0, 0.0, 0.0]

    private let source = DataSource.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    
                    inputView()
                    .onAppear {
                        prediction()
                    }
                    
                    // Seller
                    NavigationLink {
                        selectionGroup()
                        .onChange(of: selectedSeller) { old, new in
                            selectedCity = new.seller_city
                            selectedPayment = new.payment_type
                            selectedDay = new.dow
                            selectedHour = new.hour
                        }
                    } label: {
                        Text("Change Seller")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    Divider()
                    
                    Text("Price recommendation based on the current seller parameters. The idea is that when the seller enters the input for the next sale value, we can recommend a price based on predictions from our ML-trained model.")
                        .font(.body)
                        .padding()
                    Text("The goal is just to help seller usability")
                        .font(.headline)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Sale Prediction")
        }
        .padding()
    }

    private func prediction() {
        do {
            let hour = selectedHour
            let day = selectedDay
            let seller = selectedSeller
            let city = selectedCity
            let payment = selectedPayment
            let result = try salePredict.predict(sellerId: seller.seller_id,
                                                 hour: hour,
                                                 dayOfWeek: day,
                                                 city: city,
                                                 payment: source.paymetTypes[payment] ?? 0)
            
            predictions = result
            currencyInput = "\(predictions.first ?? 0.0)"
        } catch {
            print(error.localizedDescription)
        }
    }

    @ViewBuilder
    func inputView() -> some View {
        Group {
            Text("Enter your selling price for the next sale:")
                .font(.callout)
            TextField("Price", text: $currencyInput)
                .font(.system(size: 28, weight: .bold, design: .default))
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .currency)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                }
            Text("Recommended Price for Pickup")
                .font(.subheadline)
            
            Picker("Select Prediction", selection: $selectedPredictionIndex) {
                ForEach(predictions.indices, id: \.self) { index in
                    Text(predictions[index], format: .currency(code: "USD"))
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedPredictionIndex) { old, new in
                let value = predictions[new]
                currencyInput = "\(value)"
            }
            
        }.padding(.bottom, 16.0)
    }

    @ViewBuilder
    func selectionGroup() -> some View {
        Group {
            // Seller
            NavigationLink(destination: SellerSelectionView(selectedSeller: $selectedSeller)) {
                HStack {
                    Text("Seller")
                    Spacer()
                    Text(selectedSeller.seller_id)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            // Day of week
            Menu {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                    Button(daysOfWeek[index]) {
                        selectedDay = index
                    }
                }
            } label: {
                HStack {
                    Text(daysOfWeek[selectedDay])
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Hour
            Menu {
                ForEach(hours, id: \.self) { index in
                    Button("\(index)h") {
                        selectedHour = index
                    }
                }
            } label: {
                HStack {
                    Text("\(selectedHour)h")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Payment
            Menu {
                ForEach(Array(source.paymetTypes.keys), id: \.self) { index in
                    Button("\(index)") {
                        selectedPayment = index
                    }
                }
            } label: {
                HStack {
                    Text(selectedPayment.isEmpty ? "Select payment type" : "\(selectedPayment)")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            Text("Here we can change the seller, payment type, and pickup option from the seller table and compare the results.")
                .font(.body)
                .padding()
        }
    }
}
