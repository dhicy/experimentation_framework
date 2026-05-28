# Indodax API — Robot Framework Automation (PoC)

Proof-of-concept API test automation for the [Indodax Public REST API](https://github.com/btcid/indodax-official-api-docs).

---

## Project Structure

```
indodax-robot/
│
├── tests/                          # Test suites (one file per feature area)
│   ├── test_smoke.robot            # ✈  CI gate — fastest subset (6 tests)
│   ├── test_ticker.robot           # 📈 Ticker endpoint tests
│   ├── test_orderbook.robot        # 📖 Order book / depth tests
│   ├── test_trades.robot           # 🔄 Trade history tests
│   └── test_general_api.robot      # 🌐 server_time · pairs · summaries
│
├── resources/
│   ├── keywords/
│   │   ├── common_keywords.robot   # HTTP layer: GET, session, base assertions
│   │   └── api_assertions.robot    # Domain assertions: ticker, depth, trades…
│   ├── variables/
│   │   └── global_variables.robot  # URLs, timeouts, pair names, thresholds
│   └── testdata/
│       ├── ticker_pairs.csv        # Data-driven input for ticker tests
│       ├── orderbook_pairs.csv     # Data-driven input for order book tests
│       └── trades_pairs.csv        # Data-driven input for trades tests
│
├── libraries/
│   └── IndodaxAPILibrary.py        # Custom Python library (numeric checks, schema, logging)
│
├── config/
│   └── robot.cfg                   # Robot Framework configuration (output paths, log level)
│
├── results/                        # Generated: report.html · log.html · output.xml
├── Makefile                        # Common run targets
├── requirements.txt
└── README.md
```

---

## Design Principles

| Principle | Implementation |
|---|---|
| **Scalable structure** | Separate suite files per endpoint; keywords split by responsibility layer |
| **Data-driven testing** | `[Template]` + inline tables; CSV files for external parameterisation |
| **Proper segregation** | `resources/` (reusable) vs `tests/` (executable) vs `libraries/` (Python) |
| **Clear assertion strategy** | Atomic assertion keywords with descriptive failure messages |
| **Reusable components** | `common_keywords.robot` (HTTP), `api_assertions.robot` (domain), `IndodaxAPILibrary.py` (Python helpers) |
| **Logging & reporting** | `Log Response Summary` keyword + built-in Robot HTML report + custom log statements |

---

## Endpoints Covered

| Endpoint | Suite | Tags |
|---|---|---|
| `GET /api/server_time` | test_general_api | `server-time` |
| `GET /api/pairs` | test_general_api | `pairs` |
| `GET /api/summaries` | test_general_api | `summaries` |
| `GET /api/{pair}/ticker` | test_ticker | `ticker` |
| `GET /api/{pair}/depth` | test_orderbook | `orderbook` |
| `GET /api/{pair}/trades` | test_trades | `trades` |

---

## Test Categories (Tags)

| Tag | Purpose |
|---|---|
| `smoke` | Fast CI gate — 1 test per endpoint |
| `happy-path` | Normal expected behaviour |
| `contract` / `schema` | Field presence and type checks |
| `integrity` | Value correctness (price > 0, ask >= bid, etc.) |
| `negative` | Invalid inputs, error handling |
| `performance` / `sla` | Response time assertions |
| `data-driven` | Template-based multi-pair execution |
| `regression` | Key business-rule checks (BTC pair exists, etc.) |

---

## Setup

```bash
pip install -r requirements.txt
```

---

## Running Tests

```bash
# Smoke tests (CI gate)
make smoke

# Full regression
make all

# Specific suite
make ticker
make orderbook
make trades
make general

# By tag
python -m robot --include negative --outputdir results tests/
python -m robot --include performance --outputdir results tests/

# Single test file
python -m robot --outputdir results tests/test_ticker.robot
```

---

## Reports

After any run, open `results/report.html` in your browser for the full execution report with pass/fail details, timing, and log output.

---

## Extending the Suite

### Add a new trading pair
Edit the `[Template]` table inside the relevant test file, or add a row to the appropriate CSV in `resources/testdata/`.

### Add a new endpoint
1. Add URL variables to `resources/variables/global_variables.robot`
2. Add a `GET XYZ` keyword to `resources/keywords/common_keywords.robot`
3. Add domain assertion keywords to `resources/keywords/api_assertions.robot`
4. Create `tests/test_new_endpoint.robot`
5. Add a smoke test to `tests/test_smoke.robot`

### Override base URL (e.g. staging)
```bash
python -m robot --variable BASE_URL:https://staging.indodax.com --outputdir results tests/
```
