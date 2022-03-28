//
//  TransactionListViewModel.swift
//  ExpenseTracker_SwiftUI_Practice
//
//  Created by Kevin Kim on 2022/03/27.
//

import Foundation
import Combine
import Collections

typealias TransactionGroup      = OrderedDictionary<String, [Transaction]>
typealias TransactionPrefixSum  = [(String, Double)]

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
    
    func groupTransactionsByMonth() -> TransactionGroup {
        guard !transactions.isEmpty else { return [:] }
        
        let groupTransactions = TransactionGroup(grouping: transactions) { $0.month }
        
        return groupTransactions
    }
    
    func accumulateTransactions() -> TransactionPrefixSum {
        print("✅ accumulateTransactions")
        guard !transactions.isEmpty else { return [] }
        
        let today = "02/17/2022".dateParsed()  // Ideal: Date()
        let dateInterval = Calendar.current.dateInterval(of: .month, for: today)!
        print("✅ dateInterval: \(dateInterval)")
        
        var sum: Double = .zero
        var cumulativeSum = TransactionPrefixSum()
        
        for date in stride(from: dateInterval.start, to: today, by: 60 * 60 * 24) {
            let dailyExpense = transactions.filter { $0.dateParsed == date && $0.isExpense }
            let dailyTotal = dailyExpense.reduce(0) { $0 - $1.signedAmount }
            
            sum += dailyTotal
            sum = sum.roundedTo2Digits()
            cumulativeSum.append((date.formatted(), sum))
            
        }
        return cumulativeSum
    }
}
