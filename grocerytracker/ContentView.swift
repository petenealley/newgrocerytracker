//
//  ContentView.swift
//  grocerytracker
//
//  Created by Pete Nealley on 3/10/25.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TransactionListView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
            AddTransactionView()
                .tabItem {
                    Label("Add", systemImage: "plus")
                }
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
