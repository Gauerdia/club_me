import '../discount.dart';

ClubMeDiscount parseClubMeDiscount(var data){

  return ClubMeDiscount(

      discountId: data['discount_id'],
      clubId: data['club_id'],
      clubName: data["club_name"],

      discountTitle: data["discount_title"],
      discountDate : DateTime.tryParse(data['discount_date'])!,
      discountDescription: data['discount_description'],

      numberOfUsages: data['number_of_usages'],
      bannerId: data['banner_id'],
      howOftenRedeemed: data['how_often_redeemed'],

      hasAgeLimit: data['has_age_limit'],
      hasUsageLimit: data['has_usage_limit'],
      hasTimeLimit: data['has_time_limit'],

      targetGender: data['target_gender'],
      priorityScore: data['priority_score'],

      ageLimitLowerLimit: data['age_limit_lower_limit'],
      ageLimitUpperLimit: data['age_limit_upper_limit'],

      isRepeatedDays: data['is_repeated_days'],
  );
}