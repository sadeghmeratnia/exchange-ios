# Exchange iOS

A native SwiftUI currency exchange calculator that converts between USDc and a selection of fiat currencies, using live rates from the dolarapp API with offline-capable fallback.

<!-- TODO: replace with your repository URL if you want a clone link in the README -->

## Features

- Convert between USDc and a selected fiat currency, editing either field and auto-updating the other.
- Choose the non-USDc currency from a bottom sheet.
- Swap the top and bottom currencies with a single tap.
- Live rates from the remote API, with automatic fallback to cached rates when the network is unavailable.
- Realtime vs. stale indication with a last-updated timestamp.
- Locale-aware number input and formatting (comma- and dot-decimal locales).

## Screenshots

<!-- TODO: drop 2-3 screenshots or a short screen recording / GIF here.
     Suggested shots: (1) main calculator, (2) currency picker sheet, (3) stale/offline banner.
     Example:
     | Calculator | Currency Picker | Offline |
     |---|---|---|
     | ![Calculator](docs/calculator.png) | ![Picker](docs/picker.png) | ![Offline](docs/offline.png) |
-->

## Requirements

- iOS 16.0+ <!-- TODO: confirm against the project's deployment target; APIs used (Locale.region, presentationDetents) require 16+ -->
- Xcode 16 or later <!-- TODO: set to the Xcode version you built with -->
- Swift 5.9+
- No third-party dependencies — the project builds with the standard Apple toolchain only.

## Getting Started

```bash
git clone https://github.com/sadeghmeratnia/exchange-ios
cd exchange-ios
open Exchange.xcodeproj
```

Then in Xcode:

1. Select the `Exchange` scheme.
2. Choose any iOS Simulator (e.g. iPhone 17 Pro).
3. Run with `Cmd + R`.

No package resolution, signing changes, or other setup is required.

### Running tests

From Xcode: `Cmd + U`. From the command line:

```bash
xcodebuild -project "Exchange.xcodeproj" \
  -scheme "Exchange" \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro" \
  -only-testing:"ExchangeTests" test
```

<!-- TODO: adjust the simulator name to one installed on your machine -->

## Architecture

The project uses a feature-first Clean Architecture split:

- `Core/` — shared infrastructure: networking, dependency injection, presentation contracts, utilities, and localization.
- `Features/Exchange/Domain` — entities, repository protocol, and use cases (pure business logic).
- `Features/Exchange/Data` — DTOs, mappers, data sources, and the repository implementation.
- `Features/Exchange/Presentation` — the reducer / view-model / view / state flow and the feature's root wiring.

Presentation follows a unidirectional flow:

```
Trigger -> Action -> Reducer -> Effect -> ViewModel execution -> Action
```

The reducer is a pure function `(state, action) -> (state, effect?)`, which makes UI logic deterministic and easy to test in isolation. Side effects (network calls) are executed by the view model and fed back in as actions.

### Why this structure

- Keeps business logic isolated from UI and transport concerns.
- Makes conversion and reducer behaviour straightforward to unit test without UI.
- Provides clear seams for swapping data sources and adding new features.

## Exchange Rate Handling

- The rates endpoint returns both an `ask` and a `bid` price per currency. Conversion uses the **mid price** (the average of ask and bid) as a neutral rate appropriate for a two-way calculator, rather than favouring the buy or sell side.
- All conversion math uses `Decimal` end-to-end (never floating point) to avoid rounding errors with monetary values.
- The initial load fetches the available currencies and the rates concurrently to reduce time-to-content.

## API and Fallback Strategy

Rates endpoint:

```
GET https://api.dolarapp.dev/v1/tickers?currencies=MXN,ARS
```

Available-currencies endpoint (may be unavailable):

```
GET https://api.dolarapp.dev/v1/tickers-currencies
```

Fallback behaviour:

- **Rates:** remote-first. On success, rates are cached and the quote is marked realtime. On failure, the app uses persisted cached rates (if any) and marks the quote as stale.
- **Currency list:** the endpoint is not guaranteed to be available, so the app falls back to cached codes or a seeded default set (`MXN`, `ARS`, `BRL`, `COP`). The remote call is made behind a protocol, so when the endpoint goes live the app picks it up with no code changes.

## Edge Cases Handled

- **Empty or invalid input** clears the opposite field rather than producing a misleading value.
- **Locale decimal separators** — input typed with either a comma or a dot decimal separator is parsed correctly, and output is formatted for the current locale.
- **Offline cold launch** — rates are persisted, so the app can launch without a network connection and show the last known rates with a stale indicator.
- **Currency endpoint unavailable** — the picker still populates from the cached/seed list.
- **In-flight request cancellation** — superseded rate fetches are cancelled to avoid stale results overwriting newer ones.
- **Swap** preserves the entered amount and recalculates the opposite side.

## Currency Display Policy

- The UI shows the currency code (matching the wireframe style); `USDC` is displayed as `USDc`.
- Flags are rendered conservatively: a flag is shown only when a currency maps to a single, unambiguous region. For currencies tied to multiple regions, a neutral `globe` SF Symbol is shown instead of guessing. This keeps an unexpected currency from the API from rendering a misleading flag.

## Number and Locale Behavior

- Input parsing and output formatting are locale-aware and support both comma-decimal and dot-decimal locales.
- Decimal precision is preserved end-to-end for conversion correctness.

## Project Entry

`ExchangeApp` builds the `AppContainer` (network client, logger) and asks `ExchangeFeatureBuilder` to compose the Exchange feature's dependency graph and produce its root view, which is hosted in a `NavigationStack`.

<!-- TODO: if you keep the coordinator types, you can mention them here; if you collapse them, this description already matches the simplified entry. -->

## Testing

Covered areas include:

- Conversion logic (including rounding and decimal handling).
- Reducer transitions and emitted effects.
- View-model trigger / action / effect execution.
- Repository remote/cache fallback behaviour.
- Networking client and retry policy.
- Localized number parsing and currency display mapping.

Tests use the Swift Testing framework.

## Trade-offs and Next Steps

- **Navigation scope is intentionally minimal** — the app is a single primary screen, so it does not ship a full navigation coordinator. A coordinator/router layer would be introduced once the app grows to multiple screens and flows; the feature builder already acts as the per-feature composition root.
- **Accessibility** — basic support is in place; richer VoiceOver labels and hints for the amount fields and swap control are a natural next addition.
- **Currency metadata** — display names and flags are derived locally; these could move to backend-driven metadata once a richer currency API is available.
- **Timestamps** — the API returns dates without a timezone, which are interpreted as UTC for the "last updated" display; this affects freshness labelling only, never conversion.
