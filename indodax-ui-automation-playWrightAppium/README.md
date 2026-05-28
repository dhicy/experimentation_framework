# Indodax UI Automation

Proyek otomasi pengujian untuk Indodax - Web & Mobile menggunakan **Robot Framework** dengan arsitektur bersih (Clean Architecture).

---

## 📁 Struktur Proyek

```
indodax-automation/
├── web/                          # Web Automation (Robot + Playwright)
│   ├── tests/                    # Test suites
│   ├── pages/                    # Page Object Model
│   ├── keywords/                 # Custom keywords
│   ├── resources/                # Resource files (variables, settings)
│   └── data/                     # Test data (CSV/JSON)
│
├── mobile/                       # Mobile Automation (Robot + Appium)
│   ├── tests/                    # Test suites
│   ├── screens/                  # Screen Object Model
│   ├── keywords/                 # Custom keywords
│   ├── resources/                # Resource files
│   └── data/                     # Test data
│
├── shared/
│   ├── utils/                    # Shared utilities
│   └── config/                   # Configuration files
│
├── requirements.txt              # Python dependencies
└── README.md
```

---

## 🚀 Cara Setup

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Install Playwright Browsers

```bash
rfbrowser init
```

### 3. Setup Appium (Mobile)

```bash
npm install -g appium
appium driver install uiautomator2   # Android
appium driver install xcuitest       # iOS
```

---

## ▶️ Cara Menjalankan Test

### Web Tests

```bash
# Jalankan semua web test
robot --outputdir web/reports web/tests/

# Jalankan test spesifik
robot --outputdir web/reports web/tests/market_page_test.robot

# Jalankan dengan tag
robot --include smoke --outputdir web/reports web/tests/
```

### Mobile Tests

```bash
# Pastikan Appium server berjalan
appium

# Jalankan mobile test
robot --outputdir mobile/reports mobile/tests/

# Jalankan test spesifik
robot --outputdir mobile/reports mobile/tests/market_screen_test.robot
```

---

## 🏗️ Arsitektur

### Clean Architecture Layers

```
┌─────────────────────────────────┐
│          TEST LAYER             │  ← Test suites (.robot)
│   (tests/ directory)            │
├─────────────────────────────────┤
│        KEYWORD LAYER            │  ← Business logic keywords
│   (keywords/ directory)         │
├─────────────────────────────────┤
│     PAGE/SCREEN LAYER           │  ← Page/Screen Object Model
│   (pages/ or screens/)          │
├─────────────────────────────────┤
│      RESOURCE LAYER             │  ← Locators, variables, config
│   (resources/ directory)        │
└─────────────────────────────────┘
```

### Prinsip yang Diterapkan

- **Page Object Model (POM)**: Setiap halaman/layar direpresentasikan sebagai file terpisah
- **Data-Driven Testing**: Data test dipisah dari logic test (CSV/JSON)
- **Keyword Abstraction**: Keyword bisnis dipisah dari keyword teknis
- **Maintainable Locators**: Locator dikelola di file resources terpusat

---

## 📊 Test Cases

### Web - Indodax Market Page

| Test Case | Deskripsi |
|-----------|-----------|
| TC_WEB_001 | Verifikasi halaman market dapat dibuka |
| TC_WEB_002 | Verifikasi elemen header halaman market |
| TC_WEB_003 | Verifikasi data harga USDT/IDR ditampilkan |
| TC_WEB_004 | Verifikasi order book (bid & ask) |
| TC_WEB_005 | Verifikasi trading chart ditampilkan |
| TC_WEB_006 | Verifikasi tabel trade history |
| TC_WEB_007 | Verifikasi info pair USDT/IDR |
| TC_WEB_008 | Verifikasi responsive layout |
| TC_WEB_009 | Data-driven: validasi multiple market pairs |

### Mobile - Indodax Market Screen

| Test Case | Deskripsi |
|-----------|-----------|
| TC_MOB_001 | Verifikasi halaman market dapat dibuka |
| TC_MOB_002 | Verifikasi daftar market ditampilkan |
| TC_MOB_003 | Verifikasi search coin berfungsi |
| TC_MOB_004 | Verifikasi filter market (IDR/BTC/USDT) |
| TC_MOB_005 | Verifikasi navigasi ke detail coin |
| TC_MOB_006 | Verifikasi data harga coin ditampilkan |
| TC_MOB_007 | Verifikasi sort market list |
| TC_MOB_008 | Data-driven: validasi multiple coins |

---

## ⚙️ Konfigurasi

### Web Config (`shared/config/web_config.yaml`)
- Base URL
- Browser settings
- Timeout values

### Mobile Config (`shared/config/mobile_config.yaml`)
- Appium server URL
- Device capabilities
- App path/package

---

## 📝 Laporan

Laporan test akan dihasilkan di folder `reports/`:
- `report.html` - HTML report
- `log.html` - Detailed log
- `output.xml` - XML output untuk CI/CD
