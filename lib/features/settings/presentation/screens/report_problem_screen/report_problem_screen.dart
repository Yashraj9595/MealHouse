import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  int _selectedIssueIndex = 0;
  final TextEditingController _descriptionController = TextEditingController();
  bool _imageAttached = false;

  final List<Map<String, dynamic>> _issueTypes = [
    {
      'label': 'Order Issue',
      'icon': Icons.shopping_bag_outlined,
      'color': const Color(0xFFD4541B),
      'bgColor': const Color(0xFFFFF3EE),
    },
    {
      'label': 'Pickup Location',
      'icon': Icons.location_on_outlined,
      'color': const Color(0xFF3B82F6),
      'bgColor': const Color(0xFFEFF6FF),
    },
    {
      'label': 'Payment Issue',
      'icon': Icons.credit_card_outlined,
      'color': const Color(0xFF22C55E),
      'bgColor': const Color(0xFFF0FDF4),
    },
    {
      'label': 'Subscription',
      'icon': Icons.calendar_month_outlined,
      'color': const Color(0xFFA855F7),
      'bgColor': const Color(0xFFFAF5FF),
    },
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('SELECT ISSUE TYPE'),
                  SizedBox(height: 1.5.h),
                  _buildIssueGrid(),
                  SizedBox(height: 1.2.h),
                  _buildOtherIssueCard(),
                  SizedBox(height: 2.5.h),
                  _buildSectionLabel('DESCRIPTION'),
                  SizedBox(height: 1.5.h),
                  _buildDescriptionField(),
                  SizedBox(height: 1.5.h),
                  _buildAttachImageArea(),
                  SizedBox(height: 1.h),
                  _buildAttachHint(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF1A1A1A),
          size: 24,
        ),
      ),
      title: Text(
        'Report a Problem',
        style: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFE5E5E5)),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF8A8A8A),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildIssueGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 1.5.h,
        childAspectRatio: 1.4,
      ),
      itemCount: _issueTypes.length,
      itemBuilder: (context, index) {
        final issue = _issueTypes[index];
        final bool isSelected = _selectedIssueIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedIssueIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isSelected
                    ? (issue['color'] as Color)
                    : const Color(0xFFE8E8E8),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: issue['bgColor'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    issue['icon'] as IconData,
                    color: issue['color'] as Color,
                    size: 22,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  issue['label'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtherIssueCard() {
    final bool isSelected = _selectedIssueIndex == 4;
    return GestureDetector(
      onTap: () => setState(() => _selectedIssueIndex = 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 1.8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4541B)
                : const Color(0xFFE8E8E8),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: Color(0xFF888888),
                size: 18,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'Other Issue',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 7,
        minLines: 7,
        style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          hintText: 'Describe your problem in detail.',
          hintStyle: GoogleFonts.dmSans(
            fontSize: 14,
            color: const Color(0xFFAAAAAA),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.8.h,
          ),
        ),
      ),
    );
  }

  Widget _buildAttachImageArea() {
    return GestureDetector(
      onTap: () {
        setState(() => _imageAttached = !_imageAttached);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: _imageAttached
                ? const Color(0xFFD4541B)
                : const Color(0xFFBBBBBB),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: _imageAttached
                ? const Color(0xFFD4541B)
                : const Color(0xFFBBBBBB),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _imageAttached
                    ? Icons.check_circle_outline_rounded
                    : Icons.camera_alt_outlined,
                color: _imageAttached
                    ? const Color(0xFFD4541B)
                    : const Color(0xFF555555),
                size: 22,
              ),
              SizedBox(width: 2.w),
              Text(
                _imageAttached ? 'Image Attached' : 'Attach Image',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _imageAttached
                      ? const Color(0xFFD4541B)
                      : const Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachHint() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: Text(
        'Optional: Share a screenshot to help us understand better.',
        style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF999999)),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 3.h),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            _showSuccessSnackbar(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8621A),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.0),
            ),
          ),
          child: Text(
            'Submit Request',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Your request has been submitted successfully!',
          style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD4541B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Dashed border is handled by the Container border above
    // This painter is a placeholder for future dashed border if needed
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
