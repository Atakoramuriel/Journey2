import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journey2/constants.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journey2/auth.dart';
import 'package:journey2/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crop_your_image/crop_your_image.dart';

class ImageCrop extends StatefulWidget {
  const ImageCrop({super.key});

  @override
  State<ImageCrop> createState() => _ImageCropState();
}

class _ImageCropState extends State<ImageCrop> {
  //Starting variables
  final _controller = CropController(); //For cropping image
  final _imageDataList = <Uint8List>[];
  File? fileImg;
  bool cropReady = false;
  var _isSumbnail = false;
  var _isCropping = false;
  var _isCircleUi = true;
  Uint8List? _croppedData, firebaseIMG;
  var _statusText = '';

  @override
  void initState() {
    super.initState();
    _getImage();
  }

  Future _getImage() async {
    print("_getImage Called II");
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      print("\n \n \n ERROR Getting Image\n \n \n ");
    }

    final fileImg2 = File(image!.path);
    //Set State
    setState(() {
      fileImg = fileImg2;
      _loadCrop(fileImg);
      // _profileImg = imageTemp;
      // _selectedGalleryImg = _profileImg;
      // selectedImg = true;
      // _imageDataList.add(await _selectedGalleryImg!.readAsBytes());
      // _cropController.image = await _selectedGalleryImg!.readAsBytes();
      //assignProfilePhoto();

      // print('_profileImg: $_profileImg');
    });
  }

  Future _loadCrop(File? fileImg) async {
    _imageDataList.add(await fileImg!.readAsBytes());
    cropReady = true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: kNightCard,
            height: size.height,
            width: size.width,
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.12,
                ),
                // if (fileImg != null) ...[
                //   CircleAvatar(
                //     backgroundColor: Colors.white,
                //     backgroundImage: FileImage(fileImg!),
                //     radius: 150,
                //   )
                // ] else ...[
                //   const CircularProgressIndicator()
                // ],
                if (cropReady == true) ...[
                  Container(
                    height: size.height * 0.5,
                    width: size.width,
                    child: Crop(
                      willUpdateScale: (newScale) => newScale < 5,
                      controller: _controller,
                      image: _imageDataList[0],
                      onCropped: (croppedData) {
                        setState(() {
                          print(
                              "========== CROPPED IMAGE ========== \n \n \n \n \n");
                          _croppedData = croppedData;
                          firebaseIMG = croppedData;
                          _isCropping = false;
                          var image = croppedData;

                          // fileImg = Image.memory(croppedData) as File?;
                        });
                      },
                      withCircleUi: _isCircleUi,
                      onStatusChanged: (status) => setState(() {
                        _statusText = <CropStatus, String>{
                              CropStatus.nothing: 'Crop has no image data',
                              CropStatus.loading:
                                  'Crop is now loading given image',
                              CropStatus.ready: 'Crop is now ready!',
                              CropStatus.cropping: 'Crop is now cropping image',
                            }[status] ??
                            '';
                      }),
                      initialSize: 0.5,
                      maskColor: _isSumbnail ? Colors.white : null,
                      cornerDotBuilder: (size, edgeAlignment) =>
                          const SizedBox.shrink(),
                      interactive: true,
                      fixCropRect: true,
                      radius: 20,
                      initialRectBuilder: (viewportRect, imageRect) {
                        return Rect.fromLTRB(
                          viewportRect.left + 24,
                          viewportRect.top + 24,
                          viewportRect.right - 24,
                          viewportRect.bottom - 24,
                        );
                      },
                    ),
                  )
                ],
                SizedBox(
                  height: size.height * 0.05,
                ),
                ElevatedButton(
                  child: Text('Crop Image'),
                  onPressed: () => _controller.crop(),
                ),
                if (_croppedData != null) ...[
                  Image.memory(
                    _croppedData!,
                    width: size.width * 0.5,
                  )
                ] else ...[
                  const CircularProgressIndicator()
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
