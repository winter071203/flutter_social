import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insta_assets_crop/insta_assets_crop.dart';
import 'package:insta_node_app/screens/preview_video_edit.dart';
import 'package:insta_node_app/utils/animate_route.dart';
import 'package:insta_node_app/utils/media_services.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaGalleryReelScreen extends StatefulWidget {
  final Function navigationTapped;
  final List<Uint8List> imageList;
  final Function(List<Uint8List>) handleChangeImageList;
  const MediaGalleryReelScreen({
    Key? key,
    required this.navigationTapped,
    required this.imageList,
    required this.handleChangeImageList,
  }) : super(key: key);
  @override
  State<MediaGalleryReelScreen> createState() => _MediaGalleryReelScreenState();
}

class _MediaGalleryReelScreenState extends State<MediaGalleryReelScreen> {
  final ScrollController _scrollController = ScrollController();
  final cropKey = GlobalKey<CropState>();
  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetList = [];
  int _currentPage = 1;

  @override
  void initState() {
    MediaServices().loadAlbums(RequestType.video, 1).then((value) {
      setState(() {
        albumList = value;
        selectedAlbum = value[0];
      });
      MediaServices().loadAssets(selectedAlbum!, 1).then((value) {
        setState(() {
          assetList = value;
        });
      });
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        MediaServices()
            .loadAssets(selectedAlbum!, _currentPage + 1)
            .then((value) {
          setState(() {
            _currentPage++;
            assetList = [...assetList, ...value];
          });
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void handleChooseMedia() async {
    widget.navigationTapped();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        title: Row(
          children: [
            GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  size: 30,
                  color: Colors.white,
                )),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'New reel',
                  style: TextStyle(fontWeight: FontWeight.bold,),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            children: [
              Container(
                height: 50,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    DropdownButton<AssetPathEntity>(
                      dropdownColor: Colors.black,
                      value: selectedAlbum,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      onChanged: (AssetPathEntity? value) async {
                        setState(() {
                          selectedAlbum = value;
                        });
                        MediaServices()
                            .loadAssets(selectedAlbum!, 1)
                            .then((value) {
                          setState(() {
                            assetList = value;
                          });
                        });
                      },
                      items: albumList.map<DropdownMenuItem<AssetPathEntity>>(
                          (AssetPathEntity album) {
                        return DropdownMenuItem<AssetPathEntity>(
                          value: album,
                          child: Row(
                            children: [
                              Text(album.name,),
                              const SizedBox(
                                width: 8,
                              ),
                              FutureBuilder(
                                future: album.assetCountAsync,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(snapshot.data.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),);
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            )),
                        child: const Icon(Icons.select_all_outlined,),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: ShapeDecoration(
                          color: Colors.black38,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                      child: const Icon(Icons.camera_alt_outlined),
                    ),
                  ],
                ),
              ),
              assetList.isEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      itemCount: 10,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.grey,
                        );
                      },
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      itemCount: assetList.length,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemBuilder: (context, index) {
                        AssetEntity assetEntity = assetList[index];
                        return assetWidget(assetEntity, index);
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget assetWidget(AssetEntity assetEntity, int index) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: ()async {
              final convertToFile = await assetEntity.originFile;
              if(!mounted) return;
              Navigator.of(context).push(
              createRoute(PreviewEditVideoScreen(videoFile: convertToFile!)));
            },
            child: AssetEntityImage(
              assetEntity,
              isOriginal: false,
              thumbnailSize: const ThumbnailSize.square(1000),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, StackTrace) {
                return const Center(child: Text('Error'));
              },
            ),
          ),
        ),
        if (assetEntity.type == AssetType.video)
          Positioned(
            bottom: 5,
            right: 5,
            child: Text(
              // convert to 00:00
              convertDuration(assetEntity.videoDuration),
              style: const TextStyle(color: Colors.white),
            ),
          )
      ],
    );
  }

  // convert duration to 00:00
  String convertDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}