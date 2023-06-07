//
//  Product.swift
//  AleloTeste
//
//  Created by Erick Sens on 06/06/23.
//

import Foundation

struct ProductArray: Decodable,Hashable {
    var products: [Product] = []
}

struct Product : Decodable, Hashable {
    
    let name, style, code_color, color_slug: String
        let color: String
        let on_sale: Bool
        let regular_price, actual_price, discount_percentage, installments: String
        let image: String
        let sizes: [Size]
    
}

struct Size: Identifiable, Decodable, Hashable {
    let id = UUID()
    let available: Bool
    let size: String
    let sku: String
}
class ProductViewModel: ObservableObject {
    @Published var productArray: ProductArray = ProductArray()
    @Published var showOnlyOnSale = false
    @Published var isLoading = false
    
    var filteredProducts: [Product] {
        if showOnlyOnSale {
            return productArray.products.filter { $0.on_sale }
        } else {
            return productArray.products
        }
    }
    
    func fetchProducts() { // Alterado o nome do método para fetchProducts()
        let apiclient = APIClient()
        isLoading = true
        apiclient.request(endpoint: "https://www.mocky.io/v2/59b6a65a0f0000e90471257d") { (result: Result<ProductArray, Error>) in
            switch result {
            case .success(let products):
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.productArray = products
                    self.isLoading = false
                }
                
            case .failure (let error):
                print(error)
            }
        }
    }
}
