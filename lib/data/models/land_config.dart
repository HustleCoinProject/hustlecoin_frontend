class LandConfig {
  final int landPrice;
  final int landSellPrice;
  final int landIncomePerDay;
  final bool incomeAccumulate;
  final int cooldownHours;

  LandConfig({
    required this.landPrice,
    required this.landSellPrice,
    required this.landIncomePerDay,
    required this.incomeAccumulate,
    required this.cooldownHours,
  });

  factory LandConfig.fromJson(Map<String, dynamic> json) {
    return LandConfig(
      landPrice: json['land_price'] ?? 500,
      landSellPrice: json['land_sell_price'] ?? 400,
      landIncomePerDay: json['land_income_per_day'] ?? 50,
      incomeAccumulate: json['income_accumulate'] ?? false,
      cooldownHours: json['cooldown_hours'] ?? 24,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'land_price': landPrice,
      'land_sell_price': landSellPrice,
      'land_income_per_day': landIncomePerDay,
      'income_accumulate': incomeAccumulate,
      'cooldown_hours': cooldownHours,
    };
  }
}
