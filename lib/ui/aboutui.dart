import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows some kind of "About app" screen
/// containing information about the app,
/// publisher, producer, developers,
/// and licenses.
class AboutUi extends StatelessWidget {
  const AboutUi({super.key});

  @override
  Widget build(BuildContext context) {
    final PackageInfo appInfo = Provider.of<PackageInfo>(context);
    final primStyle = TextStyle(color: PlanColors.PrimaryTextColor, fontWeight: FontWeight.bold);
    final scndStyle = TextStyle(color: PlanColors.SecondaryTextColor);
    
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.aboutApp)),
      body: Column(
        children: [
          ListTile(
            leading: Image.asset("assets/images/AppIcon.png"),
            title: Text(AppLocalizations.of(context)!.title, style: TextStyle(color: PlanColors.PrimaryTextColor, fontWeight: FontWeight.bold, fontSize: 32)),    
            subtitle: Text(
              AppLocalizations.of(context)!.subtitle,
              style: TextStyle(color: PlanColors.SecondaryTextColor)
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: IntrinsicColumnWidth(flex: 0.4),
                1: FlexColumnWidth()
              },
              children: [
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context)!.name, style: primStyle),
                    Text(appInfo.appName, style: scndStyle)
                  ]
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context)!.version, style: primStyle),
                    Text(appInfo.version, style: scndStyle)
                  ]
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context)!.store, style: primStyle),
                    Text(appInfo.installerStore ?? AppLocalizations.of(context)!.storeUnknown, style: scndStyle)
                  ]
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context)!.license, style: primStyle),
                    Text("MIT", style: scndStyle)
                  ]
                ),
                TableRow(
                  children: [
                    Text("", style: primStyle),
                    Text("", style: scndStyle)
                  ]
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context)!.publisher, style: primStyle),
                    Text("Friedrich-List-Schule Wiesbaden", style: scndStyle)
                  ]
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context)!.phone, style: primStyle),
                    RichText(
                      text: TextSpan(
                        text: '+49 (0)611/31 51 00',
                        style: scndStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async { 
                            final Uri url = Uri.parse("tel://+49611315100");
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                      )
                    )
                  ]
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context)!.website, style: primStyle),
                    RichText(
                      text: TextSpan(
                        text: 'www.fls-wiesbaden.de',
                        style: scndStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async { 
                            final Uri url = Uri.parse("https://www.fls-wiesbaden.de");
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                      )
                    )
                  ]
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context)!.email, style: primStyle),
                    RichText(
                      text: TextSpan(
                        text: 'website-team@fls-wiesbaden.de',
                        style: scndStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async { 
                            final Uri url = Uri.parse("mailto:website-team@fls-wiesbaden.de?subject=FLS-Vertretungsplan-App");
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                      )
                    )
                  ]
                ),
                TableRow(
                  children: [
                    Text("", style: primStyle),
                    Text("", style: scndStyle)
                  ]
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context)!.design, style: primStyle),
                    Text("Kamil Drozd", style: scndStyle)
                  ]
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context)!.concept, style: primStyle),
                    Text("Simon Seyer", style: scndStyle)
                  ]
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context)!.development, style: primStyle),
                    Text("Lukas Schreiner", style: scndStyle)
                  ]
                )
              ],
            )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 15),
            child: ElevatedButton(
              onPressed: () {
                // ignore: use_build_context_synchronously
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LicensePage()),
                );
              }, 
              child: Text(AppLocalizations.of(context)!.licenses)
            ),
          )
        ]
      ),
    );
  }
}