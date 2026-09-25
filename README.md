# Immoizi Core

Shared Flutter package used by `immoizi-AppManager` and `immoizi-App-user-tenant`.

## Contents

- `GraphQLClient`, login mutation and JSON parsing helpers
- `DashboardCache` for the offline dashboard payload
- `Property` model, `PropertyFilters` and the filter sheet
- Ivory theme and app shell widgets (header, drawer, bottom bar, connection card, search bar)
- Media viewers (video, image gallery) and the interest-request chat

## Usage

The apps depend on it by path, so this folder must sit next to them:

```yaml
dependencies:
  immoizi_core:
    path: ../immoizi-core
```

```bash
flutter pub get
flutter test
```
