import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/components/custom_image.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/view_models/auth/posts_view_model.dart';
import 'package:social_media_app/widgets/indicators.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  @override
  Widget build(BuildContext context) {
    currentUserId() => firebaseAuth.currentUser!.uid;
    final viewModel = Provider.of<PostsViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        await viewModel.resetPost();
        return true;
      },
      child: LoadingOverlay(
        progressIndicator: circularProgress(context),
        isLoading: viewModel.loading,
        child: Scaffold(
          key: viewModel.scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Ionicons.close_outline),
              onPressed: () {
                viewModel.resetPost();
                Navigator.pop(context);
              },
            ),
            title: Text('Biker Sync'.toUpperCase()),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () async {
                  await viewModel.uploadPosts(context);
                  Navigator.pop(context);
                  viewModel.resetPost();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Post'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(15.0),
            children: [
              const SizedBox(height: 10.0),

              // User info
              StreamBuilder(
                stream: usersRef.doc(currentUserId()).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    UserModel user = UserModel.fromJson(
                      snapshot.data!.data() as Map<String, dynamic>,
                    );
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25.0,
                        backgroundImage: NetworkImage(user.photoUrl!),
                      ),
                      title: Text(
                        user.username!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(user.email!),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 10.0),

              // Image picker
              InkWell(
                onTap: () => showImageChoices(context, viewModel),
                child: Container(
                  height: MediaQuery.of(context).size.width - 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  child:
                      viewModel.imgLink != null
                          ? CustomImage(
                            imageUrl: viewModel.imgLink,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.width - 30,
                            fit: BoxFit.cover,
                          )
                          : viewModel.mediaUrl == null
                          ? Center(
                            child: Text(
                              'Tap to upload photo',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          )
                          : Image.file(
                            viewModel.mediaUrl!,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.width - 30,
                            fit: BoxFit.cover,
                          ),
                ),
              ),

              const SizedBox(height: 25),

              buildCardInput(
                icon: Ionicons.people_outline,
                controller: viewModel.gatheringTEC,
                hint: 'Type of ride or gathering',
                onChanged: viewModel.setGathering,
              ),

              buildCardInput(
                icon: Ionicons.calendar_outline,
                controller: viewModel.dateTEC,
                hint: 'Select date',
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    String formattedDate =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    viewModel.dateTEC.text = formattedDate;
                    viewModel.setDate(formattedDate);
                  }
                },
              ),

              buildCardInput(
                icon: Ionicons.time_outline,
                controller: viewModel.timeTEC,
                hint: 'Select time',
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    viewModel.timeTEC.text = pickedTime.format(context);
                    viewModel.setTime(viewModel.timeTEC.text);
                  }
                },
              ),

              buildCardInput(
                icon: Ionicons.pencil_outline,
                hint: 'Ride details',
                initialValue: viewModel.description,
                onChanged: viewModel.setDescription,
                maxLines: null,
              ),

              buildCardInput(
                icon: Ionicons.location_outline,
                controller: viewModel.locationTEC,
                hint: 'Enter location',
                onChanged: viewModel.setLocation,
                suffixIcon: IconButton(
                  icon: Icon(CupertinoIcons.map_pin_ellipse),
                  tooltip: "Use your current location",
                  onPressed: () => viewModel.getLocation(),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCardInput({
    required IconData icon,
    TextEditingController? controller,
    String? initialValue,
    String? hint,
    bool readOnly = false,
    int? maxLines = 1,
    Widget? suffixIcon,
    Function()? onTap,
    Function(String)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        readOnly: readOnly,
        maxLines: maxLines,
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: Icon(icon),
          hintText: hint,
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  void showImageChoices(BuildContext context, PostsViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Select Image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Ionicons.camera_outline),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImage(camera: true);
                },
              ),
              ListTile(
                leading: Icon(Ionicons.image_outline),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
