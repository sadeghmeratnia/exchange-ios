# Exchange iOS

Exchange iOS is a take-home assignment implementation of a USDc exchange calculator built with SwiftUI.

## What This App Does

- Converts between USDc and selected fiat currencies.
- Supports editing either amount field and auto-updating the opposite side.
- Lets users choose the non-USDc currency from a bottom sheet.
- Supports currency swap between top and bottom rows.
- Fetches rates from remote API and falls back to cached data when needed.
- Shows realtime vs stale status with last-updated context.

## Architecture

This project uses a feature-first Clean Architecture split:

- `Core/` for shared infrastructure (networking, DI, presentation contracts, utilities, localization).
- `Features/Exchange/Domain` for entities, repository protocol, and use cases.
- `Features/Exchange/Data` for DTOs, mappers, data sources, and repository implementation.
- `Features/Exchange/Presentation` for reducer/view-model/view/state flow and coordinator/root wiring.

Presentation follows a unidirectional flow:

- `Trigger -> Action -> Reducer -> Effect -> ViewModel execution -> Action`

### Why This Structure

- Keeps business logic isolated from UI and transport concerns.
- Makes conversion/reducer behavior straightforward to unit test.
- Provides clear seams for replacing data sources and adding new features.

## API and Fallback Strategy

- Rates endpoint:
  - `GET https://api.dolarapp.dev/v1/tickers?currencies=MXN,ARS`
- Currency list endpoint may be unavailable:
  - `GET https://api.dolarapp.dev/v1/tickers-currencies`

Fallback behavior:

- Remote-first rates fetch.
- On success: cache rates and mark quote as realtime.
- On failure: use persisted cached rates if available and mark as stale.
- Currency list falls back to cached codes or seeded defaults (`MXN`, `ARS`, `BRL`, `COP`).

## Currency Display Policy

- UI displays currency code (matching wireframe style).
- `USDC` is displayed as `USDc`.
- Flag rendering is conservative:
  - Show a flag only when a deterministic single representative region can be inferred.
  - Otherwise show neutral `globe` SF Symbol fallback.

## Number and Locale Behavior

- Input parsing and output formatting are locale-aware.
- Comma-decimal and dot-decimal locales are supported.
- Decimal math is preserved end-to-end for conversion correctness.

## Project Entry

- `ExchangeApp` builds `AppContainer` and starts `ExchangeFeatureBuilder`.
- `ExchangeListCoordinator` + `ExchangeListRootView` provide the current root navigation shell for the feature.

## Tests

Covered areas include:

- Conversion logic.
- Reducer transitions and emitted effects.
- View-model trigger/action/effect execution behavior.
- Repository remote/cache fallback behavior.
- Networking client and retry policy.
- Localized number parsing and currency display mapping.

Run tests:

```bash
xcodebuild -project "Exchange.xcodeproj" -scheme "Exchange" -destination "platform=iOS Simulator,name=iPhone 17 Pro" -only-testing:"ExchangeTests" test
```

## Tradeoffs and Next Steps

- Current navigation scope is intentionally minimal (single primary screen).
- Accessibility can be expanded with richer labels/hints for amount fields and controls.
- Currency metadata can evolve to backend-driven display metadata once a richer currency API is available.
