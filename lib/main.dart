import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:untitled/application.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyAppState();
  }
}
class MyAppState extends State<MyApp> {
  int index = 0;

  bool isDownloading = false;
  double downloadProgress = 0;
  String downloadedFilePath = "";

  Future<Map<String, dynamic>> loadJsonFromGithub() async {
    final response = await http.read(Uri.parse(
        "https://raw.githubusercontent.com/bradjjc/update_test/main/app_versions_check/version.json"));
    return jsonDecode(response);
  }

  Future<void> openExeFile(String filePath) async {
    await Process.start(filePath, ["-t", "-l", "1000"]).then((value) {});
  }

  Future<void> openDMGFile(String filePath) async {
    await Process.start(
        "MOUNTDEV=\$(hdiutil mount '$filePath' | awk '/dev.disk/{print\$1}')",
        []).then((value) {
      debugPrint("Value: $value");
    });
  }

  Future downloadNewVersion(String appPath) async {
    final fileName = appPath.split("/").last;
    isDownloading = true;
    setState(() {});

    final dio = Dio();

    downloadedFilePath =
    "${(await getApplicationDocumentsDirectory()).path}/$fileName";

    await dio.download(
      "https://raw.githubusercontent.com/bradjjc/update_test/main/app_versions_check/$appPath",
      downloadedFilePath,
      onReceiveProgress: (received, total) {
        final progress = (received / total) * 100;
        debugPrint('Rec: $received , Total: $total, $progress%');
        downloadProgress = double.parse(progress.toStringAsFixed(1));
        setState(() {});
      },
    );
    debugPrint("File Downloaded Path: $downloadedFilePath");
    if (Platform.isWindows) {
      await openExeFile(downloadedFilePath);
    }
    isDownloading = false;
    setState(() {});
  }

  showUpdateDialog(Map<String, dynamic> versionJson) {
    final version = versionJson['version'];
    final updates = versionJson['description'] as List;
    return showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            // contentPadding: const EdgeInsets.all(10),
            title: Text("Latest Version $version"),
            content: Text('What\'s new in $version'),
            actions: [
              const SizedBox(
                height: 5,
              ),
              ...updates
                  .map((e) => Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "$e",
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ))
                  .toList(),
              const SizedBox(
                height: 10,
              ),
              if (version > ApplicationConfig.currentVersion)
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (Platform.isMacOS) {
                        downloadNewVersion(versionJson["macos_file_name"]);
                      }
                      if (Platform.isWindows) {
                        downloadNewVersion(versionJson["windows_file_name"]);
                      }
                    },
                    icon: const Icon(FluentIcons.update_restore),
                    // label: const Text("Update"),
                ),
            ],
          );
        });
  }

  Future<void> _checkForUpdates() async {
    final jsonVal = await loadJsonFromGithub();
    debugPrint("Response: $jsonVal");
    showUpdateDialog(jsonVal);
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return isDownloading
        ?  const ProgressRing(value: 35,)
        : FluentApp(
        theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            accentColor: Colors.blue,
            iconTheme: const IconThemeData(size: 24)),
        darkTheme: ThemeData(
            scaffoldBackgroundColor: Colors.black,
            accentColor: Colors.blue,
            iconTheme: const IconThemeData(size: 24)),
        home: NavigationView(
          appBar: const NavigationAppBar(
              title: Text("Fluent Design App Bar")),
          pane: NavigationPane(
              selected: index,
              onChanged: (newIndex){
                setState(() {
                  index = newIndex;
                });
              },
              displayMode: PaneDisplayMode.auto,
              items: [
                 PaneItem(
                    icon: const Icon(FluentIcons.code),
                    title: const Text("Sample Page 1")
                ),
                PaneItem(
                    icon: Icon(FluentIcons.access_logo),
                    title: Text("Sample Page 2")
                )
              ]
          ),
          content: NavigationBody(
              index: index,
            children: [
               ScaffoldPage(
                header: const Text(
                  "Sample Page 1",
                  style: TextStyle(fontSize: 60),
                ),
                 content: Center(
                   child: Button(
                     onPressed: (){
                       _checkForUpdates();
                     },
                     child: Text('check updates'),
                   ),
                 ),
              ),
              ScaffoldPage(
                header: const Text(
                  "Sample Page 2",
                  style: TextStyle(fontSize: 60),
                ),
                content: Center(
                  child: Text("Welcome to Page 2!"),
                ),
              ),
            ],
          ),
        )
    );
  }
}

