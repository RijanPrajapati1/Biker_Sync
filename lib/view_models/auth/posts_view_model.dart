import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/screens/mainscreen.dart';
import 'package:social_media_app/services/post_service.dart';
import 'package:social_media_app/services/user_service.dart';
import 'package:social_media_app/utils/constants.dart';
import 'package:social_media_app/utils/firebase.dart';

class PostsViewModel extends ChangeNotifier {
  // Services
  UserService userService = UserService();
  PostService postService = PostService();

  // Keys
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Variables
  bool loading = false;
  String? username;
  File? mediaUrl;
  final picker = ImagePicker();
  String? location;
  Position? position;
  Placemark? placemark;
  String? bio;
  String? description;
  String? email;
  String? commentData;
  String? ownerId;
  String? userId;
  String? type;
  File? userDp;
  String? imgLink;
  bool edit = false;
  String? id;

  // New Post Details
  String? date;
  String? time;
  String? gathering;

  // Controllers
  TextEditingController locationTEC = TextEditingController();
  TextEditingController dateTEC = TextEditingController();
  TextEditingController timeTEC = TextEditingController();
  TextEditingController gatheringTEC = TextEditingController();

  // Setters
  setEdit(bool val) {
    edit = val;
    notifyListeners();
  }

  setPost(PostModel post) {
    description = post.description;
    imgLink = post.mediaUrl;
    location = post.location;
    edit = true;
    edit = false;
    notifyListeners();
  }

  setUsername(String val) {
    print('SetName $val');
    username = val;
    notifyListeners();
  }

  setDescription(String val) {
    print('SetDescription $val');
    description = val;
    notifyListeners();
  }

  setLocation(String val) {
    print('SetCountry $val');
    location = val;
    notifyListeners();
  }

  setBio(String val) {
    print('SetBio $val');
    bio = val;
    notifyListeners();
  }

  setDate(String val) {
    print('SetDate $val');
    date = val;
    notifyListeners();
  }

  setTime(String val) {
    print('SetTime $val');
    time = val;
    notifyListeners();
  }

  setGathering(String val) {
    print('SetGathering $val');
    gathering = val;
    notifyListeners();
  }

  // Functions
  pickImage({bool camera = false, BuildContext? context}) async {
    loading = true;
    notifyListeners();
    try {
      XFile? pickedFile = await picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickedFile == null) {
        loading = false;
        notifyListeners();
        showInSnackBar('No image selected', context);
        return;
      }
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Constants.lightAccent,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
          IOSUiSettings(minimumAspectRatio: 1.0),
        ],
      );
      if (croppedFile == null) {
        loading = false;
        notifyListeners();
        showInSnackBar('Crop cancelled', context);
        return;
      }
      mediaUrl = File(croppedFile.path);
      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();
      showInSnackBar('Cancelled', context);
    }
  }

  getLocation() async {
    loading = true;
    notifyListeners();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
      await getLocation();
    } else {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position!.latitude,
        position!.longitude,
      );
      placemark = placemarks[0];
      location = "${placemarks[0].locality}, ${placemarks[0].country}";
      locationTEC.text = location!;
    }
    loading = false;
    notifyListeners();
  }

  uploadPosts(BuildContext context) async {
    try {
      loading = true;
      notifyListeners();
      await postService.uploadPost(
        mediaUrl!,
        location ?? '',
        description ?? '',
        date ?? '',
        time ?? '',
        gathering ?? '',
      );
      loading = false;
      resetPost();
      notifyListeners();
      showInSnackBar('Uploaded successfully!', context);
    } catch (e) {
      print(e);
      loading = false;
      resetPost();
      showInSnackBar('Upload failed: ${e.toString()}', context);
      notifyListeners();
    }
  }

  uploadProfilePicture(BuildContext context) async {
    if (mediaUrl == null) {
      showInSnackBar('Please select an image', context);
    } else {
      try {
        loading = true;
        notifyListeners();
        await postService.uploadProfilePicture(
          mediaUrl!,
          firebaseAuth.currentUser!,
        );
        loading = false;
        notifyListeners();
        Navigator.of(
          context,
        ).pushReplacement(CupertinoPageRoute(builder: (_) => TabScreen()));
      } catch (e) {
        print(e);
        loading = false;
        showInSnackBar('Upload failed: ${e.toString()}', context);
        notifyListeners();
      }
    }
  }

  resetPost() {
    mediaUrl = null;
    description = null;
    location = null;
    date = null;
    time = null;
    gathering = null;

    locationTEC.clear();
    dateTEC.clear();
    timeTEC.clear();
    gatheringTEC.clear();

    edit = false;
    notifyListeners();
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
