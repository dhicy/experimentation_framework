*** Variables ***
# ─── Base URLs ────────────────────────────────────────────────────────────────
${BASE_URL}                 https://indodax.com
${PUBLIC_API_BASE}          ${BASE_URL}/api
${TICKER_API_BASE}          ${BASE_URL}/api
${CHART_API_BASE}           ${BASE_URL}/api
${SERVER_TIME_URL}          ${PUBLIC_API_BASE}/server_time
${PAIRS_URL}                ${PUBLIC_API_BASE}/pairs
${SUMMARIES_URL}            ${PUBLIC_API_BASE}/summaries

# ─── Request Configuration ────────────────────────────────────────────────────
${REQUEST_TIMEOUT}          30
${DEFAULT_HEADERS}          Content-Type=application/json

# ─── Common HTTP Status Codes ─────────────────────────────────────────────────
${HTTP_200}                 200
${HTTP_400}                 400
${HTTP_401}                 401
${HTTP_404}                 404
${HTTP_429}                 429
${HTTP_500}                 500

# ─── Retry Config ─────────────────────────────────────────────────────────────
${RETRY_COUNT}              3
${RETRY_INTERVAL}           2s

# ─── Well-known Trading Pairs ─────────────────────────────────────────────────
${PAIR_BTC_IDR}             btcidr
${PAIR_ETH_IDR}             ethidr
${PAIR_USDT_IDR}            usdtidr
${PAIR_BNB_IDR}             bnbidr
${PAIR_SOL_IDR}             solidr
${INVALID_PAIR}             invalidpair999

# ─── Numeric Validation Thresholds ───────────────────────────────────────────
${MIN_PRICE}                0
${MAX_SPREAD_PERCENT}       50
