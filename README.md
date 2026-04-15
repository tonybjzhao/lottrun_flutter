# lottfun_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## AU Lottery CSV Updates

The repository can publish Australia lottery CSVs from the `docs/` folder for GitHub Pages.
The current scraper keeps Playwright in the loop, but fetches stable per-draw public result pages for CI reliability.
The scheduled workflow runs at `12:00 UTC` daily, which is typically `10:00 pm AEST` or `11:00 pm AEDT` after draw results are usually published in Australia.

Local run:

```bash
python3 -m pip install -r requirements.txt
python3 -m playwright install chromium
python3 scrape_au_lottos.py
```

Outputs:

- `docs/powerball.csv`
- `docs/oz_lotto.csv`
- `docs/saturday_lotto.csv`

The GitHub Actions workflow at `.github/workflows/update_lotto.yml` runs daily and can also be triggered manually with `workflow_dispatch`.
