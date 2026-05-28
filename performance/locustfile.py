"""
============================================================
  Performance Test – dummy.restapiexample.com
  Tool   : Locust 2.x
  Target : https://dummy.restapiexample.com
  Max RPS: 10
============================================================

Run (headless, 10 RPS for 60 s):
  locust -f locustfile.py \
         --headless \
         --users 10 \
         --spawn-rate 2 \
         --run-time 60s \
         --host https://dummy.restapiexample.com

Run (Web UI):
  locust -f locustfile.py --host https://dummy.restapiexample.com
  → open http://localhost:8089
"""

import json
import logging
import statistics
import time
from datetime import datetime

from locust import HttpUser, between, events, task
from locust.runners import MasterRunner, WorkerRunner

# ──────────────────────────────────────────────────────────
# Logging
# ──────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("perf-test")

# ──────────────────────────────────────────────────────────
# Thresholds (assertions)
# ──────────────────────────────────────────────────────────
THRESHOLDS = {
    "max_rps"             : 10,      # do not exceed 10 req/s
    "max_avg_response_ms" : 3_000,   # average response ≤ 3 s
    "max_p95_response_ms" : 5_000,   # 95th percentile ≤ 5 s
    "max_failure_rate_pct": 5.0,     # error rate ≤ 5 %
    "min_success_rate_pct": 95.0,    # success rate ≥ 95 %
}

# ──────────────────────────────────────────────────────────
# In-memory metrics collector (used by listener)
# ──────────────────────────────────────────────────────────
_metrics: dict = {
    "response_times": [],
    "failures"      : 0,
    "successes"     : 0,
    "rps_samples"   : [],
    "start_time"    : None,
    "last_rps_ts"   : None,
    "req_in_window" : 0,
}


# ══════════════════════════════════════════════════════════
# LISTENERS
# ══════════════════════════════════════════════════════════

@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    """Fired once when the test begins."""
    _metrics["start_time"]   = time.time()
    _metrics["last_rps_ts"]  = time.time()
    log.info("=" * 60)
    log.info("  INDODAX Performance Test – dummy.restapiexample.com")
    log.info("  Started at : %s", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    log.info("  Thresholds : %s", json.dumps(THRESHOLDS, indent=2))
    log.info("=" * 60)


@events.request.add_listener
def on_request(request_type, name, response_time, response_length,
               response, context, exception, **kwargs):
    """
    Fired after every HTTP request – success or failure.
    Collects raw data and logs per-request detail.
    """
    # Track RPS in 1-second rolling windows
    now = time.time()
    _metrics["req_in_window"] += 1
    if now - _metrics["last_rps_ts"] >= 1.0:
        _metrics["rps_samples"].append(_metrics["req_in_window"])
        _metrics["req_in_window"] = 0
        _metrics["last_rps_ts"]   = now

    if exception:
        _metrics["failures"] += 1
        log.warning("  [FAIL] %s %s | error: %s", request_type, name, exception)
        return

    _metrics["successes"]       += 1
    _metrics["response_times"]  .append(response_time)

    # Per-request assertion: flag individual slow responses
    if response_time > THRESHOLDS["max_p95_response_ms"]:
        log.warning(
            "  [SLOW] %s %s | %.0f ms > p95 threshold %d ms",
            request_type, name, response_time,
            THRESHOLDS["max_p95_response_ms"],
        )
    else:
        log.debug("  [OK]   %s %s | %.0f ms | %d bytes",
                  request_type, name, response_time, response_length)


@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    """
    Fired once when the test ends.
    Runs all assertions and prints a performance interpretation report.
    """
    _run_assertions_and_report(environment)


# ──────────────────────────────────────────────────────────
# Assertion engine + report
# ──────────────────────────────────────────────────────────

def _run_assertions_and_report(environment):
    rt       = _metrics["response_times"]
    total    = _metrics["successes"] + _metrics["failures"]
    duration = time.time() - (_metrics["start_time"] or time.time())

    # Derived stats
    avg_ms        = statistics.mean(rt)              if rt else 0
    p95_ms        = sorted(rt)[int(len(rt) * 0.95)] if rt else 0
    p99_ms        = sorted(rt)[int(len(rt) * 0.99)] if rt else 0
    min_ms        = min(rt)                          if rt else 0
    max_ms        = max(rt)                          if rt else 0
    median_ms     = statistics.median(rt)            if rt else 0
    failure_rate  = (_metrics["failures"] / total * 100) if total else 0
    success_rate  = 100 - failure_rate
    actual_rps    = total / duration if duration else 0
    peak_rps      = max(_metrics["rps_samples"]) if _metrics["rps_samples"] else 0

    # ── Assertion checks ──────────────────────────────────
    assertion_results = []

    def check(label, actual, threshold, passed):
        status = "✅ PASS" if passed else "❌ FAIL"
        assertion_results.append((status, label, actual, threshold))
        return passed

    all_pass = all([
        check("Max RPS",
              f"{peak_rps:.1f} rps",
              f"≤ {THRESHOLDS['max_rps']} rps",
              peak_rps <= THRESHOLDS["max_rps"]),

        check("Avg Response Time",
              f"{avg_ms:.0f} ms",
              f"≤ {THRESHOLDS['max_avg_response_ms']} ms",
              avg_ms <= THRESHOLDS["max_avg_response_ms"]),

        check("P95 Response Time",
              f"{p95_ms:.0f} ms",
              f"≤ {THRESHOLDS['max_p95_response_ms']} ms",
              p95_ms <= THRESHOLDS["max_p95_response_ms"]),

        check("Failure Rate",
              f"{failure_rate:.2f} %",
              f"≤ {THRESHOLDS['max_failure_rate_pct']} %",
              failure_rate <= THRESHOLDS["max_failure_rate_pct"]),

        check("Success Rate",
              f"{success_rate:.2f} %",
              f"≥ {THRESHOLDS['min_success_rate_pct']} %",
              success_rate >= THRESHOLDS["min_success_rate_pct"]),
    ])

    # ── Print report ──────────────────────────────────────
    sep  = "=" * 65
    sep2 = "-" * 65

    log.info("")
    log.info(sep)
    log.info("  PERFORMANCE TEST REPORT")
    log.info("  Finished at : %s", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    log.info(sep)

    log.info("  RAW METRICS")
    log.info(sep2)
    log.info("  Total Requests  : %d", total)
    log.info("  Successes       : %d", _metrics["successes"])
    log.info("  Failures        : %d", _metrics["failures"])
    log.info("  Test Duration   : %.1f s", duration)
    log.info("  Avg RPS         : %.2f", actual_rps)
    log.info("  Peak RPS        : %.2f", peak_rps)
    log.info(sep2)
    log.info("  RESPONSE TIME DISTRIBUTION")
    log.info(sep2)
    log.info("  Min             : %.0f ms", min_ms)
    log.info("  Median (p50)    : %.0f ms", median_ms)
    log.info("  Average         : %.0f ms", avg_ms)
    log.info("  p95             : %.0f ms", p95_ms)
    log.info("  p99             : %.0f ms", p99_ms)
    log.info("  Max             : %.0f ms", max_ms)
    log.info(sep2)
    log.info("  ASSERTIONS")
    log.info(sep2)
    for status, label, actual, threshold in assertion_results:
        log.info("  %s  %-25s actual=%-15s threshold=%s",
                 status, label, actual, threshold)
    log.info(sep2)

    # ── Performance interpretation ────────────────────────
    log.info("  PERFORMANCE INTERPRETATION")
    log.info(sep2)
    _interpret(avg_ms, p95_ms, peak_rps, failure_rate,
               actual_rps, total, duration)
    log.info(sep2)
    verdict = "✅  OVERALL: PASS – All thresholds met." if all_pass \
              else "❌  OVERALL: FAIL – One or more thresholds violated."
    log.info("  %s", verdict)
    log.info(sep)

    # Propagate failure to CI exit code
    if not all_pass:
        environment.process_exit_code = 1


def _interpret(avg_ms, p95_ms, peak_rps, failure_rate,
               actual_rps, total, duration):
    """Print a human-readable performance analysis."""

    # Throughput analysis
    if peak_rps <= THRESHOLDS["max_rps"]:
        log.info("  [Throughput]  Peak RPS %.1f ≤ %.0f target. "
                 "Load was well within limits.", peak_rps, THRESHOLDS["max_rps"])
    else:
        log.info("  [Throughput]  ⚠ Peak RPS %.1f exceeded target %.0f. "
                 "Reduce spawn-rate or add rate-limiting.",
                 peak_rps, THRESHOLDS["max_rps"])

    # Latency analysis
    if avg_ms < 500:
        latency_grade = "Excellent (< 500 ms avg)"
    elif avg_ms < 1_500:
        latency_grade = "Good (500 ms – 1.5 s avg)"
    elif avg_ms < 3_000:
        latency_grade = "Acceptable (1.5 s – 3 s avg)"
    else:
        latency_grade = "Poor (> 3 s avg) – investigate server bottleneck"
    log.info("  [Latency]     %s", latency_grade)

    if p95_ms > THRESHOLDS["max_p95_response_ms"]:
        log.info("  [Latency]     ⚠ p95 %.0f ms exceeds threshold. "
                 "Long tail detected – check slow endpoints.", p95_ms)

    # Reliability analysis
    if failure_rate == 0:
        log.info("  [Reliability] Zero failures. API is stable under this load.")
    elif failure_rate <= 1:
        log.info("  [Reliability] Failure rate %.2f %% – minor, acceptable.", failure_rate)
    elif failure_rate <= THRESHOLDS["max_failure_rate_pct"]:
        log.info("  [Reliability] Failure rate %.2f %% – within threshold "
                 "but warrants investigation.", failure_rate)
    else:
        log.info("  [Reliability] ⚠ Failure rate %.2f %% exceeds threshold. "
                 "API may be rate-limiting or degraded.", failure_rate)

    # General recommendation
    log.info("  [Summary]     %d requests in %.1f s. "
             "System handled the load %s.",
             total, duration,
             "gracefully" if failure_rate < THRESHOLDS["max_failure_rate_pct"]
             else "with degradation")


# ══════════════════════════════════════════════════════════
# USER SCENARIOS
# ══════════════════════════════════════════════════════════

class EmployeeApiUser(HttpUser):
    """
    Simulates a realistic user journey through the Employee API.
    wait_time keeps RPS ≤ 10 with 10 concurrent users.
    """

    host     = "https://dummy.restapiexample.com"
    wait_time = between(1, 3)   # 1–3 s think time → ~10 RPS with 10 users

    # ── GET /api/v1/employees ──────────────────────────────
    @task(3)
    def get_all_employees(self):
        """TC-01 – List all employees (highest weight – most common read)."""
        with self.client.get(
            "/api/v1/employees",
            name="GET /employees",
            catch_response=True,
        ) as resp:
            # Assertion: HTTP 200
            if resp.status_code != 200:
                resp.failure(
                    f"Expected 200, got {resp.status_code}"
                )
                return

            # Assertion: valid JSON with expected structure
            try:
                body = resp.json()
                assert body.get("status") == "success", \
                    f"status != success: {body.get('status')}"
                data = body.get("data", [])
                assert isinstance(data, list), "data is not a list"
                assert len(data) > 0,          "data list is empty"

                # Spot-check first record shape
                first = data[0]
                for field in ("id", "employee_name", "employee_salary", "employee_age"):
                    assert field in first, f"Missing field: {field}"

                resp.success()
                log.debug("  GET /employees → %d records", len(data))

            except (AssertionError, ValueError, KeyError) as exc:
                resp.failure(str(exc))

    # ── GET /api/v1/employee/{id} ──────────────────────────
    @task(2)
    def get_single_employee(self):
        """TC-02 – Fetch a specific employee by ID."""
        emp_id = 1   # stable ID for repeatable tests
        with self.client.get(
            f"/api/v1/employee/{emp_id}",
            name="GET /employee/{id}",
            catch_response=True,
        ) as resp:
            if resp.status_code != 200:
                resp.failure(f"Expected 200, got {resp.status_code}")
                return
            try:
                body = resp.json()
                assert body.get("status") == "success", \
                    f"status != success: {body.get('status')}"
                data = body.get("data", {})
                assert isinstance(data, dict),       "data is not an object"
                assert str(data.get("id")) == str(emp_id), \
                    f"Returned id {data.get('id')} != {emp_id}"
                assert "employee_name" in data,      "Missing field: employee_name"
                assert data.get("employee_salary") is not None, \
                    "employee_salary is null"
                resp.success()
            except (AssertionError, ValueError, KeyError) as exc:
                resp.failure(str(exc))

    # ── POST /api/v1/create ───────────────────────────────
    @task(2)
    def create_employee(self):
        """TC-03 – Create a new employee record."""
        payload = {
            "name"  : "Locust Test User",
            "salary": "99000",
            "age"   : "30",
        }
        with self.client.post(
            "/api/v1/create",
            json=payload,
            name="POST /create",
            catch_response=True,
        ) as resp:
            if resp.status_code not in (200, 201):
                resp.failure(f"Expected 200/201, got {resp.status_code}")
                return
            try:
                body = resp.json()
                assert body.get("status") == "success", \
                    f"status != success: {body.get('status')}"
                data = body.get("data", {})
                assert data.get("name") == payload["name"], \
                    "Returned name does not match payload"
                assert "id" in data, "No 'id' in create response"
                resp.success()
                log.debug("  POST /create → new id=%s", data.get("id"))
            except (AssertionError, ValueError, KeyError) as exc:
                resp.failure(str(exc))

    # ── PUT /api/v1/update/{id} ────────────────────────────
    @task(2)
    def update_employee(self):
        """TC-04 – Update an existing employee record."""
        emp_id  = 1
        payload = {
            "name"  : "Updated Locust User",
            "salary": "120000",
            "age"   : "35",
        }
        with self.client.put(
            f"/api/v1/update/{emp_id}",
            json=payload,
            name="PUT /update/{id}",
            catch_response=True,
        ) as resp:
            if resp.status_code != 200:
                resp.failure(f"Expected 200, got {resp.status_code}")
                return
            try:
                body = resp.json()
                assert body.get("status") == "success", \
                    f"status != success: {body.get('status')}"
                resp.success()
            except (AssertionError, ValueError, KeyError) as exc:
                resp.failure(str(exc))

    # ── DELETE /api/v1/delete/{id} ─────────────────────────
    @task(1)
    def delete_employee(self):
        """TC-05 – Delete an employee record (lowest weight)."""
        emp_id = 2
        with self.client.delete(
            f"/api/v1/delete/{emp_id}",
            name="DELETE /delete/{id}",
            catch_response=True,
        ) as resp:
            if resp.status_code != 200:
                resp.failure(f"Expected 200, got {resp.status_code}")
                return
            try:
                body = resp.json()
                assert body.get("status") == "success", \
                    f"status != success: {body.get('status')}"
                resp.success()
            except (AssertionError, ValueError, KeyError) as exc:
                resp.failure(str(exc))
