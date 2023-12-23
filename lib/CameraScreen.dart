import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:camera_app2/GalleryScreen.dart';
import 'package:camera_app2/utility.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraScreen extends StatefulWidget {
  List<CameraDescription> cameras;
  CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int selectedCamera = 0;
  List<File> capturedImages = [];

  initializationCamera(int cameraIndex) async {
    _controller = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void initState() {
    initializationCamera(selectedCamera);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return Column(
            children: [
              Container(
                height: 700,
                child: CameraPreview(_controller),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 225, 121, 9),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //camera rotate image
                      IconButton(
                        onPressed: () {
                          if (widget.cameras.length > 1) {
                            setState(() {
                              selectedCamera =
                                  selectedCamera == 0 ? 1 : 0; //switch camera
                              initializationCamera(selectedCamera);
                            });
                          }
                        },
                        icon: Icon(
                          Icons.switch_camera_rounded,
                          size: 40,
                        ),
                      ),

                      //capture image
                      GestureDetector(
                        onTap: () async {
                          await _initializeControllerFuture;
                          dynamic xFile = await _controller.takePicture();
                          setState(() {
                            capturedImages.add(File(xFile.path));
                            Utility.saveImageToShareprefrences(xFile.path);
                            print(
                                'lengthin shared pre ${capturedImages.length}');
                            print('mid ${xFile.path}');
                          });
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // image part show
                      GestureDetector(
                        onTap: () async {
                          print('hi');
                          print(capturedImages);
                          if (capturedImages.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return GalleryScreen(
                                    images: capturedImages.reversed.toList(),
                                  );
                                },
                              ),
                            );
                          } else {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (ctx) {
                              return GalleryScreen(images: capturedImages);
                            }));
                          }
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              image: capturedImages.isNotEmpty
                                  ? DecorationImage(
                                      image: FileImage(capturedImages.last),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        } else {
          // Otherwise, display a loading indicator.
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
