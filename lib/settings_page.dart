import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
              "This app was built and shared for free out of revolutionary fraternity by one guy holding a newborn in one arm. It's built for both Android and Apple, but Apple charges \$100 a year to put apps on their store.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
              "Consider donating below! If I get enough donations, I'll also take it as a sign to build a WearOS integration, do some other stupid stuff probably, and mostly just keep having fun churning out niche content.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _launchURL('https://ko-fi.com/mvpworldchamp'),
              child: const Text(
                "Donate with Ko-Fi!",
                style: TextStyle(
                  fontFamily: "Cinzel",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Divider(
              height: 20,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
              "Whether or not you donate, the fact that you downloaded this wildly niche app means you're cool. I'd love to hear from you. Reach out to me on BlueSky!",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _launchURL('https://bsky.app/profile/theilluminati.bsky.social'),
              child: const Text(
                "theilluminati.bsky.social",
                style: TextStyle(
                  fontFamily: "Cinzel",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Divider(
              height: 20,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
              "Interested in adding quotes to the quote of the day? Have ideas for a feature? Want to steal the code and hack your own version? It's open source on GitHub! Submit PRs, do whatever!",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _launchURL('https://github.com/NickyEXE/French-Republican-Calendar'),
              child: const Text(
                "GitHub Repo",
                style: TextStyle(
                  fontFamily: "Cinzel",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}