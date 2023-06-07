import XCTest
@testable import AleloTeste // Importe o nome do seu aplicativo ou módulo

class CartManagerTests: XCTestCase {
    var cartManager: CartManager!
    var testProduct: Product!
    var testSize: Size?
    
    override func setUp() {
        super.setUp()
        cartManager = CartManager()
        testProduct = Product(name: "Test Product", actual_price: "10.00")
        testSize = Size(size: "M", available: true)
    }
    
    func testAddToCart_AddsNewCartItem() {
        cartManager.addToCart(product: testProduct, size: testSize)
        
        XCTAssertEqual(cartManager.cartItems.count, 1)
        XCTAssertEqual(cartManager.cartItems[0].product.name, testProduct.name)
        XCTAssertEqual(cartManager.cartItems[0].size, testSize)
        XCTAssertEqual(cartManager.cartItems[0].quantity, 1)
    }
    
    func testAddToCart_IncrementsQuantityForExistingCartItem() {
        // Add an item to the cart
        cartManager.addToCart(product: testProduct, size: testSize)
        
        // Add the same item again
        cartManager.addToCart(product: testProduct, size: testSize)
        
        XCTAssertEqual(cartManager.cartItems.count, 1)
        XCTAssertEqual(cartManager.cartItems[0].product.name, testProduct.name)
        XCTAssertEqual(cartManager.cartItems[0].size, testSize)
        XCTAssertEqual(cartManager.cartItems[0].quantity, 2)
    }
    
    // Add more test cases as needed for other functions
    
    func testRemoveFromCart_RemovesCartItem() {
        // Add an item to the cart
        cartManager.addToCart(product: testProduct, size: testSize)
        
        // Remove the item from the cart
        cartManager.removeFromCart(cartItemId: cartManager.cartItems[0].id)
        
        XCTAssertEqual(cartManager.cartItems.count, 0)
    }
    
    func testUpdateQuantity_UpdatesCartItemQuantity() {
        // Add an item to the cart
        cartManager.addToCart(product: testProduct, size: testSize)
        
        // Update the quantity of the item
        cartManager.updateQuantity(product: testProduct, quantity: 5)
        
        XCTAssertEqual(cartManager.cartItems[0].quantity, 5)
    }
    
    // ...
}
