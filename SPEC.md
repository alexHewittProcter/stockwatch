# StockWatch — Desktop App Specification

## Overview
A Flutter desktop app (macOS primary) for watching stocks, commodities, forex, and crypto with customizable dashboards, native notifications for significant market movements, and trading capabilities.

## APIs

### Data: Alpha Vantage (free tier to start)
- **Base URL**: `https://www.alphavantage.co/query`
- **Free tier**: 25 requests/day (upgrade later if needed)
- **Covers**: Stocks, commodities, forex, crypto, economic indicators, news/sentiment
- **Key endpoints**:
  - `GLOBAL_QUOTE` — real-time stock quote
  - `TIME_SERIES_INTRADAY` — intraday data (1/5/15/30/60 min)
  - `TIME_SERIES_DAILY` — daily historical
  - Commodities: WTI, Brent, natural gas, copper, aluminum, wheat, corn, cotton, sugar, coffee, gold, silver
  - `NEWS_SENTIMENT` — news with sentiment scores
  - `TOP_GAINERS_LOSERS` — market movers

### Trading: Alpaca Markets
- **Paper trading** (practice mode, no real money)
- **Live trading** (when ready, US stocks + crypto)
- **REST API + WebSocket** for real-time updates
- Supports: market/limit orders, long/short positions, fractional shares
- Free to sign up at alpaca.markets

### Alternative/Backup: Yahoo Finance (yfinance)
- Unofficial but widely used, good for bulk historical data
- Can supplement Alpha Vantage rate limits

## Architecture

```
stockwatch/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── models/
│   │   ├── stock.dart
│   │   ├── commodity.dart
│   │   ├── dashboard.dart
│   │   ├── alert.dart
│   │   ├── portfolio.dart
│   │   └── watchlist.dart
│   ├── services/
│   │   ├── alpha_vantage_service.dart
│   │   ├── alpaca_service.dart
│   │   ├── notification_service.dart
│   │   ├── cache_service.dart
│   │   └── dashboard_service.dart
│   ├── providers/
│   │   ├── market_provider.dart
│   │   ├── dashboard_provider.dart
│   │   ├── alert_provider.dart
│   │   └── portfolio_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── dashboard_editor_screen.dart
│   │   ├── stock_detail_screen.dart
│   │   ├── alerts_screen.dart
│   │   ├── portfolio_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── price_card.dart
│   │   ├── sparkline_chart.dart
│   │   ├── candlestick_chart.dart
│   │   ├── movement_indicator.dart
│   │   ├── dashboard_grid.dart
│   │   ├── news_feed.dart
│   │   └── order_panel.dart
│   └── theme/
│       └── app_theme.dart (dark mode, financial UI style)
├── assets/
├── macos/
├── test/
└── pubspec.yaml
```

## Features

### 1. Dashboards
- **Custom dashboards**: Create/edit/delete, drag-drop layout of widgets
- **Widget types**: Price card, sparkline, candlestick chart, news feed, movement %, sector heatmap
- **Default dashboards** (pre-built, read-only but cloneable):

#### Default Dashboard Index:

**📈 Major Indices**
- S&P 500, Dow Jones, NASDAQ, FTSE 100, DAX, Nikkei 225, Hang Seng, ASX 200

**🏢 US Tech Giants (FAANG+)**
- AAPL, GOOGL, AMZN, META, MSFT, NVDA, TSLA, NFLX

**🏦 Banking & Finance**
- JPM, GS, MS, BAC, HSBA.L, BCS, C, WFC

**⚡ Energy**
- XOM, CVX, SHEL, BP, COP, TTE, ENB, SLB

**🏥 Healthcare & Pharma**
- JNJ, PFE, UNH, ABBV, MRK, LLY, TMO, ABT

**🛡️ Defence & Aerospace**
- LMT, RTX, BA, NOC, GD, BAE.L, HII, LHX

**🥇 Precious Metals**
- Gold (XAU), Silver (XAG), Platinum, Palladium

**⛽ Energy Commodities**
- WTI Crude, Brent Crude, Natural Gas, Heating Oil

**🌾 Agricultural**
- Wheat, Corn, Soybeans, Coffee, Sugar, Cotton, Cocoa, Rice

**🏗️ Industrial Metals**
- Copper, Aluminum, Zinc, Nickel, Iron Ore, Steel

**💱 Major Forex Pairs**
- EUR/USD, GBP/USD, USD/JPY, AUD/USD, USD/CHF, USD/CAD

**₿ Crypto**
- BTC, ETH, SOL, ADA, XRP, DOT, AVAX, MATIC

**🇬🇧 UK Markets (FTSE)**
- AZN.L, SHEL.L, HSBA.L, ULVR.L, GSK.L, DGE.L, RIO.L, BP.L

**📊 Economic Indicators**
- US GDP, CPI, Federal Funds Rate, 10Y Treasury, Unemployment Rate, Retail Sales

### 2. Alerts & Notifications
- **Price alerts**: Notify when a symbol crosses above/below a threshold
- **Movement alerts**: Notify on X% move in Y timeframe (e.g., >5% daily move)
- **Sector alerts**: Notify when an entire sector moves significantly
- **macOS native notifications** via `flutter_local_notifications` or `macos_ui`
- **Menu bar indicator**: Optional persistent icon showing portfolio P&L or index movement

### 3. Trading (Alpaca Integration)
- **Paper trading by default** (safe practice mode)
- **Order types**: Market, limit, stop, stop-limit
- **Positions**: Long and short
- **Portfolio view**: Current holdings, P&L, allocation chart
- **Order history**: Past trades with P&L
- Switch between paper and live via settings

### 4. UI/UX
- **Dark theme** (Bloomberg-terminal inspired, dark bg with green/red accents)
- **Sidebar navigation**: Dashboards, Watchlists, Portfolio, Alerts, Settings
- **Responsive grid**: Dashboard widgets resize and reflow
- **Charts**: Candlestick + line charts via `fl_chart` or `syncfusion_flutter_charts`
- **Keyboard shortcuts**: Quick search (Cmd+K), refresh (Cmd+R)

### 5. Data Management
- **Local SQLite cache** for historical data (don't re-fetch what we have)
- **Smart rate limiting**: Queue API calls, respect Alpha Vantage limits
- **Background polling**: Refresh active dashboard every 60s during market hours
- **Offline mode**: Show cached data when no connection

## Tech Stack
- **Flutter 3.x** (desktop, macOS target)
- **State management**: Riverpod (or Provider)
- **Charts**: fl_chart + candlesticks package
- **Local storage**: SQLite via sqflite/drift
- **HTTP**: dio
- **Notifications**: flutter_local_notifications (macOS)
- **Theme**: Custom dark theme

## Setup
1. Get free Alpha Vantage API key: https://www.alphavantage.co/support/#api-key
2. Sign up for Alpaca paper trading: https://alpaca.markets
3. Add keys to Settings screen (stored locally, encrypted)

## Git
- Repo: github.com/aajhp (Alex's personal GitHub)
- Author: Alex Hewitt-Procter <alexhp@hotmail.co.uk>
