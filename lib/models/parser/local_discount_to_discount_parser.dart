import 'package:club_me/models/club_me_local_discount.dart';
import 'package:club_me/models/discount.dart';

ClubMeDiscount localDiscountToDiscountParser(ClubMeLocalDiscount clubMeLocalDiscount){
  return ClubMeDiscount(

      discountId: clubMeLocalDiscount.getDiscountId(),
      clubId: clubMeLocalDiscount.getClubId(),
      clubName: clubMeLocalDiscount.getClubName(),
      bannerId: clubMeLocalDiscount.getBannerId(),

      discountTitle: clubMeLocalDiscount.getDiscountTitle(),
      discountDate: clubMeLocalDiscount.getDiscountDate(),
      discountDescription: clubMeLocalDiscount.getDiscountDescription(),

      hasTimeLimit: clubMeLocalDiscount.getHasTimeLimit(),
      hasUsageLimit: clubMeLocalDiscount.getHasUsageLimit(),
      hasAgeLimit: clubMeLocalDiscount.getHasAgeLimit(),

      numberOfUsages: clubMeLocalDiscount.getNumberOfUsages(),
      howOftenRedeemed: clubMeLocalDiscount.getHowOftenRedeemed(),


      targetGender: clubMeLocalDiscount.getTargetGender(),
      priorityScore: clubMeLocalDiscount.getPriorityScore(),
      isRepeatedDays: clubMeLocalDiscount.getIsRepeatedDays(),

      ageLimitLowerLimit: clubMeLocalDiscount.getAgeLimitLowerLimit(),
      ageLimitUpperLimit: clubMeLocalDiscount.getAgeLimitUpperLimit(),
  );
}