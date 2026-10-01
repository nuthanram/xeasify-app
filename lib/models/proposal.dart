class Proposal {
  final String id;
  final String campaign;
  final String creator;
  final String pitch;
  final double bidAmount;
  final String status;
  final int forecastedReach;
  final double forecastedRoiIndex;
  final DateTime submittedAt;

  const Proposal({
    required this.id,
    required this.campaign,
    required this.creator,
    required this.pitch,
    required this.bidAmount,
    required this.status,
    required this.forecastedReach,
    required this.forecastedRoiIndex,
    required this.submittedAt,
  });

  factory Proposal.fromJson(Map<String, dynamic> j) => Proposal(
        id: j['id'] as String,
        campaign: j['campaign'] as String? ?? '',
        creator: j['creator'] as String? ?? '',
        pitch: j['pitch'] as String? ?? '',
        bidAmount:
            double.tryParse(j['bid_amount']?.toString() ?? '0') ?? 0,
        status: j['status'] as String? ?? '',
        forecastedReach: j['forecasted_reach'] as int? ?? 0,
        forecastedRoiIndex:
            double.tryParse(j['forecasted_roi_index']?.toString() ?? '0') ??
                0,
        submittedAt:
            DateTime.tryParse(j['submitted_at'] as String? ?? '') ??
                DateTime.now(),
      );
}
