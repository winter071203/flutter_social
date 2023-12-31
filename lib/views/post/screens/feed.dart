import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:insta_node_app/utils/helpers/asset_helper.dart';
import 'package:insta_node_app/models/post.dart';
import 'package:insta_node_app/models/story.dart';
import 'package:insta_node_app/providers/auth_provider.dart';
import 'package:insta_node_app/recources/post_api.dart';
import 'package:insta_node_app/recources/story_api.dart';
import 'package:insta_node_app/utils/helpers/helper_functions.dart';
import 'package:insta_node_app/views/message/screens/conversation.dart';
import 'package:insta_node_app/views/notification/screens/notifications.dart';
import 'package:insta_node_app/views/post/widgets/post_card.dart';
import 'package:insta_node_app/views/story/widgets/story_list.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String accessToken;
  const HomeScreen({super.key, required this.accessToken});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> _posts = [];
  List<Stories> _stories = [];
  int page = 1;
  int limit = 8;
  bool _isLoadMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getStories();
    getPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getPosts();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _refeshLoad();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
                centerTitle: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                floating: true,
                titleSpacing: 0,
                title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Scroll to top
                          _scrollController.animateTo(0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: SvgPicture.asset(AssetHelper.icSvg,
                              height: 32,
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context).colorScheme.secondary,
                                  BlendMode.srcATop)),
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () async {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => NotificationScreen()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(Icons.favorite_outline),
                          )),
                      GestureDetector(
                        onTap: () async {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => Conversation()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Icon(FontAwesomeIcons.comment),
                        ),
                      ),
                    ])),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                        child: StoryListWidget(
                      stories: [..._stories],
                    )),
                    const SizedBox(height: 10),
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Colors.grey[500],
                    )
                  ],
                ),
              ),
            ),
            _posts.isEmpty
                ? emptyPostUi()
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (index == _posts.length) {
                          return SizedBox(
                              height: 200,
                              child: Center(
                                child: Opacity(
                                    opacity: _isLoadMore ? 1.0 : 0.0,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    )),
                              ));
                        }
                        return PostCard(
                          post: _posts[index],
                          deletePost: _deletePost,
                        );
                      },
                      childCount: _posts.length + 1,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _refeshLoad() async {
    setState(() {
      _posts = [];
      _stories = [];
      page = 1;
    });
    getStories();
    getPosts();
  }

  Widget emptyPostUi() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Text('No post'),
        ),
      ),
    );
  }

  void getStories() async {
    final res = await StoryApi().getStories(widget.accessToken);
    if (res is String) {
      if (!mounted) return;
      showSnackBar(context, 'Error', res);
    } else {
      List<Stories> temp = [...res];
      if (!mounted) return;
      final user = Provider.of<AuthProvider>(context, listen: false).auth.user!;
      final tempStories =
          temp.firstWhere((element) => element.user!.sId == user.sId,
              orElse: () => Stories(
                  stories: [],
                  user: UserPost.fromJson({
                    '_id': user.sId,
                    'username': 'Your Story',
                    'avatar': user.avatar,
                  })));
      // remove old story
      temp.removeWhere((element) => element.user!.sId == user.sId);
      if (tempStories.user!.username != 'Your Story') {
        final newStories = Stories.fromJson({
          ...tempStories.toJson(),
          'user': {
            ...tempStories.user!.toJson(),
            'username': 'Your Story',
          }
        });
        temp.insert(0, newStories);
      } else {
        temp.insert(0, tempStories);
      }
      setState(() {
        _stories = [...temp];
      });
    }
  }

  void getPosts() async {
    if (_posts.isNotEmpty && _posts.length % limit != 0) {
      setState(() {
        _isLoadMore = false;
      });
      return;
    }
    final res = await PostApi().getPosts(widget.accessToken, page, limit);
    if (res is List) {
      setState(() {
        _posts = [..._posts, ...res];
        page++;
      });
    } else {
      if (!mounted) return;
      showSnackBar(context, 'Error', res);
    }
  }

  void _deletePost(String postId) async {
    final res = await PostApi().deletePost(postId, widget.accessToken);
    if (res is String) {
      if (!mounted) return;
      showSnackBar(context, 'Error', res);
    } else {
      setState(() {
        _posts.removeWhere((post) => post.sId == postId);
      });
    }
  }
}
