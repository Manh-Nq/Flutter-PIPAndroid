import 'dart:ffi';

import 'package:flutter/material.dart';

Widget iconViews(VoidCallback callback) {
  return Material(
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () {
              callback();
            },
            child: Icon(
              Icons.link_off,
              size: 25,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Icon(
            Icons.share,
            size: 25,
          ),
        ),
        Expanded(
          flex: 1,
          child: Icon(
            Icons.download,
            size: 25,
          ),
        ),
        Expanded(
          flex: 1,
          child: Icon(
            Icons.cut,
            size: 25,
          ),
        ),
        Expanded(
          flex: 1,
          child: Icon(
            Icons.save_alt,
            size: 25,
          ),
        )
      ],
    ),
  );
}

Widget contentVideoMini(VoidCallback callback) {
  return Opacity(
      opacity: 1,
      child: Padding(
        padding: const EdgeInsets.only(left: 170),
        child: Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: const [
                Text(
                  "this is content video",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                Text("robert fukuda",
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w200)),
              ],
            )),
            InkWell(
                onTap: () {},
                child: Icon(
                  Icons.play_arrow,
                  size: 32,
                )),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.close,
                  size: 32,
                )),
          ],
        ),
      ));
}

Widget navigationBar() {
  return Container(
    color: Colors.white,
    height: 48,
    child: Row(
      children: const [
        Expanded(
            flex: 1,
            child: Icon(
              Icons.home,
              size: 25,
            )),
        Expanded(
            flex: 1,
            child: Icon(
              Icons.short_text_outlined,
              size: 25,
            )),
        Expanded(
            flex: 1,
            child: Icon(
              Icons.add,
              size: 25,
            )),
        Expanded(
            flex: 1,
            child: Icon(
              Icons.subscriptions,
              size: 25,
            )),
        Expanded(
            flex: 1,
            child: Icon(
              Icons.video_library,
              size: 25,
            )),
      ],
    ),
  );
}

Widget content() {
  return const Padding(
    padding: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
    child: Text(
      "Tập thể dục buổi sáng, Gà trống mèo con Cún con - Liên khúc nhạc thiếu nhi",
      maxLines: 2,
      style: TextStyle(fontSize: 16),
    ),
  );
}

Widget listVideos(List<Video> videos, VoidCallback callback) {
  return Scrollbar(
      child: Opacity(
          opacity: 1,
          child: ListView.builder(
            itemBuilder: (context, index) {
              var item = videos[index];
              if (item.type == TypeItem.header) {
                return headerItem(callback);
              } else {
                return VideoCard(video: videos[index]);
              }
            },
            itemCount: videos.length,
          )));
}

Widget headerItem(VoidCallback callback) {
  return Container(
    width: double.infinity,
    alignment: Alignment.topLeft,
    height: 80,
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, right: 8),
          child: Text(
            "But if you want to change the opacity of all the widget, in your case a Container, you can wrap it into a Opacity widget like this",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: iconViews(callback),
        )
      ],
    ),
  );
}

class VideoCard extends StatelessWidget {
  final Video video;
  final bool hasPadding;
  final VoidCallback? onTap;

  const VideoCard({
    Key? key,
    required this.video,
    this.hasPadding = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: hasPadding ? 12.0 : 0,
                ),
                child: Image.network(
                  video.thumbnailUrl,
                  height: 220.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 8.0,
                right: hasPadding ? 20.0 : 8.0,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  color: Colors.black,
                  child: Text(
                    video.duration,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => print('Navigate to profile'),
                  child: CircleAvatar(
                    foregroundImage: NetworkImage(video.author.profileImageUrl),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontSize: 15.0),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '${video.author.username} • ${video.viewCount} views •',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(fontSize: 14.0),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.more_vert, size: 20.0),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class UserVideo {
  final String username;
  final String profileImageUrl;
  final String subscribers;

  const UserVideo({
    required this.username,
    required this.profileImageUrl,
    required this.subscribers,
  });
}

const UserVideo currentUser = UserVideo(
  username: 'Animal',
  profileImageUrl: 'https://www.flaticon.com/free-icon/poster_252341',
  subscribers: '100tr',
);

enum TypeItem { item, header }

class Video {
  final String id;
  final UserVideo author;
  final String title;
  final String thumbnailUrl;
  final String duration;
  final DateTime timestamp;
  final String viewCount;
  final String likes;
  final String dislikes;
  final TypeItem type;

  const Video({
    required this.id,
    required this.author,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.timestamp,
    required this.viewCount,
    required this.likes,
    required this.dislikes,
    required this.type,
  });
}

List<Video> fakeItems() {
  List<Video> videos = [];
  for (int i = 0; i < 10; i++) {
    if (i == 0) {
      videos.add(fakeHeader());
    } else {
      videos.add(fakeVideo());
    }
  }

  return videos;
}

Video fakeVideo() {
  return Video(
      id: 'x606y4QWrxo',
      author: currentUser,
      title: 'this is animal in animal world',
      thumbnailUrl:
          'https://images.pexels.com/photos/751829/pexels-photo-751829.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      duration: '8:20',
      timestamp: DateTime(2021, 3, 20),
      viewCount: '10K',
      likes: '958',
      dislikes: '4',
      type: TypeItem.item);
}

Video fakeHeader() {
  return Video(
      id: '',
      author: currentUser,
      title: '',
      thumbnailUrl: '',
      duration: '',
      timestamp: DateTime(2021, 3, 20),
      viewCount: '',
      likes: '',
      dislikes: '',
      type: TypeItem.header);
}
