# Exchange iOS

A native SwiftUI currency exchange calculator that converts between USDc and fiat currencies using live rates from the DolarApp API, with offline-capable fallback.

## Features

- Two-way conversion between USDc and a selected fiat currency — edit either field and the other updates automatically.
- Currency picker presented as a bottom sheet for the non-USDc side.
- Swap button to flip the two currencies in place.
- Live rates with automatic fallback to cached rates when offline.
- Realtime vs. stale indicator with a relative "last updated" timestamp.
- Locale-aware number input and formatting (comma and dot decimal separators).

## Requirements

- iOS 17.0+
- Xcode 16+
- Swift 5.9+
- No third-party dependencies.

## Getting Started

```bash
git clone https://github.com/sadeghmeratnia/exchange-ios
cd exchange-ios
open Exchange.xcodeproj
```

1. Select the **Exchange** scheme.
2. Pick any iOS Simulator.
3. **Cmd + R** to run.

No package resolution or signing changes required.

### Running Tests

Xcode: **Cmd + U**

Command line:

```bash
xcodebuild -project "Exchange.xcodeproj" \
  -scheme "Exchange" \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro" \
  -only-testing:"ExchangeTests" test
```

## Architecture

The project follows a feature-first Clean Architecture layout:

```
Exchange/
├── Core/                  Networking, DI, presentation contracts, utilities, localization
└── Features/Exchange/
    ├── Domain/            Entities, repository protocol, use cases
    ├── Data/              DTOs, mappers, data sources, repository implementation
    └── Presentation/      State, actions, reducer, view model, views
```

Presentation uses a unidirectional data flow:

```
Trigger → Action → Reducer → (State, Effect?) → ViewModel executes Effect → Action
```

The reducer is a pure function `(State, Action) → (State, Effect?)`, making UI logic deterministic and testable in isolation. Side effects (network calls) are executed by the view model and fed back as actions.

### Design Rationale

- Business logic is isolated from UI and transport concerns.
- Conversion logic and reducer transitions are straightforward to unit-test without a running UI.
- Clear protocol boundaries make it easy to swap data sources or extend with new features.

## API & Fallback Strategy

| Endpoint | URL | Status |
|---|---|---|
| Exchange rates | `GET /v1/tickers?currencies=MXN,ARS` | Available |
| Currency list | `GET /v1/tickers-currencies` | Not yet available |

**Rates:** Remote-first. On success the rates are cached locally and marked as realtime. On failure the app serves persisted cached rates (if any) and marks them as stale.

**Currency list:** Falls back to cached codes, then to a seeded default set (`MXN`, `ARS`, `BRL`, `COP`). The remote call is behind a protocol, so the app will pick up the endpoint automatically once it goes live.

## Key Design Decisions

- **Mid-price conversion** — The API returns both `ask` and `bid`. The app uses the midpoint `(ask + bid) / 2` as a neutral rate for a two-way calculator.
- **Decimal-only math** — All conversion uses `Decimal` end-to-end with banker's rounding to avoid floating-point errors on monetary values.
- **Conservative flag rendering** — A flag emoji is shown only when a currency maps to a single unambiguous region. Multi-region currencies (e.g. USD) get a neutral globe icon instead.
- **Concurrent initial load** — Available currencies and rates are fetched in parallel to reduce time-to-content.
- **Request cancellation** — Superseded rate fetches are cancelled so stale results never overwrite newer ones.

## Edge Cases

- Empty or invalid input clears the opposite field instead of showing a misleading value.
- Locale decimal separators (comma or dot) are parsed and formatted correctly.
- Offline cold launch displays the last cached rates with a stale indicator.
- Currency endpoint unavailable — the picker populates from cached or seeded codes.
- Swap preserves the entered amount and recalculates the opposite side.

## Testing

The test suite covers:

- Conversion logic including rounding and decimal precision.
- Reducer state transitions and emitted effects.
- View model trigger → action → effect execution.
- Repository remote/cache fallback behaviour.
- Network client, retry policy, and endpoint construction.
- Localized number parsing and currency display mapping.
- UI tests for core user flows (launch, swap, input conversion).

Tests use the **Swift Testing** framework (`@Suite`, `@Test`, `#expect`).

## Trade-offs & Future Work

- **Minimal navigation** — Single-screen app; a coordinator/router would be introduced when more screens are added.
- **Accessibility** — Basic VoiceOver labels are in place; richer hints for the amount fields and swap control are a natural next step.
- **Currency metadata** — Flags and display names are derived locally; these could move to backend-driven metadata when a richer API is available.
- **Timezone assumption** — The API returns dates without a timezone; they are interpreted as UTC for freshness display only.
- **No staleness ceiling** — Stale data is surfaced with a banner and relative timestamp, but no hard max-age currently blocks conversion.
- **Cache scope** — Persisted rates reflect the latest fetched set (the currently visible pair), not a full per-currency history.
