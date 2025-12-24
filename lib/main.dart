// lib/main.dart
import 'package:disaster_management/pages/login_page.dart';
import 'package:disaster_management/theme/app_theme.dart';
import 'package:disaster_management/config/app_routes.dart';
import 'package:disaster_management/pages/home_page.dart';
import 'package:disaster_management/pages/official_profile_page.dart';
import 'package:disaster_management/pages/report_form_page.dart';
import 'package:disaster_management/pages/view_reports_page.dart';
import 'package:disaster_management/pages/view_reports_page_admin.dart';
import 'package:disaster_management/pages/report_detail_page.dart';
import 'package:disaster_management/pages/report_detail_page_admin.dart';
import 'package:disaster_management/pages/report_feedback_page.dart';
import 'package:disaster_management/pages/risk_factor_page.dart';
import 'package:disaster_management/pages/submit_report_page.dart';
import 'models/report_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) => runApp(const DisasterApp()));
}

class DisasterApp extends StatelessWidget {
  const DisasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Landslide Hazard Reporting',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const HomePage());
          case AppRoutes.officialProfile:
            return MaterialPageRoute(
              builder: (_) => const OfficialProfilePage(),
            );
          case AppRoutes.reportForm:
            return MaterialPageRoute(builder: (_) => const ReportFormPage());
          case AppRoutes.viewReports:
            return MaterialPageRoute(builder: (_) => const ViewReportsPage());
          case AppRoutes.viewReportsAdmin:
            return MaterialPageRoute(
              builder: (_) => const ViewReportsPageAdmin(),
            );
          case AppRoutes.reportDetail:
            final id = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => ReportDetailPage(reportId: id),
            );
          case AppRoutes.reportDetailAdmin:
            final id = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => ReportDetailPageAdmin(reportId: id),
            );
          case AppRoutes.reportFeedback:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ReportFeedbackPage(
                reportId: args['reportId'] as String,
                currentStatus: args['currentStatus'] as String?,
              ),
            );
          case AppRoutes.riskFactor:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => RiskFactorPage(
                report: args['report'] as ReportData,
                index: args['index'] as int,
              ),
            );
          case AppRoutes.submitReport:
            final report = settings.arguments as ReportData;
            return MaterialPageRoute(
              builder: (_) => SubmitReportPage(report: report),
            );
        }
        return null;
      },
    );
  }
}
