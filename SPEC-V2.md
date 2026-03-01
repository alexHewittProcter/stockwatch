# StockWatch v2 — AI-Powered Bloomberg Terminal

## Vision
Not just a price tracker — an AI-powered intelligence platform that combines institutional-grade market data with social sentiment, automated opportunity detection, and learning from successful trades.

---

## Core Pillars

### 1. 📊 Market Data (v1 — built)
- Real-time streaming via Finnhub WebSocket
- Yahoo Finance for bulk/historical/international
- Alpha Vantage for economic indicators + news sentiment
- 14 default dashboards (indices, sectors, commodities, crypto, forex, UK markets, economic)

### 2. 🏛️ Holder Intelligence (NEW)
Like Bloomberg's ownership data but with tracking and alerts.

**Features:**
- **Stock → Holders view**: For any stock, see institutional holders (13F filings), insider holdings, ETF exposure
- **Holder → Portfolio view**: Click any holder (e.g., Berkshire Hathaway, Citadel, Vanguard) and see ALL their positions
- **Holder tracking**: "Follow" a holder like you follow a stock — get alerts when they buy/sell
- **Change tracking**: Show quarter-over-quarter changes in positions (increased/decreased/new/exited)
- **Holder dashboard**: Grid of tracked holders with latest moves
- **Smart money signals**: When multiple tracked holders all buy the same stock = strong signal

**Data sources:**
- SEC EDGAR (13F filings, quarterly) — free, official
- Fintel.io API or OpenFIGI for institutional ownership
- SEC insider transactions (Form 4) — real-time insider buys/sells
- Yahoo Finance holder data as backup

### 3. 📈 Options & Volatility Intelligence (NEW)
Track leverage, options flow, and volatility to spot opportunities.

**Features:**
- **Options chain viewer**: Calls/puts, strike prices, expiry, volume, open interest
- **Unusual options activity**: Flag when volume >> open interest (someone knows something)
- **IV (Implied Volatility) tracking**: Track IV changes over time per stock
- **IV Rank/Percentile**: Where current IV sits vs historical range
- **Put/Call ratio tracking**: Bearish/bullish sentiment indicator
- **Options flow feed**: Real-time unusual options activity stream
- **Volatility dashboard**: VIX, sector volatility, most volatile movers

**Data sources:**
- Finnhub options data (premium)
- CBOE data
- Unusual Whales API or similar for options flow
- Alpha Vantage options endpoints

### 4. 🎯 Opportunity Engine (NEW)
The killer feature — AI-powered opportunity detection.

**Types of opportunities:**
- **Movement-based**: Stock moves X% in Y time, volume spike, breakout from range
- **Holder-based**: Major holder accumulating, insider buying cluster, 13F reveals new position
- **Options-based**: Unusual options activity, IV crush setup, put/call ratio extreme
- **Social-based**: WSB/4chan sentiment spike, trending ticker, meme stock signals
- **News-based**: Breaking news + sentiment shift, earnings surprise, analyst upgrade/downgrade
- **Pattern-based**: AI-detected patterns from successful past trades (see "Learn" feature)

**Condition builder:**
- Set custom conditions on any stock/commodity: "If oil drops below $65 AND Saudi production increases AND XOM insider buying > $1M → alert me"
- Visual condition builder (AND/OR logic, thresholds, timeframes)
- Backtest conditions against historical data
- Conditions can combine: price, volume, holder activity, options flow, news sentiment

**Opportunity feed:**
- Ranked by confidence/relevance
- Each opportunity shows: trigger conditions, supporting evidence, suggested position, risk level
- One-click to open research report or place trade

### 5. 🧠 AI "Learn" Feature (NEW)
After a successful trade, press "Learn" to have AI analyze what made it profitable.

**How it works:**
1. User closes a profitable trade → "Learn" button appears
2. AI analyzes the conditions leading up to and during the trade:
   - Price action patterns (breakout, reversal, momentum)
   - Volume patterns
   - Options activity at the time
   - News/sentiment at entry and exit
   - Holder activity around that period
   - Social media buzz
   - Macro conditions (interest rates, sector rotation)
3. AI generates a "Trade Pattern" report:
   - What conditions aligned to create the opportunity
   - Historical frequency of similar setups
   - Average return when these conditions repeat
   - Risk factors that could have gone wrong
4. Pattern is saved and used by the Opportunity Engine to find similar setups in the future
5. Over time, builds a personalized "edge library" of proven patterns

### 6. 📰 News & Intelligence Feed (NEW)
Aggregated financial news with AI-powered relevance scoring.

**Sources:**
- **RSS feeds**: Morning Brew, Bloomberg, Reuters, FT, CNBC, MarketWatch, Seeking Alpha
- **Social media**: Reddit (r/wallstreetbets, r/stocks, r/options, r/investing), 4chan (/biz/)
- **SEC filings**: Real-time 8-K, 10-K, 13F, insider transactions
- **Earnings**: Whisper numbers, earnings call transcripts
- **Analyst reports**: Upgrades/downgrades, price target changes

**Tabs:**
- **For You**: AI-curated based on your watchlist, tracked holders, and past interests
- **Trending**: Most discussed tickers across all sources
- **Opportunities**: News that creates actionable trading opportunities
- **Social Pulse**: Real-time sentiment from Reddit/4chan/Twitter with ticker extraction

**Features:**
- AI summarizes long articles into key points
- Sentiment scoring per article (bullish/bearish/neutral)
- Ticker auto-tagging — click any ticker mentioned to see its dashboard
- "Piggyback" alerts: When a known successful trader (tracked holder) makes a move that aligns with social sentiment

### 7. 📋 Research Reports (NEW)
Auto-generated when an opportunity is detected.

**Report contents:**
- Executive summary
- Opportunity thesis (why this trade makes sense)
- Supporting data (charts, holder changes, options flow, news)
- Risk analysis (what could go wrong)
- Suggested entry/exit points
- Position sizing recommendation based on risk tolerance
- Historical comparison (similar setups and their outcomes)
- Confidence score

**Storage:**
- All reports saved locally and searchable
- Tag reports by outcome (won/lost/pending)
- AI learns from report accuracy over time

### 8. 💹 Trading (v1 — built, needs expansion)
- Alpaca paper + live trading
- One-click trade from any opportunity or research report
- Portfolio analytics with P&L attribution
- Trade journal — auto-logged with entry conditions, thesis, outcome

---

## Tracking System

Everything is trackable in the same unified way:

| Entity | Track | Alerts |
|--------|-------|--------|
| Stock/Commodity | Price, volume, technicals | Price cross, volume spike, breakout |
| Holder | Portfolio changes, new positions | Buy/sell activity, new 13F filing |
| Options | IV, unusual activity, flow | Unusual volume, IV spike, put/call extreme |
| Sector | Rotation, relative strength | Sector breakout/breakdown |
| Social ticker | Mention frequency, sentiment | Trending spike, sentiment flip |
| News source | New articles | Breaking news on tracked tickers |

---

## Technical Architecture Additions

```
lib/
├── services/
│   ├── finnhub_service.dart          (real-time WebSocket)
│   ├── yahoo_finance_service.dart    (bulk data)
│   ├── alpha_vantage_service.dart    (economic/news)
│   ├── alpaca_service.dart           (trading)
│   ├── sec_edgar_service.dart        (13F, Form 4, filings) NEW
│   ├── options_service.dart          (options chain, flow) NEW
│   ├── news_aggregator_service.dart  (RSS, API feeds) NEW
│   ├── social_sentiment_service.dart (Reddit, 4chan scraping) NEW
│   ├── ai_analysis_service.dart      (opportunity detection, learn) NEW
│   ├── report_generator_service.dart (auto research reports) NEW
│   ├── notification_service.dart     (macOS notifications)
│   └── cache_service.dart            (SQLite + persistence)
├── screens/
│   ├── home_screen.dart
│   ├── dashboard_screen.dart
│   ├── stock_detail_screen.dart
│   ├── holder_screen.dart            NEW — holder portfolio view
│   ├── holder_tracking_screen.dart   NEW — tracked holders grid
│   ├── options_screen.dart           NEW — options chain + flow
│   ├── opportunities_screen.dart     NEW — opportunity feed
│   ├── condition_builder_screen.dart NEW — custom alert conditions
│   ├── news_feed_screen.dart         NEW — aggregated news
│   ├── reports_screen.dart           NEW — research reports
│   ├── trade_journal_screen.dart     NEW — trade history + learn
│   ├── portfolio_screen.dart
│   ├── alerts_screen.dart
│   └── settings_screen.dart
```

---

## Social Scraping Strategy

For Reddit/4chan/forum data:
- **Reddit**: Use Reddit API (free with account) or PRAW-style HTTP scraping
- **4chan**: /biz/ board JSON API (no auth needed: a]boards.4chan.org/biz/catalog.json)
- **Twitter/X**: Nitter instances or social search APIs
- **Browser automation**: For sources that need login, use headless browser with created accounts
- **NLP pipeline**: Extract tickers ($TSLA, AAPL mentions), classify sentiment, detect hype cycles

---

## Build Phases

### Phase 1: Complete v1 Foundation ⬅️ CURRENT
- Finish charts, caching, dashboard editor, keyboard shortcuts
- Portfolio + alerts screens
- Make it compile and run

### Phase 2: Holder Intelligence
- SEC EDGAR integration (13F parser, Form 4)
- Holder → Portfolio view
- Holder tracking + alerts
- Smart money signals

### Phase 3: Options & Volatility
- Options chain viewer
- Unusual options activity detection
- IV tracking + historical percentile
- Volatility dashboard

### Phase 4: News & Social Intelligence
- RSS aggregation pipeline
- Reddit/4chan scraping
- AI summarization + sentiment scoring
- "For You" personalized feed

### Phase 5: Opportunity Engine
- Condition builder UI
- Movement-based opportunity detection
- Combine signals (price + holder + options + social)
- Opportunity feed with ranking

### Phase 6: AI Learn + Reports
- Trade pattern analysis
- Auto-generated research reports
- Pattern library
- Backtest engine
- Confidence scoring

### Phase 7: Polish & Scale
- Persistent data sync
- Performance optimization for 100s of tracked symbols
- Menu bar widget
- Potential mobile companion app
