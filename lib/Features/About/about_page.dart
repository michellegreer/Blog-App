import 'package:flutter/material.dart';
import 'package:blog_app/Core/Common/Widgets/kittehs_scaffold.dart';
import 'package:blog_app/Core/Themes/app_pallate.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final hPad = (screenW * 0.15).clamp(24.0, 220.0);

    const bodyStyle = TextStyle(color: Colors.white, fontSize: 16, height: 1.7);
    const bulletStyle = TextStyle(color: Colors.white, fontSize: 16, height: 1.7);

    return KittehsScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 40, hPad, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Kitties FTW',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenW >= 700 ? 36 : 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: AppPallate.borderColor),
            const SizedBox(height: 24),
            const Text(
              'Kids love cat videos, but YouTube isn\'t the safest place to send your kids. '
              'Kitties FTW provides a safe place to share and comment on cat videos with your '
              'friends and family. Every user here is vetted by the creator of this website, '
              'Michelle Greer.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),
            const Text(
              'As the admin of this site, I ensure to never:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, height: 1.7),
            ),
            const SizedBox(height: 8),
            ...[
              'Sell your information to someone else',
              'Track your online activity',
              'Expose your kids to content they shouldn\'t see',
              'Let creepers use this site to track your kids',
            ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('  •  ', style: TextStyle(color: AppPallate.coralColor, fontSize: 18)),
                  Expanded(child: Text(item, style: bulletStyle)),
                ],
              ),
            )),
            const SizedBox(height: 24),
            const Text(
              'So enjoy the site! Let me know if you want any features. '
              'If you\'re on this site, you know how to find me!',
              style: bodyStyle,
            ),
          ],
        ),
      ),
    );
  }
}
