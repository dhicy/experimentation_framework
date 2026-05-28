# 🔥 Load Testing — Locust

Performance test untuk `https://dummy.restapiexample.com` menggunakan **Locust 2.x**.

---

## Cara Menjalankan

### Install Dependency

```bash
pip install locust
```

### Headless (CI/CD)

```bash
locust -f locustfile.py \
  --headless \
  --users 10 \
  --spawn-rate 2 \
  --run-time 60s \
  --host https://dummy.restapiexample.com
```

### Web UI

```bash
locust -f locustfile.py --host https://dummy.restapiexample.com
# buka http://localhost:8089
```

---

## Struktur Script

### 🎯 5 Task (Skenario)

| Task | Endpoint | Weight | Metode |
|---|---|---|---|
| TC-01 | GET /employees | 3x | List semua employee |
| TC-02 | GET /employee/{id} | 2x | Detail satu employee |
| TC-03 | POST /create | 2x | Buat employee baru |
| TC-04 | PUT /update/{id} | 2x | Update employee |
| TC-05 | DELETE /delete/{id} | 1x | Hapus employee |

### 📡 Listeners

- `on_test_start` – log banner + thresholds saat test mulai
- `on_request` – tracking per-request: response time, RPS window, flag request lambat
- `on_test_stop` – jalankan semua assertions + cetak laporan lengkap

### ✅ Assertions (5 checks)

| Assertion | Threshold |
|---|---|
| Max RPS | ≤ 10 req/s |
| Avg Response Time | ≤ 3.000 ms |
| P95 Response Time | ≤ 5.000 ms |
| Failure Rate | ≤ 5% |
| Success Rate | ≥ 95% |

### 📊 Performance Interpretation

Report akhir otomatis mencetak analisa naratif:

- **[Throughput]** – apakah RPS dalam batas target
- **[Latency]** – grading: `Excellent` / `Good` / `Acceptable` / `Poor`
- **[Reliability]** – analisa error rate beserta rekomendasi
- **[Summary]** – kesimpulan satu baris + `PASS`/`FAIL` overall + exit code `1` jika ada threshold yang jebol (CI-friendly)
