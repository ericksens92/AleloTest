//
//  ContentView.swift
//  AleloTeste
//
//  Created by Erick Sens on 06/06/23.
//

import SwiftUI
import SDWebImageSwiftUI

class CartManager: ObservableObject {
    @Published var cartItems: [CartItem] = []
    
    var totalPayment: String {
        let rawTotalPayment = cartItems.reduce(0.0) { result, cartItem in
            let cleanedPriceString = cartItem.product.regular_price
                .replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: ",", with: ".")
                .replacingOccurrences(of: "R$", with: "")
                .trimmingCharacters(in: .whitespaces)
            
            if let regularPrice = Double(cleanedPriceString) {
                return result + (regularPrice * Double(cartItem.quantity))
            } else {
                return result
            }
        }
        
        let formattedTotalPayment = String(format: "%.2f", rawTotalPayment)
        return formattedTotalPayment
    }
    
    func addToCart(product: Product, size: Size?) {
        if let existingItemIndex = cartItems.firstIndex(where: { $0.product == product && $0.size == size }) {
            cartItems[existingItemIndex].quantity += 1
        } else {
            let newItem = CartItem(product: product, size: size, quantity: 1)
            cartItems.append(newItem)
        }
    }
    
    func removeFromCart(cartItemId: UUID) {
        if let index = cartItems.firstIndex(where: { $0.id == cartItemId }) {
            cartItems.remove(at: index)
        }
    }
    
    func updateQuantity(product: Product, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.product.name == product.name }) {
            cartItems[index].quantity = quantity
        }
    }
}

struct ProductWithSize: Identifiable {
    let id = UUID()
    let product: Product
    let size: Size?
}

struct CartItem: Identifiable, Equatable {
    let id = UUID()
    let product: Product
    let size: Size?
    var quantity: Int
    
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        return lhs.product.name == rhs.product.name && lhs.size?.size == rhs.size?.size
    }
}

struct ProductListView: View {
    @EnvironmentObject var cartManager: CartManager
    @ObservedObject var viewModel: ProductViewModel
    @State private var showOnlyOnSale = false
    @State private var isShowingCartView = false
    @State private var selectedSize: Size? = nil
    
    var filteredProducts: [Product] {
        viewModel.productArray.products.filter { product in
            !showOnlyOnSale || product.on_sale
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle(isOn: $showOnlyOnSale) {
                    Text("Mostrar apenas em promoção")
                }
                .padding()
                
                List(filteredProducts, id: \.self) { product in
                    VStack(alignment: .leading) {
                        HStack {
                            WebImage(url: URL(string: product.image))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.name)
                                    .font(.headline)
                                Text("Preço: \(product.regular_price)")
                                    .foregroundColor(.gray)
                                
                                if product.on_sale {
                                    Text("com desconto")
                                        .foregroundColor(.green)
                                    
                                    if let salePrice = product.actual_price {
                                        Text("preço com desconto: \(salePrice)")
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                Text("Sizes")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Picker(selection: $selectedSize, label: Text("Sizes")) {
                                    ForEach(product.sizes.filter { $0.available }) { size in
                                        Text(size.size)
                                            .id(size.id)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                        
                        Button(action: {
                            cartManager.addToCart(product: product, size: selectedSize)
                            isShowingCartView = true
                        }) {
                            Text("Adicionar ao carrinho")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .sheet(isPresented: $isShowingCartView) {
                            CartView()
                        }
                        
                    }
                }
            }
            .navigationBarTitle("Lista de Produtos")
            
        }
    }
}

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(cartManager.cartItems) { cartItem in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(cartItem.product.name)
                                .font(.headline)
                            Spacer()
                            Text("Preço: \(cartItem.product.actual_price)")
                                .foregroundColor(.gray)
                        }
                        
                        Stepper("Quantidade: \(cartItem.quantity)", value: Binding(
                            get: { cartItem.quantity },
                            set: { newValue in
                                if let index = cartManager.cartItems.firstIndex(of: cartItem) {
                                    cartManager.cartItems[index].quantity = newValue
                                }
                            }
                        ), in: 1...10)
                        
                        
                    }
                }
                .onDelete(perform: removeCartItem)
                
                Section(header: Text("Total Payment")) {
                    Text("R$\(cartManager.totalPayment)")
                        .font(.headline)
                }
            }
            .navigationBarTitle("Cart")
        }
    }
    
    private func removeCartItem(at offsets: IndexSet) {
        for index in offsets {
            let cartItem = cartManager.cartItems[index]
            cartManager.removeFromCart(cartItemId: cartItem.id)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var cartManager: CartManager
    @ObservedObject var viewModel = ProductViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ProductListView(viewModel: viewModel)
                }
            }
            .navigationBarItems(trailing: NavigationLink(destination: CartView()) {
                Image(systemName: "cart")
            })
            .onAppear {
                viewModel.fetchProducts()
            }
        }
        .environmentObject(cartManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
