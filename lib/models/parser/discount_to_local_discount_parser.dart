import 'package:club_me/models/discount.dart';

import '../hive_models/2_club_me_local_discount.dart';

ClubMeLocalDiscount discountToLocalDiscountParser(ClubMeDiscount clubMeDiscount){
  return ClubMeLocalDiscount(

      discountId: clubMeDiscount.getDiscountId(),
      clubId: clubMeDiscount.getClubId(),
      clubName: clubMeDiscount.getClubName(),

      discountTitle: clubMeDiscount.getDiscountTitle(),
      discountDate: clubMeDiscount.getDiscountDate(),
      discountDescription: clubMeDiscount.getDiscountDescription(),

      hasTimeLimit: clubMeDiscount.getHasTimeLimit(),
      hasUsageLimit: clubMeDiscount.getHasUsageLimit(),
      hasAgeLimit: clubMeDiscount.getHasAgeLimit(),

      numberOfUsages: clubMeDiscount.getNumberOfUsages(),

      bannerId: clubMeDiscount.getBannerId(),
      howOftenRedeemed: clubMeDiscount.getHowOftenRedeemed(),
      isRepeatedDays: clubMeDiscount.getIsRepeatedDays(),

      targetGender: clubMeDiscount.getTargetGender(),
      priorityScore: clubMeDiscount.getPriorityScore(),

      ageLimitUpperLimit: clubMeDiscount.getAgeLimitUpperLimit(),
      ageLimitLowerLimit: clubMeDiscount.getAgeLimitLowerLimit(),
    bigBannerFileName: clubMeDiscount.getBigBannerFileName()
  );
}