import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';
import '../core/constants/images.dart';
import '../widgets/custom_button.dart';

class CoinDetailScreen extends StatefulWidget {
  final String? image;
  final String symbol;
  final String name;
  final String percentage;
  final bool isUp;
  final String price;

  const CoinDetailScreen({
    super.key,
    this.image,
    required this.symbol,
    required this.name,
    required this.percentage,
    required this.isUp,
    required this.price,
  });

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  int _selectedTimeFrame = 0;
  final List<String> _timeFrames = ['1D', '7D', '1M', '1Y', '5Y'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: SvgPicture.asset(
                        AppImages.left,
                        width: 24.w,
                        height: 24.h,
                      )
                    ),
                    Text(
                      widget.name,
                      style: AppTextStyles.ktwhite16600,
                    ),
                    SvgPicture.asset(
                      AppImages.heart,
                      width: 24.w,
                      height: 24.h,
                    )
                  ],
                ),
              ),
              21.verticalSpace,

              Column(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: widget.image == null ? AppColors.kprimary : Colors.transparent,
                    child: widget.image != null
                        ? Image.asset(
                            widget.image!,
                            width: 60.w,
                            height: 60.h,
                          )
                        : Text(
                            widget.symbol.substring(0, 1),
                            style: AppTextStyles.ktwhite16600.copyWith(
                              color: AppColors.kwhite,
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  
                  46.verticalSpace,
                  
                  // Percentage Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: widget.isUp
                          ? AppColors.kgreen.withValues(alpha: 0.16)
                          : AppColors.kred.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          widget.isUp ? AppImages.arrowup : AppImages.arrowdown,
                          width: 24.w,
                          height: 16.h,
                        ),
                        4.horizontalSpace,
                        Text(
                          widget.percentage,
                          style: AppTextStyles.ktwhite14500.copyWith(
                            color: widget.isUp ? AppColors.kgreen : AppColors.kred,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              21.verticalSpace,
              
              // Chart Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.ksecondary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10.w,
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: AppColors.kwhite.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Past',
                              style: AppTextStyles.ktwhite16400,
                            ),
                          ],
                        ),
                        SizedBox(width: 24.w),
                        Row(
                          children: [
                            Container(
                              width: 10.w,
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: AppColors.kprimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Future',
                              style: AppTextStyles.ktwhite16400,
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Price Labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$3,019.32',
                          style: AppTextStyles.ktwhite12500.copyWith(
                            color: AppColors.kred,
                          ),
                        ),
                        Text(
                          '\$3,276.21',
                          style: AppTextStyles.ktwhite12500.copyWith(
                            color: AppColors.kgreen,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Chart Placeholder (you can replace with actual chart)
                    Container(
                      height: 120.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: CustomPaint(
                        size: Size(double.infinity, 120.h),
                        painter: ChartPainter(isUp: widget.isUp),
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Time Frame Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _timeFrames.asMap().entries.map((entry) {
                        int index = entry.key;
                        String timeFrame = entry.value;
                        bool isSelected = _selectedTimeFrame == index;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTimeFrame = index;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.kprimary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              timeFrame,
                              style: AppTextStyles.ktwhite14500.copyWith(
                                color: isSelected ? AppColors.kwhite : AppColors.kwhite,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Save and Refresh Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: AppColors.ktertiary,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.ktertiary,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AppImages.save,
                                width: 18.w,
                                height: 18.h,
                              ),
                              SizedBox(width: 7.19.w),
                              Text(
                                'Save',
                                style: AppTextStyles.ktwhite14400,
                              ),
                            ],
                          ),
                        ),
                        8.horizontalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: AppColors.ktertiary,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.ktertiary,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AppImages.rotate,
                                width: 18.w,
                                height: 18.h,
                              ),
                              SizedBox(width: 7.19.w),
                              Text(
                                'Refresh',
                                style: AppTextStyles.ktwhite14400,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              21.verticalSpace,
              
              // Forecast Details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    // Forecast Direction and Confidence Score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Forecast Direction',
                                style: AppTextStyles.ktwhite14500.copyWith(
                                  color: AppColors.kwhite2,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    widget.isUp ? AppImages.arrowup : AppImages.arrowdown,
                                    width: 24.w,
                                    height: 24.h,
                                  ),
                                  4.horizontalSpace,
                                  Text(
                                    widget.isUp ? 'UP' : 'DOWN',
                                    style: AppTextStyles.kwhite16700.copyWith(
                                      color: widget.isUp ? AppColors.kgreen : AppColors.kred,
                                    ),
                                  ),
                                  16.horizontalSpace,
                                  SvgPicture.asset(
                                    widget.isUp ? AppImages.forcastup : AppImages.forcastdown,
                                    width: 74.w,
                                    height: 56.h,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Confidence Score',
                              style: AppTextStyles.ktwhite14500.copyWith(
                                color: AppColors.kwhite2,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                color: widget.isUp ? AppColors.kgreen.withValues(alpha: 0.16) : AppColors.kred.withValues(alpha: 0.16),
                              ),
                              child: Text(
                                '86%',
                                style: AppTextStyles.kwhite16700.copyWith(
                                  color: widget.isUp ? AppColors.kgreen : AppColors.kred,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Predicted and Last Updated
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Predicted',
                            style: AppTextStyles.ktwhite14500.copyWith(
                          color: AppColors.kwhite2,
                          ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                widget.price,
                                style: AppTextStyles.ktwhite14600,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Last Updated',
                                style: AppTextStyles.ktwhite14500.copyWith(
                                  color: AppColors.kwhite2,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '23 July 2025 | 12: 45PM',
                                style: AppTextStyles.ktwhite14600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32.h),


              Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h,horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(100.r),
                      border: Border.all(
                        color: AppColors.kwhite.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppImages.rotate,
                          width: 24.w,
                          height: 24.h,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Refresh',
                          style: AppTextStyles.ktwhite14500,
                        ),
                      ],
                    ),
                  ),

              
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final bool isUp;

  ChartPainter({required this.isUp});

  @override
  void paint(Canvas canvas, Size size) {
    // Past data (grey line)
    final pastPaint = Paint()
      ..color = Colors.grey.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Future data (teal line)
    final futurePaint = Paint()
      ..color = AppColors.kprimary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Create the complex chart pattern similar to the reference image
    final pastPath = Path();
    final futurePath = Path();

    // Define key points for the past data (left 50% of the chart)
    final pastPoints = [
      Offset(0, size.height * 0.7),              // Start point
      Offset(size.width * 0.06, size.height * 0.8),  // Dip
      Offset(size.width * 0.12, size.height * 0.3),  // First peak
      Offset(size.width * 0.18, size.height * 0.6),  // Valley
      Offset(size.width * 0.24, size.height * 0.2),  // Second peak
      Offset(size.width * 0.30, size.height * 0.7),  // Valley
      Offset(size.width * 0.36, size.height * 0.4),  // Peak
      Offset(size.width * 0.42, size.height * 0.8),  // Valley
      Offset(size.width * 0.50, size.height * 0.5),  // Connection point
    ];

    // Create smooth curves for past data
    pastPath.moveTo(pastPoints[0].dx, pastPoints[0].dy);

    for (int i = 0; i < pastPoints.length - 1; i++) {
      final current = pastPoints[i];
      final next = pastPoints[i + 1];

      // Create control points for smooth curves
      final controlPoint1 = Offset(
        current.dx + (next.dx - current.dx) * 0.4,
        current.dy,
      );
      final controlPoint2 = Offset(
        current.dx + (next.dx - current.dx) * 0.6,
        next.dy,
      );

      pastPath.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        next.dx, next.dy,
      );
    }

    // Define key points for future data (right 50% of the chart)
    final futureStartY = size.height * 0.5;
    List<Offset> futurePoints;

    if (isUp) {
      // Upward trend for future prediction
      futurePoints = [
        Offset(size.width * 0.50, futureStartY),        // Connection point
        Offset(size.width * 0.56, size.height * 0.6),   // Slight dip
        Offset(size.width * 0.62, size.height * 0.3),   // Rise
        Offset(size.width * 0.68, size.height * 0.4),   // Small dip
        Offset(size.width * 0.74, size.height * 0.1),   // High peak
        Offset(size.width * 0.80, size.height * 0.3),   // Valley
        Offset(size.width * 0.86, size.height * 0.05),  // Highest peak
        Offset(size.width * 0.92, size.height * 0.2),   // Small valley
        Offset(size.width * 1.0, size.height * 0.1),    // End high
      ];
    } else {
      // Downward trend for future prediction
      futurePoints = [
        Offset(size.width * 0.50, futureStartY),        // Connection point
        Offset(size.width * 0.56, size.height * 0.4),   // Slight rise
        Offset(size.width * 0.62, size.height * 0.7),   // Decline
        Offset(size.width * 0.68, size.height * 0.6),   // Small rise
        Offset(size.width * 0.74, size.height * 0.9),   // Low dip
        Offset(size.width * 0.80, size.height * 0.7),   // Peak
        Offset(size.width * 0.86, size.height * 0.95),  // Lowest point
        Offset(size.width * 0.92, size.height * 0.8),   // Small peak
        Offset(size.width * 1.0, size.height * 0.9),    // End low
      ];
    }

    // Create smooth curves for future data
    futurePath.moveTo(futurePoints[0].dx, futurePoints[0].dy);

    for (int i = 0; i < futurePoints.length - 1; i++) {
      final current = futurePoints[i];
      final next = futurePoints[i + 1];

      // Create control points for smooth curves
      final controlPoint1 = Offset(
        current.dx + (next.dx - current.dx) * 0.4,
        current.dy,
      );
      final controlPoint2 = Offset(
        current.dx + (next.dx - current.dx) * 0.6,
        next.dy,
      );

      futurePath.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        next.dx, next.dy,
      );
    }

    // Draw the paths
    canvas.drawPath(pastPath, pastPaint);
    canvas.drawPath(futurePath, futurePaint);

    // Optional: Add dots at key connection points for visual emphasis
    final dotPaint = Paint()
      ..style = PaintingStyle.fill;

    // Connection point dot
    dotPaint.color = Colors.grey.withOpacity(0.8);
    canvas.drawCircle(
      Offset(size.width * 0.5, futureStartY),
      3.0,
      dotPaint,
    );

    // End point dots
    dotPaint.color = AppColors.kprimary;
    final endPoint = futurePoints.last;
    canvas.drawCircle(endPoint, 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}