class Campaign {
  final String id;
  final String title;
  final String description;
  final String deliverableType;
  final double budgetTotal;
  final double budgetPerCreator;
  final int maxCreators;
  final String status;
  final bool escrowFunded;
  final bool isFlashCampaign;
  final int flashRadiusKm;
  final String? applicationDeadline;
  final String? campaignStart;
  final String? campaignEnd;
  final String? couponCode;
  final DateTime createdAt;

  const Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.deliverableType,
    required this.budgetTotal,
    required this.budgetPerCreator,
    required this.maxCreators,
    required this.status,
    required this.escrowFunded,
    required this.isFlashCampaign,
    required this.flashRadiusKm,
    this.applicationDeadline,
    this.campaignStart,
    this.campaignEnd,
    this.couponCode,
    required this.createdAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> j) => Campaign(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        deliverableType: j['deliverable_type'] as String? ?? '',
        budgetTotal:
            double.tryParse(j['budget_total']?.toString() ?? '0') ?? 0,
        budgetPerCreator:
            double.tryParse(j['budget_per_creator']?.toString() ?? '0') ?? 0,
        maxCreators: j['max_creators'] as int? ?? 1,
        status: j['status'] as String? ?? '',
        escrowFunded: j['escrow_funded'] as bool? ?? false,
        isFlashCampaign: j['is_flash_campaign'] as bool? ?? false,
        flashRadiusKm: j['flash_radius_km'] as int? ?? 5,
        applicationDeadline: j['application_deadline'] as String?,
        campaignStart: j['campaign_start'] as String?,
        campaignEnd: j['campaign_end'] as String?,
        couponCode: j['coupon_code'] as String?,
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}
