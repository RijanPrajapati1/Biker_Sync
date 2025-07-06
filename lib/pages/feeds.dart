import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:social_media_app/chats/recent_chats.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/utils/constants.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/widgets/indicators.dart';
import 'package:social_media_app/widgets/story_widget.dart';
import 'package:social_media_app/widgets/userpost.dart';

class Feeds extends StatefulWidget {
  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int page = 5;
  bool loadingMore = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          page += 5;
          loadingMore = true;
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      page = 5; // Reset to initial page count on refresh
      loadingMore = false;
    });
    await postRef.orderBy('timestamp', descending: true).limit(page).get();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          Constants.appName,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Ionicons.chatbubble_ellipses, size: 30.0),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => Chats()),
              );
            },
          ),
          SizedBox(width: 20.0),
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: _handleRefresh,
        child: ListView(
          controller: scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            StoryWidget(),
            FutureBuilder<QuerySnapshot>(
              future:
                  postRef
                      .orderBy('timestamp', descending: true)
                      .limit(page)
                      .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var docs = snapshot.data!.docs;
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      // Cast Firestore document data to Map<String, dynamic>
                      PostModel post = PostModel.fromJson(
                        docs[index].data()! as Map<String, dynamic>,
                      );
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: UserPost(post: post),
                      );
                    },
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return circularProgress(context);
                } else {
                  return Center(
                    child: Text(
                      'No Feeds',
                      style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
