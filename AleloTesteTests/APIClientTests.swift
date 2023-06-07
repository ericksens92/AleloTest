//
//  APIClientTests.swift
//  AleloTesteTests
//
//  Created by Erick Sens on 07/06/23.
//

import XCTest
@testable import AleloTeste

class APIClientTests: XCTestCase {
    var apiClient: APIClient!
    
    override func setUp() {
        super.setUp()
        apiClient = APIClient()
    }
    
    func testRequest_SuccessfulResponse() {
        // Criar uma expectativa para aguardar a conclusão da chamada da API
        let expectation = self.expectation(description: "API Request")
        
        // Definir uma estrutura de exemplo para decodificar a resposta da API
        struct ExampleResponse: Decodable {
            let code: Int
            let type: String
            let message: String
        }
        
        
        apiClient.request(endpoint: "https://www.mocky.io/v2/59b6a65a0f0000e90471257d", completion: { (result: Result<ExampleResponse, Error>) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.code, 200) // Verificar se o código de resposta é 200 (OK)
                XCTAssertEqual(response.type, "success") // Verificar se o tipo de resposta é "success"
                XCTAssertEqual(response.message, "Request successful") // Verificar se a mensagem é "Request successful"
                expectation.fulfill() // Cumprir a expectativa
            case .failure(let error):
                XCTFail("API request failed with error: \(error)") // Falha no teste se houver um erro na chamada da API
            }
        })
        
        // Aguardar a expectativa ser cumprida por um tempo limite
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRequest_InvalidURL() {
        // Criar uma expectativa para aguardar a conclusão da chamada da API
        let expectation = self.expectation(description: "API Request")
        
        // Fazer uma chamada de API com uma URL inválida
        apiClient.request(endpoint: "invalid-url", completion: { (result: Result<ExampleResponse, Error>) in
            switch result {
            case .success:
                XCTFail("API request should have failed with an invalid URL") // Falha no teste se a chamada da API tiver sucesso com uma URL inválida
            case .failure(let error):
                XCTAssertEqual(error as? APIError, .invalidUrl) // Verificar se o erro retornado é .invalidUrl
                expectation.fulfill() // Cumprir a expectativa
            }
        })
        
        // Aguardar a expectativa ser cumprida por um tempo limite
        waitForExpectations(timeout: 5, handler: nil)
    }
}
