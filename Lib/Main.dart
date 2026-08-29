import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const StatusGoApp());
}

class StatusGoApp extends StatelessWidget {
  const StatusGoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StatusGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF075E54),
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF075E54),
          primary: const Color(0xFF075E54),
          secondary: const Color(0xFF25D366),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasPermission = false;
  List<File> imageList = [];
  List<File> videoList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.request();
    var manageStatus = await Permission.manageExternalStorage.request();
    
    if (status.isGranted || manageStatus.isGranted) {
      setState(() {
        hasPermission = true;
      });
      loadStatuses();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void loadStatuses() {
    final directory = Directory('/storage/emulated/0/WhatsApp/Media/.Statuses');
    final whatsappBusiness = Directory('/storage/emulated/0/WhatsApp Business/Media/.Statuses');

    List<File> tempImages = [];
    List<File> tempVideos = [];

    for (var dir in [directory, whatsappBusiness]) {
      if (dir.existsSync()) {
        final items = dir.listSync();
        for (var item in items) {
          if (item is File) {
            String path = item.path.toLowerCase();
            if (path.endsWith('.jpg') || path.endsWith('.png')) {
              tempImages.add(item);
            } else if (path.endsWith('.mp4')) {
              tempVideos.add(item);
            }
          }
        }
      }
    }

    setState(() {
      imageList = tempImages;
      videoList = tempVideos;
      isLoading = false;
    });
  }

  Future<void> saveFile(File file) async {
    try {
      final saveDir = Directory('/storage/emulated/0/Download/StatusGo');
      if (!saveDir.existsSync()) {
        saveDir.createSync(recursive: true);
      }
      final String fileName = file.path.split('/').last;
      final String newPath = '${saveDir.path}/$fileName';
      await file.copy(newPath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imetunzwa kwenye Downloads/StatusGo!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imeshindikana kutunza: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF075E54),
          title: const Text(
            'StatusGo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Picha (Images)'),
              Tab(text: 'Video'),
            ],
          ),
        ),
        body: !hasPermission
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Ruhusa ya kufikia mafaili inahitajika ili kuonyesha Status.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF075E54),
                        ),
                        onPressed: requestStoragePermission,
                        child: const Text('Ruhusu Upate Ruhusa', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              )
            : isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      imageList.isEmpty
                          ? const Center(child: Text('Hakuna Picha za Status zilizopatikana'))
                          : GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: imageList.length,
                              itemBuilder: (context, index) {
                                final file = imageList[index];
                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.file(file, fit: BoxFit.cover),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: FloatingActionButton.small(
                                        backgroundColor: const Color(0xFF25D366),
                                        onPressed: () => saveFile(file),
                                        child: const Icon(Icons.download, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                      videoList.isEmpty
                          ? const Center(child: Text('Hakuna Video za Status zilizopatikana'))
                          : GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: videoList.length,
                              itemBuilder: (context, index) {
                                final file = videoList[index];
                                return Container(
                                  color: Colors.black12,
                                  child: Stack(
                                    children: [
                                      const Center(child: Icon(Icons.videocam, size: 50, color: Colors.white)),
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: FloatingActionButton.small(
                                          backgroundColor: const Color(0xFF25D366),
                                          onPressed: () => saveFile(file),
                                          child: const Icon(Icons.download, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
      ),
    );
  }
}
