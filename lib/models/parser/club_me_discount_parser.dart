import '../discount.dart';

ClubMeDiscount parseClubMeDiscount(var data){
  return ClubMeDiscount(
      discountId: data['discount_id'],
      discountTitle: data["discount_title"],
      discountDate : DateTime.tryParse(data['discount_date'])!,
      clubName: data["club_name"],
      numberOfUsages: data['number_of_usages'],
      bannerId: data['banner_id'],
      howOftenRedeemed: data['how_often_redeemed'],
      clubId: data['club_id'],
      hasUsageLimit: data['has_usage_limit'],
      hasTimeLimit: data['has_time_limit'],
      discountDescription: data['discount_description'],
      targetGender: data['target_gender'],
      targetAge: data['target_age'],
      targetAgeIsUpperLimit: data['target_age_is_upper_limit'],
      priorityScore: data['priority_score']
  );
}