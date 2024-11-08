import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GlintLeaderBoard extends StatefulWidget {
  final String groupId;
  const GlintLeaderBoard({super.key, required this.groupId});

  @override
  State<GlintLeaderBoard> createState() => _GlintLeaderBoardState();
}

class _GlintLeaderBoardState extends State<GlintLeaderBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LeaderBoard'),
      ),
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
            String name = member['name'];
            int points = member['points'];

            // Add data for each member
            barData.add(
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points.toDouble(),
                    color: Colors.blueAccent,
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
                showingTooltipIndicators: [0],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                maxY: members
                        .map((m) => m['points'])
                        .reduce((a, b) => a > b ? a : b) +
                    5.0,
                barGroups: barData,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        String memberName = members[value.toInt()]['name'];
                        return Text(memberName, style: TextStyle(fontSize: 12));
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
              ),
            ),
          );
        },
      ),
    );
  }
}
