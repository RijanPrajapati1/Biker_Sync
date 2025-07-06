import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:like_button/like_button.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/widgets/indicators.dart';
import 'package:timeago/timeago.dart' as timeago;

class ViewImage extends StatefulWidget {
  final PostModel? post;

  ViewImage({this.post});

  @override
  _ViewImageState createState() => _ViewImageState();
}

final DateTime timestamp = DateTime.now();

String currentUserId() => firebaseAuth.currentUser!.uid;

UserModel? user;

class _ViewImageState extends State<ViewImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Center(child: buildImage(context))),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      direction: Axis.vertical,
                      spacing: 4,
                      children: [
                        Text(
                          widget.post?.username ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(Ionicons.alarm_outline, size: 13.0),
                            const SizedBox(width: 3.0),
                            Text(
                              timeago.format(widget.post!.timestamp!.toDate()),
                              style: const TextStyle(fontSize: 12.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  buildLikeButton(),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: CachedNetworkImage(
          imageUrl: widget.post!.mediaUrl ?? '',
          placeholder: (context, url) => circularProgress(context),
          errorWidget:
              (context, url, error) =>
                  const Icon(Icons.broken_image, size: 100, color: Colors.grey),
          height: 400.0,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildLikeButton() {
    return StreamBuilder(
      stream:
          likesRef
              .where('postId', isEqualTo: widget.post!.postId)
              .where('userId', isEqualTo: currentUserId())
              .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

          Future<bool> onLikeButtonTapped(bool isLiked) async {
            if (docs.isEmpty) {
              await likesRef.add({
                'userId': currentUserId(),
                'postId': widget.post!.postId,
                'dateCreated': Timestamp.now(),
              });
              addLikesToNotification();
              return !isLiked;
            } else {
              await likesRef.doc(docs[0].id).delete();
              removeLikeFromNotification();
              return isLiked;
            }
          }

          return LikeButton(
            onTap: onLikeButtonTapped,
            size: 25.0,
            circleColor: const CircleColor(
              start: Color(0xffFFC0CB),
              end: Color(0xffff0000),
            ),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Color(0xffFFA500),
              dotSecondaryColor: Color(0xffd8392b),
              dotThirdColor: Color(0xffFF69B4),
              dotLastColor: Color(0xffff8c00),
            ),
            likeBuilder:
                (_) => Icon(
                  docs.isEmpty ? Ionicons.heart_outline : Ionicons.heart,
                  color: docs.isEmpty ? Colors.grey : Colors.red,
                  size: 25,
                ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> addLikesToNotification() async {
    if (currentUserId() != widget.post!.ownerId) {
      final doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      await notificationRef
          .doc(widget.post!.ownerId)
          .collection('notifications')
          .doc(widget.post!.postId)
          .set({
            "type": "like",
            "username": user!.username!,
            "userId": currentUserId(),
            "userDp": user!.photoUrl,
            "postId": widget.post!.postId,
            "mediaUrl": widget.post!.mediaUrl,
            "timestamp": timestamp,
          });
    }
  }

  Future<void> removeLikeFromNotification() async {
    if (currentUserId() != widget.post!.ownerId) {
      final doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      final notifDoc =
          await notificationRef
              .doc(widget.post!.ownerId)
              .collection('notifications')
              .doc(widget.post!.postId)
              .get();
      if (notifDoc.exists) {
        await notifDoc.reference.delete();
      }
    }
  }
}
