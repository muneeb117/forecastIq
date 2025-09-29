import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {


  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      body: SafeArea(
        child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset(
                            AppImages.left,
                            width: 24.w,
                            height: 24.h,
                          )
                      ),

                      Text(
                          'Privacy Policy',
                          style: AppTextStyles.ktwhite16500
                      ),
                      SizedBox()
                    ],
                  ),
                  22.verticalSpace,
                  Container(
                    height: 54.h,
                    decoration: BoxDecoration(
                      color: AppColors.ktertiary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTextStyles.kblack14500.copyWith(
                        color: AppColors.kwhite,
                      ),
                      textAlignVertical:
                      TextAlignVertical.center, // Center text vertically
                      decoration: InputDecoration(
                        hintText: 'Search ...',
                        hintStyle: AppTextStyles.kblack14500.copyWith(
                          color: AppColors.kwhite2,
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                            left: 20.w,
                            right: 12.w,
                          ), // Adjust icon padding
                          child: SvgPicture.asset(
                            AppImages.search,
                            width: 18.w,
                            height: 18.h,
                            color:
                            AppColors.kwhite, // Ensure icon color matches text
                            fit: BoxFit.contain, // Ensure proper scaling
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 18.w,
                          minHeight: 18.h,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16.h, // Adjust vertical padding for centering
                        ),
                      ),
                    ),
                  ),
                  32.verticalSpace,
                  Row(
                    children: [
                      SvgPicture.asset(AppImages.question,
                        width: 24.w,
                        height: 24.h,
                      ),
                      12.horizontalSpace,
                      Text("General Information",
                        style: AppTextStyles.kwhite16700,
                      )
                    ],
                  ),
                  10.verticalSpace,
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      title: Text("Why can't I register with my mobile number?",
                        style: AppTextStyles.kblack14700.copyWith(
                          color: AppColors.kwhite
                        ),
                      ),
                      iconColor: AppColors.kwhite,
                      collapsedIconColor: AppColors.kwhite,
                      showTrailingIcon: true,
                      tilePadding: EdgeInsets.zero,
                      textColor: AppColors.kwhite,
                      expandedAlignment: Alignment.centerLeft,
                      initiallyExpanded: true,
                      children: [
                        Text(
                          "Your mobile number may already be linked to an existing Np account. Mobile numbers can only be registered in 1 (one) Shopline account (same for email addresses).",
                          style: AppTextStyles.kblack14700.copyWith(
                              color: AppColors.kwhite
                          ),
                        )
                      ],
                    ),
                  ),
                  24.verticalSpace,
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      title: Text("How do I make a credit card bill payment?",
                        style: AppTextStyles.kblack14700.copyWith(
                            color: AppColors.kwhite
                        ),
                      ),
                      iconColor: AppColors.kwhite,
                      collapsedIconColor: AppColors.kwhite,
                      showTrailingIcon: true,
                      tilePadding: EdgeInsets.zero,
                      textColor: AppColors.kwhite,
                      expandedAlignment: Alignment.centerLeft,
                      initiallyExpanded: true,
                      children: [
                        Text(
                          "Quis placerat felis tincidunt dolor eget elemene euismod. ristique in cursus nisi est ut. At vel in pretium sed tincidunt integer. Vulputate vestibulum donec at nullam non. Mauris et morbi volutpat sed vestibulum, orci. Scelerisque arcu ipsum volutpat massa sagittis pharetra eget lacus. A velit fermentum mattis ac ultricies est, tellus turpis. Duis enim",
                          style: AppTextStyles.kblack14700.copyWith(
                              color: AppColors.kwhite
                          ),
                        )
                      ],
                    ),
                  )
                ]
            )
        ),
      ),
    );
  }

}