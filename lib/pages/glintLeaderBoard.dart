import 'package:Glint/pages/groupfeed.dart';
import 'package:Glint/utils/colorPallet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlintLeaderBoard extends StatefulWidget {
  final String groupId;
  final String groupname;
  final String phoneNumber;
  final String todaystheme;
  final String userid;
  final String usename;

  const GlintLeaderBoard({
    super.key,
    required this.groupId,
    required this.groupname,
    required this.phoneNumber,
    required this.userid,
    required this.todaystheme,
    required this.usename,
  });

  @override
  State<GlintLeaderBoard> createState() => _GlintLeaderBoardState();
}

class _GlintLeaderBoardState extends State<GlintLeaderBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: const Text(
          'LeaderBoard',
          style: TextStyle(color: AppColors.whiteText),
        ),
        backgroundColor: AppColors.secondaryBackground,
      ),
      backgroundColor: AppColors.secondaryBackground,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var groupData = snapshot.data!.data() as Map<String, dynamic>;
          var members = groupData['members'] as List<dynamic>;

          List<BarChartGroupData> barData = [];

          for (int i = 0; i < members.length; i++) {
            var member = members[i] as Map<String, dynamic>;
            int points = member['points'];

            // Add data for each member
            barData.add(
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points.toDouble(),
                    color: AppColors.whiteText,
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                    rodStackItems: [
                      BarChartRodStackItem(0, 5, AppColors.blurple)
                    ],
                  ),
                ],
                showingTooltipIndicators: [0],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              SizedBox(
                height: 350.h,
                width: 350.w,
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                          tooltipPadding: const EdgeInsets.all(5),
                          tooltipRoundedRadius: 100),
                    ),
                    maxY: members
                            .map((m) => m['points'])
                            .reduce((a, b) => a > b ? a : b) +
                        7.0,
                    barGroups: barData,
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            String memberName = members[value.toInt()]['name'];
                            return Text(
                              memberName,
                              style: const TextStyle(
                                  fontSize: 15, color: AppColors.whiteText),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              isCurrentUserTopScorer(members, widget.usename)
                  ? const Text(
                      'You Are Winning',
                      style:
                          TextStyle(fontSize: 30, color: AppColors.whiteText),
                    )
                  : Text('${getTopScorer(members)} Is Winning',
                      style: const TextStyle(fontSize: 30)),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17)),
                    padding:
                        EdgeInsets.symmetric(horizontal: 50.w, vertical: 12.h),
                    elevation: 0,
                    backgroundColor: AppColors.blurple,
                    foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Groupfeed(
                            groupname: widget.groupname,
                            theme: widget.todaystheme,
                            code: widget.groupId,
                            phoneNumberAsUserId: widget.phoneNumber,
                            username: widget.usename,
                            userid: widget.userid)),
                  );
                },
                child: const Text(
                  'Share More Glints',
                  style: TextStyle(fontSize: 20),
                ),
              )
            ]),
          );
        },
      ),
    );
  }

  bool isCurrentUserTopScorer(List<dynamic> members, String currentUserId) {
    var topScorer = getTopScorer(members);

    // Check if the top scorer's ID matches the current user's ID
    return topScorer.isNotEmpty && topScorer == widget.usename;
  }

  String getTopScorer(List<dynamic> members) {
    var topMember = members.reduce((curr, next) {
      return curr['points'] > next['points'] ? curr : next;
    });

    return topMember['name'];
  }
}
