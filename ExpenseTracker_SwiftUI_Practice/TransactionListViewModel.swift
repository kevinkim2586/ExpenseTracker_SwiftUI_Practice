//
//  TransactionListViewModel.swift
//  ExpenseTracker_SwiftUI_Practice
//
//  Created by Kevin Kim on 2022/03/27.
//

import Foundation
import Combine

final class TransactionListViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var transactions: [Transaction] = []
    
    init() {
        getTransactions()
    }
    
    func getTransactions() {
        
        guard let url = URL(string: "https://designcode.io/data/transactions.json") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    dump(response)
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [Transaction].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    
                case .finished:
                    print("✅ Finished Fetching Transactions")
                case .failure(let error):
                    print("❗️ Error Fetching Transactions: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] result in
                self?.transactions = result
            }
            .store(in: &cancellables)

    }
}
