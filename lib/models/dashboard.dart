import 'package:json_annotation/json_annotation.dart';

part 'dashboard.g.dart';

@JsonSerializable()
class Dashboard {
  final String id;
  final String name;
  final String description;
  final List<DashboardWidget> widgets;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Dashboard({
    required this.id,
    required this.name,
    required this.description,
    required this.widgets,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) => _$DashboardFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardToJson(this);

  Dashboard copyWith({
    String? id,
    String? name,
    String? description,
    List<DashboardWidget>? widgets,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dashboard(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      widgets: widgets ?? this.widgets,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class DashboardWidget {
  final String id;
  final DashboardWidgetType type;
  final String title;
  final List<String> symbols;
  final DashboardWidgetPosition position;
  final DashboardWidgetSize size;
  final Map<String, dynamic> config;

  const DashboardWidget({
    required this.id,
    required this.type,
    required this.title,
    required this.symbols,
    required this.position,
    required this.size,
    this.config = const {},
  });

  factory DashboardWidget.fromJson(Map<String, dynamic> json) => _$DashboardWidgetFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardWidgetToJson(this);

  DashboardWidget copyWith({
    String? id,
    DashboardWidgetType? type,
    String? title,
    List<String>? symbols,
    DashboardWidgetPosition? position,
    DashboardWidgetSize? size,
    Map<String, dynamic>? config,
  }) {
    return DashboardWidget(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      symbols: symbols ?? this.symbols,
      position: position ?? this.position,
      size: size ?? this.size,
      config: config ?? this.config,
    );
  }
}

@JsonSerializable()
class DashboardWidgetPosition {
  final int row;
  final int column;

  const DashboardWidgetPosition({
    required this.row,
    required this.column,
  });

  factory DashboardWidgetPosition.fromJson(Map<String, dynamic> json) =>
      _$DashboardWidgetPositionFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardWidgetPositionToJson(this);
}

@JsonSerializable()
class DashboardWidgetSize {
  final int width;
  final int height;

  const DashboardWidgetSize({
    required this.width,
    required this.height,
  });

  factory DashboardWidgetSize.fromJson(Map<String, dynamic> json) =>
      _$DashboardWidgetSizeFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardWidgetSizeToJson(this);
}

enum DashboardWidgetType {
  @JsonValue('price_card')
  priceCard,
  @JsonValue('sparkline')
  sparkline,
  @JsonValue('candlestick')
  candlestick,
  @JsonValue('news_feed')
  newsFeed,
  @JsonValue('movement_list')
  movementList,
  @JsonValue('sector_heatmap')
  sectorHeatmap,
  @JsonValue('portfolio_summary')
  portfolioSummary,
}

// Default dashboard configurations
class DefaultDashboards {
  static final List<Dashboard> all = [
    _majorIndices,
    _usTechGiants,
    _bankingFinance,
    _energy,
    _healthcarePharma,
    _defenseAerospace,
    _preciousMetals,
    _energyCommodities,
    _agricultural,
    _industrialMetals,
    _majorForex,
    _crypto,
    _ukMarkets,
    _economicIndicators,
  ];

  static final Dashboard _majorIndices = Dashboard(
    id: 'major_indices',
    name: '📈 Major Indices',
    description: 'Global stock market indices',
    widgets: [
      DashboardWidget(
        id: 'spx_card',
        type: DashboardWidgetType.priceCard,
        title: 'S&P 500',
        symbols: ['SPX'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
      DashboardWidget(
        id: 'dow_card',
        type: DashboardWidgetType.priceCard,
        title: 'Dow Jones',
        symbols: ['DJI'],
        position: const DashboardWidgetPosition(row: 0, column: 2),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
      DashboardWidget(
        id: 'nasdaq_card',
        type: DashboardWidgetType.priceCard,
        title: 'NASDAQ',
        symbols: ['IXIC'],
        position: const DashboardWidgetPosition(row: 1, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
      DashboardWidget(
        id: 'ftse_card',
        type: DashboardWidgetType.priceCard,
        title: 'FTSE 100',
        symbols: ['UKX'],
        position: const DashboardWidgetPosition(row: 1, column: 2),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final Dashboard _usTechGiants = Dashboard(
    id: 'us_tech_giants',
    name: '🏢 US Tech Giants (FAANG+)',
    description: 'Major technology companies',
    widgets: [
      DashboardWidget(
        id: 'aapl_card',
        type: DashboardWidgetType.priceCard,
        title: 'Apple',
        symbols: ['AAPL'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
      DashboardWidget(
        id: 'googl_card',
        type: DashboardWidgetType.priceCard,
        title: 'Google',
        symbols: ['GOOGL'],
        position: const DashboardWidgetPosition(row: 0, column: 2),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
      DashboardWidget(
        id: 'msft_card',
        type: DashboardWidgetType.priceCard,
        title: 'Microsoft',
        symbols: ['MSFT'],
        position: const DashboardWidgetPosition(row: 1, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
      DashboardWidget(
        id: 'nvda_card',
        type: DashboardWidgetType.priceCard,
        title: 'NVIDIA',
        symbols: ['NVDA'],
        position: const DashboardWidgetPosition(row: 1, column: 2),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // Additional default dashboards would be defined similarly...
  static final Dashboard _bankingFinance = Dashboard(
    id: 'banking_finance',
    name: '🏦 Banking & Finance',
    description: 'Financial sector stocks',
    widgets: [
      DashboardWidget(
        id: 'jpm_card',
        type: DashboardWidgetType.priceCard,
        title: 'JPMorgan Chase',
        symbols: ['JPM'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
      DashboardWidget(
        id: 'gs_card',
        type: DashboardWidgetType.priceCard,
        title: 'Goldman Sachs',
        symbols: ['GS'],
        position: const DashboardWidgetPosition(row: 0, column: 2),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final Dashboard _energy = Dashboard(
    id: 'energy',
    name: '⚡ Energy',
    description: 'Energy sector stocks',
    widgets: [
      DashboardWidget(
        id: 'xom_card',
        type: DashboardWidgetType.priceCard,
        title: 'Exxon Mobil',
        symbols: ['XOM'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final Dashboard _healthcarePharma = Dashboard(
    id: 'healthcare_pharma',
    name: '🏥 Healthcare & Pharma',
    description: 'Healthcare and pharmaceutical companies',
    widgets: [
      DashboardWidget(
        id: 'jnj_card',
        type: DashboardWidgetType.priceCard,
        title: 'Johnson & Johnson',
        symbols: ['JNJ'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final Dashboard _defenseAerospace = Dashboard(
    id: 'defense_aerospace',
    name: '🛡️ Defence & Aerospace',
    description: 'Defense and aerospace companies',
    widgets: [
      DashboardWidget(
        id: 'lmt_card',
        type: DashboardWidgetType.priceCard,
        title: 'Lockheed Martin',
        symbols: ['LMT'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final Dashboard _preciousMetals = Dashboard(
    id: 'precious_metals',
    name: '🥇 Precious Metals',
    description: 'Gold, silver, and other precious metals',
    widgets: [
      DashboardWidget(
        id: 'gold_card',
        type: DashboardWidgetType.priceCard,
        title: 'Gold',
        symbols: ['XAUUSD'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final Dashboard _energyCommodities = Dashboard(
    id: 'energy_commodities',
    name: '⛽ Energy Commodities',
    description: 'Oil, gas, and energy commodities',
    widgets: [
      DashboardWidget(
        id: 'oil_card',
        type: DashboardWidgetType.priceCard,
        title: 'WTI Crude',
        symbols: ['CL=F'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final Dashboard _agricultural = Dashboard(
    id: 'agricultural',
    name: '🌾 Agricultural',
    description: 'Agricultural commodities',
    widgets: [
      DashboardWidget(
        id: 'wheat_card',
        type: DashboardWidgetType.priceCard,
        title: 'Wheat',
        symbols: ['ZW=F'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final Dashboard _industrialMetals = Dashboard(
    id: 'industrial_metals',
    name: '🏗️ Industrial Metals',
    description: 'Copper, aluminum, and industrial metals',
    widgets: [
      DashboardWidget(
        id: 'copper_card',
        type: DashboardWidgetType.priceCard,
        title: 'Copper',
        symbols: ['HG=F'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final Dashboard _majorForex = Dashboard(
    id: 'major_forex',
    name: '💱 Major Forex Pairs',
    description: 'Major currency pairs',
    widgets: [
      DashboardWidget(
        id: 'eurusd_card',
        type: DashboardWidgetType.priceCard,
        title: 'EUR/USD',
        symbols: ['EURUSD=X'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final Dashboard _crypto = Dashboard(
    id: 'crypto',
    name: '₿ Crypto',
    description: 'Cryptocurrency prices',
    widgets: [
      DashboardWidget(
        id: 'btc_card',
        type: DashboardWidgetType.priceCard,
        title: 'Bitcoin',
        symbols: ['BTC-USD'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final Dashboard _ukMarkets = Dashboard(
    id: 'uk_markets',
    name: '🇬🇧 UK Markets (FTSE)',
    description: 'UK stock market',
    widgets: [
      DashboardWidget(
        id: 'azn_card',
        type: DashboardWidgetType.priceCard,
        title: 'AstraZeneca',
        symbols: ['AZN.L'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final Dashboard _economicIndicators = Dashboard(
    id: 'economic_indicators',
    name: '📊 Economic Indicators',
    description: 'Economic data and indicators',
    widgets: [
      DashboardWidget(
        id: 'gdp_card',
        type: DashboardWidgetType.priceCard,
        title: 'US GDP',
        symbols: ['GDP'],
        position: const DashboardWidgetPosition(row: 0, column: 0),
        size: const DashboardWidgetSize(width: 2, height: 1),
      ),
    ],
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}