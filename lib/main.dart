import 'package:fluent_ui/fluent_ui.dart';

void main() {
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FluentApp(
        theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            accentColor: Colors.blue,
            iconTheme: const IconThemeData(size: 24)),
        darkTheme: ThemeData(
            scaffoldBackgroundColor: Colors.black,
            accentColor: Colors.blue,
            iconTheme: const IconThemeData(size: 24)),
        home: NavigationView(
          appBar: NavigationAppBar(
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
                header: Text(
                  "Sample Page 1",
                  style: TextStyle(fontSize: 60),
                ),
                 content: Center(
                   child: Text("Welcome to Page 1!"),
                 ),
              ),
              ScaffoldPage(
                header: Text(
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

