//
//  ExchangeListViewModelProtocol.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeListViewModelProtocol

@MainActor
protocol ExchangeListViewModelProtocol: ReducingStoreProtocol where State == ExchangeListState, Trigger == ExchangeListTrigger, Action == ExchangeListAction, Effect == ExchangeListEffect {}
