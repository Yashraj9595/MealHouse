import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class FaqDetailScreen extends StatefulWidget {
  const FaqDetailScreen({super.key});

  @override
  State<FaqDetailScreen> createState() => _FaqDetailScreenState();
}

class _FaqDetailScreenState extends State<FaqDetailScreen> {
  bool? _helpful;

  static const Color _orange = Color(0xFFD4541B);
  static const Color _orangeLight = Color(0xFFFFF3EC);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textGray = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainContent(),
              _buildDivider(),
              _buildRelatedQuestions(),
              _buildHelpfulSection(),
              _buildContactSection(),
              SizedBox(height: 3.h),
            ],
          ),
        ),
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
        child: const Icon(Icons.chevron_left_rounded, color: _orange, size: 30),
      ),
      title: Text(
        'FAQ',
        style: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _textDark,
          letterSpacing: -0.2,
        ),
      ),
      titleSpacing: 0,
    );
  }

  Widget _buildMainContent() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bold heading
          Text(
            'How do I cancel my order?',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textDark,
              letterSpacing: -0.3,
              height: 1.3,
            ),
          ),
          SizedBox(height: 2.h),
          // Descriptive paragraph with bold inline text
          RichText(
            text: TextSpan(
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF3A3A3A),
                height: 1.6,
              ),
              children: const [
                TextSpan(
                  text:
                      'You can cancel your mess order directly through the app before the daily cut-off time. For lunch orders, the deadline is ',
                ),
                TextSpan(
                  text: '9:00 AM',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: ', and for dinner orders, the deadline is '),
                TextSpan(
                  text: '4:00 PM',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'To cancel, follow these steps:',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF3A3A3A),
              height: 1.6,
            ),
          ),
          SizedBox(height: 1.5.h),
          // Numbered steps
          _buildStep(1, [
            const TextSpan(text: 'Navigate to the '),
            const TextSpan(
              text: "'My Orders'",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: ' tab in the bottom menu.'),
          ]),
          SizedBox(height: 1.2.h),
          _buildStep(2, [
            const TextSpan(text: 'Find the active order you wish to cancel.'),
          ]),
          SizedBox(height: 1.2.h),
          _buildStep(3, [
            const TextSpan(text: 'Tap on the order card to view details.'),
          ]),
          SizedBox(height: 1.2.h),
          _buildStep(4, [
            const TextSpan(text: 'Tap the orange '),
            const TextSpan(
              text: "'Cancel Order'",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: ' button at the bottom of the screen.'),
          ]),
          SizedBox(height: 2.5.h),
          // Note callout box
          Container(
            decoration: BoxDecoration(
              color: _orangeLight,
              borderRadius: BorderRadius.circular(8.0),
              border: const Border(left: BorderSide(color: _orange, width: 4)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: _orange,
                  height: 1.6,
                ),
                children: const [
                  TextSpan(
                    text: 'Note: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        'Once canceled, the amount will be credited back to your app wallet within 24 hours.',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  Widget _buildStep(int number, List<InlineSpan> spans) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number. ',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF3A3A3A),
            height: 1.6,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF3A3A3A),
                height: 1.6,
              ),
              children: spans,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(color: const Color(0xFFF5F5F5), height: 1.5.h);
  }

  Widget _buildRelatedQuestions() {
    final questions = [
      'When will I get my refund?',
      'Can I change my delivery address?',
      'What is the subscription pause policy?',
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Text(
            'RELATED QUESTIONS',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _textGray,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 0.5.h),
          ...questions.map((q) => _buildRelatedQuestionRow(q)),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  Widget _buildRelatedQuestionRow(String question) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _textDark,
                      height: 1.4,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _textGray,
                  size: 22,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }

  Widget _buildHelpfulSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Column(
        children: [
          Text(
            'Was this helpful?',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _textGray,
            ),
          ),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHelpfulButton('Yes', true),
              SizedBox(width: 3.w),
              _buildHelpfulButton('No', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpfulButton(String label, bool value) {
    final bool isSelected = _helpful == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _helpful = value;
        });
      },
      child: Container(
        width: 22.w,
        padding: EdgeInsets.symmetric(vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isSelected ? _orange : Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(
            color: isSelected ? _orange : const Color(0xFFCCCCCC),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : _textDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
      child: Column(
        children: [
          Text(
            'Still need help?',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _textGray,
            ),
          ),
          SizedBox(height: 1.5.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
                elevation: 0,
              ),
              child: Text(
                'Contact Support',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
