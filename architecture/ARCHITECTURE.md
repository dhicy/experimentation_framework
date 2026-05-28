# 🏛 Automation Architecture Design

> **Dokumen ini menjelaskan keputusan arsitektur, trade-off, dan strategi skalabilitas** untuk automation suite Indodax.
> Estimasi penjelasan lisan: ±30 menit.

---

## 1. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        TEST EXECUTION LAYER                         │
│                                                                     │
│   ┌────────────┐  ┌────────────┐  ┌──────────┐  ┌──────────────┐  │
│   │  API Tests │  │  Web Tests │  │  Mobile  │  │  Load Tests  │  │
│   │  (Robot)   │  │  (Robot +  │  │  (Robot +│  │  (Locust)    │  │
│   │            │  │ Playwright)│  │  Appium) │  │              │  │
│   └─────┬──────┘  └─────┬──────┘  └────┬─────┘  └──────┬───────┘  │
│         │               │              │                │           │
└─────────┼───────────────┼──────────────┼────────────────┼───────────┘
          │               │              │                │
┌─────────▼───────────────▼──────────────▼────────────────▼───────────┐
│                       KEYWORD / BUSINESS LAYER                      │
│                                                                     │
│   api_assertions.robot   market_keywords   market_keywords          │
│   common_keywords.robot  (web)             (mobile)                 │
│   IndodaxAPILibrary.py                                              │
│                                                                     │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────────────┐
│                       PAGE / SCREEN / API LAYER                     │
│                                                                     │
│   base_page.resource          base_screen.resource                  │
│   market_page.resource        market_screen.resource                │
│   (Page Object Model)         (Screen Object Model)                 │
│                                                                     │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────────────┐
│                         RESOURCE / DATA LAYER                       │
│                                                                     │
│   variables/global_variables.robot    shared/config/*.yaml          │
│   resources/locators.resource         testdata/*.csv                │
│   config/robot.cfg                    config_loader.py              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Platform Segregation

| Platform | Framework | Engine | Folder |
|---|---|---|---|
| **API** | Robot Framework | RequestsLibrary + Custom Python Lib | `api-automation/` |
| **Web** | Robot Framework | Browser Library (Playwright) | `ui-automation/web/` |
| **Android** | Robot Framework | AppiumLibrary (UIAutomator2) | `ui-automation/mobile/` |
| **iOS** | Robot Framework | AppiumLibrary (XCUITest) | `ui-automation/mobile/` |
| **Load** | Locust | Python HttpUser | `load-testing/` |

### Justifikasi Teknis
- **Robot Framework sebagai unified runner** → semua platform (kecuali load test) menggunakan bahasa yang sama, sehingga tim QA tidak perlu context switching antar tool
- **Playwright over Selenium** → lebih stabil untuk modern web app dengan heavy JavaScript (seperti crypto trading dashboard), auto-wait, dan built-in network interception
- **Appium + UIAutomator2/XCUITest** → industri standar, mendukung native, hybrid, dan cross-platform
- **Locust** → Python-native, scriptable, mendukung distributed testing, CI-friendly dengan `--headless` mode

---

## 3. Clean Architecture Principles

### 3.1 Separation of Concerns

```
tests/          ← HANYA orchestration (WHAT to test)
keywords/       ← Business logic (HOW to test, domain language)
pages/screens/  ← Element interaction (WHERE elements are)
resources/      ← Configuration & locators (static data)
testdata/       ← Test inputs (CSV/JSON, data-driven)
libraries/      ← Python helpers (complex assertions)
```

### 3.2 DRY (Don't Repeat Yourself)
- Locator disimpan di `locators.resource` — tidak tersebar di test files
- Shared keywords di `common_keywords.robot` — HTTP layer reusable
- Config di satu tempat (`variables.resource`, `global_variables.robot`)

### 3.3 Single Responsibility
- `common_keywords.robot` → HTTP layer only
- `api_assertions.robot` → domain assertions only
- `IndodaxAPILibrary.py` → complex Python logic only (numeric checks, schema validation)

---

## 4. Tagging Strategy

Setiap test case dapat memiliki **multiple tags** untuk flexible execution:

```robotframework
*** Test Cases ***
Verify BTC Ticker Returns Valid Price
    [Tags]    smoke    happy-path    ticker    regression    sla
    ...
```

### Kombinasi Run yang Umum

```bash
# CI gate (cepat ~30s)
python -m robot --include smoke tests/

# Regression lengkap
python -m robot --exclude wip tests/

# SLA/performance check saja
python -m robot --include sla tests/

# Negative scenarios
python -m robot --include negative tests/

# Specific feature
python -m robot --include ticker tests/
```

---

## 5. Environment Strategy

```
dev        → BASE_URL=https://dev.indodax.com      (internal)
staging    → BASE_URL=https://staging.indodax.com  (pre-prod)
production → BASE_URL=https://indodax.com          (live)
```

Override via CLI:
```bash
python -m robot \
  --variable BASE_URL:https://staging.indodax.com \
  --variable ENV:staging \
  --outputdir results/staging \
  tests/
```

Atau via `robot.cfg`:
```ini
[options]
variable = BASE_URL:https://indodax.com
variable = ENV:production
```

---

## 6. Test Execution Strategy

| Strategy | Tag | Trigger | Durasi |
|---|---|---|---|
| **Smoke** | `smoke` | Setiap push ke branch | ~30 detik |
| **Regression** | `regression` | Nightly / PR ke main | ~5–10 menit |
| **Selective** | `ticker` / `orderbook` / dll | Manual / feature branch | Per suite |
| **SLA Check** | `sla` | Release gate | ~2 menit |
| **Negative** | `negative` | Full regression | Bagian dari regression |

---

## 7. Error Handling & Reporting Strategy

### Error Handling
- **Custom library** (`IndodaxAPILibrary.py`) → assertion messages yang deskriptif dengan context
- **Suite/Test Setup-Teardown** → cleanup otomatis meski test gagal
- **`Run Keyword And Ignore Error`** → untuk optional checks yang tidak boleh stop test
- **`Continue On Failure`** → untuk data-driven tests (semua data dijalankan meski ada failure)

### Reporting
- **Robot HTML Report** (`report.html`) → executive summary, pass/fail rate
- **Robot Log** (`log.html`) → detailed step-by-step dengan screenshot (web)
- **output.xml** → machine-readable, untuk CI artifact & trend analysis
- **Locust** → real-time dashboard + otomatis printed report dengan analisa naratif

---

## 8. Scalability Consideration

| Dimensi | Strategi |
|---|---|
| **Tambah endpoint baru** | Tambah 1 variable + 1 keyword + 1 test file (template tersedia) |
| **Tambah trading pair** | Edit 1 baris di CSV testdata, otomatis jalan via `[Template]` |
| **Tambah platform** | Buat folder baru di `ui-automation/`, ikuti konvensi screens/ + keywords/ + tests/ |
| **Distributed load test** | Locust master-worker mode: `locust --master` / `locust --worker` |
| **Paralel execution** | `pabot` (Parallel Robot Framework executor) |

---

## 9. Maintainability Consideration

| Aspek | Implementasi |
|---|---|
| **Locator centralization** | Semua locator di `locators.resource` — update 1 tempat |
| **No magic strings** | Semua URL, timeout, nilai threshold di variables file |
| **Self-documenting tests** | Keyword names dalam bahasa bisnis (`Verify BTC Ticker Returns Valid Price`) |
| **Consistent naming convention** | `TC_WEB_001`, `TC_MOB_001`, `TC-MKT-001` |
| **Gitignore results** | `results/`, `reports/`, `*.xml` di `.gitignore` — repo tetap bersih |

---

## 10. Trade-off Decisions

| Keputusan | Pilihan Diambil | Trade-off |
|---|---|---|
| Robot vs Pytest untuk API | **Robot Framework** | Lebih verbose, tapi seragam dengan UI tests dan mudah dibaca non-engineer |
| Playwright vs Selenium | **Playwright** | Setup lebih kompleks, tapi jauh lebih stabil untuk modern SPA |
| CSV vs YAML untuk test data | **CSV** | Kurang ekspresif, tapi mudah diubah tanpa coding dan support native di Robot |
| Monorepo vs multi-repo | **Monorepo** | Lebih sulit manage permission, tapi semua automation terpusat dan mudah di-trace |
| Custom Python lib vs pure Robot | **Hybrid** | Menambah dependency Python, tapi memungkinkan complex numeric validation yang sulit di Robot |
