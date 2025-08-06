import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mycards/features/account/user_state_notifier.dart';
import 'package:mycards/features/account/profile_settings.dart';
import 'package:mycards/features/auth/presentation/phone_login/phone_login_view.dart';
import 'package:mycards/features/home/services/auth_service.dart';
import 'package:mycards/features/credits/credits_vm.dart';
import 'package:mycards/screens/transaction_history_screen.dart';
import 'package:mycards/widgets/loading_indicators/circular_loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateNotifierProvider);
    final userViewModel = ref.read(userStateNotifierProvider.notifier);
    final creditBalance = ref.watch(creditBalanceValueProvider);

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Custom App Bar
            Container(
              child: SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'My Account',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: userState.isLoading
                  ? Center(
                      child: CircularLoadingWidget(
                        colors: [
                          const Color(0xFFFF5722),
                          const Color(0xFFFF7043),
                          Colors.deepOrange,
                          Colors.deepOrangeAccent
                        ],
                        size: 60,
                      ),
                    )
                  : userState.user == null
                      ? Container(
                          margin: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(16.r),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.2)),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50.r),
                                  ),
                                  child: Icon(
                                    Icons.error_outline,
                                    size: 48.sp,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  userState.error ?? 'No user available',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Container(
                                  height: 40.h,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.red, Color(0xFFE57373)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        userViewModel.refreshUserData(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                    ),
                                    child: Text(
                                      'Retry',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 24.h),

                              // Profile Section Card
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(horizontal: 16.w),
                                padding: EdgeInsets.all(24.w),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFF3E0),
                                      Color(0xFFFFE0B2)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Profile Picture
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(50.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.orange.withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: userState.user!.profileImageUrl !=
                                              null
                                          ? ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: userState
                                                    .user!.profileImageUrl!,
                                                width: 90.r,
                                                height: 90.r,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  width: 90.r,
                                                  height: 90.r,
                                                  color: Colors.grey[300],
                                                  child: Center(
                                                    child:
                                                        CircularLoadingWidget(
                                                      colors: [
                                                        const Color(0xFFFF5722),
                                                        const Color(0xFFFF7043),
                                                        Colors.deepOrange,
                                                        Colors.deepOrangeAccent
                                                      ],
                                                      size: 25,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  width: 90.r,
                                                  height: 90.r,
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 45.sp,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.person,
                                              size: 45.sp,
                                              color: Colors.grey[600],
                                            ),
                                    ),

                                    SizedBox(height: 16.h),

                                    // User Name
                                    Text(
                                      userState.user!.name ??
                                          userState.user!.email ??
                                          "User",
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),

                                    SizedBox(height: 12.h),

                                    // Credit Balance Card
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                        border: Border.all(
                                            color:
                                                Colors.orange.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.account_balance_wallet,
                                            color: const Color(0xFFE65100),
                                            size: 18.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            "$creditBalance Credits",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFFE65100),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // Menu Items
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Column(
                                  children: [
                                    _buildMenuTile(
                                      icon: Icons.history,
                                      title: "Transaction History",
                                      subtitle: "View your recent transactions",
                                      onTap: () {
                                        // Navigate to Transaction History page
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const TransactionHistoryScreen()),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 12.h),
                                    _buildMenuTile(
                                      icon: Icons.settings,
                                      title: "Profile Settings",
                                      subtitle:
                                          "Edit your personal information",
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ProfileSettings()),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 12.h),
                                    _buildMenuTile(
                                      icon: Icons.help_outline,
                                      title: "Help & Support",
                                      subtitle: "Get help and contact support",
                                      onTap: () {
                                        // Navigate to Help page
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 40.h),

                              // Logout Button
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Container(
                                  width: double.infinity,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                        color: Colors.red.withOpacity(0.3)),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: userState.isLoading
                                        ? null
                                        : () async {
                                            await userViewModel.logout();
                                            await AuthService().signOut();
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const PhoneLoginView()),
                                              (route) => false,
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          color: Colors.red,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          "Log Out",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // Footer Links
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildFooterLink("Contact Us", () {}),
                                        _buildFooterLink(
                                            "Privacy Policy", () {}),
                                        _buildFooterLink(
                                            "Terms of Service", () {}),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE65100).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFE65100),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
