//
//  ExchangeListViewModel.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Combine
import Foundation

// MARK: - ExchangeListViewModel

@MainActor
final class ExchangeListViewModel: ExchangeListViewModelProtocol {
    @Published private(set) var state: ExchangeListState

    private let reducer: ExchangeListReducer
    private let getExchangeRatesUseCase: GetExchangeRatesUseCase
    private let getAvailableCurrenciesUseCase: GetAvailableCurrenciesUseCase

    private var effectTasks: [EffectTaskKind: Task<Void, Never>] = [:]

    init(
        initialState: ExchangeListState = .initial(),
        reducer: ExchangeListReducer = ExchangeListReducer(),
        getExchangeRatesUseCase: GetExchangeRatesUseCase,
        getAvailableCurrenciesUseCase: GetAvailableCurrenciesUseCase
    ) {
        self.state = initialState
        self.reducer = reducer
        self.getExchangeRatesUseCase = getExchangeRatesUseCase
        self.getAvailableCurrenciesUseCase = getAvailableCurrenciesUseCase
    }

    deinit {
        effectTasks.values.forEach { $0.cancel() }
    }

    func onTrigger(_ trigger: ExchangeListTrigger) {
        switch trigger {
        case .screenAppeared:
            send(.startLoad)
            start(effect: .fetchCurrencies)

        case let .topAmountChanged(value):
            send(.setTopInput(value))

        case let .bottomAmountChanged(value):
            send(.setBottomInput(value))

        case .swapTapped:
            send(.performSwap)

        case .currencyTapped:
            send(.openPicker)

        case let .currencySelected(code):
            send(.applyCurrency(code))

        case .currencyPickerDismissed:
            send(.closePicker)

        case .retryTapped:
            send(.retry)

        case .dismissError:
            send(.clearError)
        }
    }

    func send(_ action: ExchangeListAction) {
        let output = reducer.reduce(state: state, action: action)
        state = output.state

        if let effect = output.effect {
            start(effect: effect)
        }
    }

    func run(_ effect: ExchangeListEffect) async {
        switch effect {
        case let .fetchRates(currencies):
            do {
                let rates = try await getExchangeRatesUseCase.execute(currencies: currencies)
                guard Task.isCancelled == false else { return }
                send(.ratesLoaded(.success(rates)))
            } catch is CancellationError {
                return
            } catch {
                guard Task.isCancelled == false else { return }
                send(.ratesLoaded(.failure(error)))
            }

        case .fetchCurrencies:
            let currencies = await getAvailableCurrenciesUseCase.execute()
            guard Task.isCancelled == false else { return }
            send(.currenciesLoaded(currencies))
        }
    }
}

// MARK: - Effect Execution

private extension ExchangeListViewModel {
    enum EffectTaskKind: Hashable {
        case rates
        case currencies
    }

    func start(effect: ExchangeListEffect) {
        let kind = taskKind(for: effect)
        effectTasks[kind]?.cancel()
        effectTasks[kind] = Task { [weak self] in
            guard let self else { return }
            await self.run(effect)
            await self.clearTask(for: kind)
        }
    }

    func taskKind(for effect: ExchangeListEffect) -> EffectTaskKind {
        switch effect {
        case .fetchRates:
            .rates
        case .fetchCurrencies:
            .currencies
        }
    }

    func clearTask(for kind: EffectTaskKind) {
        effectTasks[kind] = nil
    }
}
