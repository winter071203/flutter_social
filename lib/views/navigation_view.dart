import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insta_node_app/models/auth.dart';
import 'package:insta_node_app/models/notify.dart';
import 'package:insta_node_app/providers/auth_provider.dart';
import 'package:insta_node_app/utils/helpers/helper_functions.dart';
import 'package:insta_node_app/views/add/screens/add.dart';
import 'package:insta_node_app/bloc/chat_bloc/chat_bloc.dart';
import 'package:insta_node_app/bloc/chat_bloc/chat_event.dart';
import 'package:insta_node_app/bloc/noti_bloc/noti_bloc.dart';
import 'package:insta_node_app/bloc/noti_bloc/noti_event.dart';
import 'package:insta_node_app/bloc/online_bloc/oneline_bloc.dart';
import 'package:insta_node_app/bloc/online_bloc/oneline_event.dart';
import 'package:insta_node_app/views/message/screens/calling.dart';
import 'package:insta_node_app/views/keep_alive_screen.dart';
import 'package:insta_node_app/views/post/screens/feed.dart';
import 'package:insta_node_app/views/profile/screens/profile.dart';
import 'package:insta_node_app/views/reel/screens/reels.dart';
import 'package:insta_node_app/views/search/screens/search.dart';
import 'package:insta_node_app/utils/notifi_config.dart';
import 'package:insta_node_app/utils/socket_config.dart';
import 'package:provider/provider.dart';

class MainAppScreen extends StatefulWidget {
  final int initPage;
  const MainAppScreen({super.key, this.initPage = 0});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  late int _currentIndex;
  late PageController _pageControllerWithAdd;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initPage;
    _pageControllerWithAdd = PageController(initialPage: 1);
    _pageController = PageController(initialPage: widget.initPage);
    fetchChatDataMessage();
    fetchNotificationData();
    SocketConfig.socket.on('checkUserOnlineToMe', (data) {
      final onlineBloc = BlocProvider.of<OnlineBloc>(context);
      final state = onlineBloc.state;
      for (var i = 0; i < state.length; i++) {
        if (!data.contains(state[i])) {
          onlineBloc.add(OnlineEventFetch(listUserId: [state[i]]));
        }
      }
    });
    SocketConfig.socket.on('checkUserOnlineToClient', (data) {
      final onlineBloc = BlocProvider.of<OnlineBloc>(context);
      onlineBloc.add(OnlineEventFetch(listUserId: [...data]));
    });
    SocketConfig.socket.on('createNotifyToClient', (data) {
      final newNotify = Notify.fromJson(data);
      NotificationService().showNotification(
        title: newNotify.user!.username!,
        body: newNotify.text!,
      );
    });

    SocketConfig.socket.on('callUserToClient', (data) {
      print(data);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CallingScreen(
                data: data,
              )));
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageControllerWithAdd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final auth = Provider.of<AuthProvider>(context).auth;
    return PageView(
      controller: _pageControllerWithAdd,
      children: [
        KeepAlivePage(
          child: AddScreen(
            handleNaviTapped: () => handleNaviTapped(1),
          ),
        ),
        KeepAlivePage(
          child: Scaffold(
            body: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: <Widget>[..._screens(auth).map((e) => e).toList()],
            ),
            bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 1,
                    ),
                  ),
                ),
                child: CurvedNavigationBar(
                  animationDuration: const Duration(milliseconds: 300),
                  index: _currentIndex,
                  color: dark ? Colors.black : Colors.white,
                  backgroundColor: dark ? Colors.white : Colors.black,
                  buttonBackgroundColor: dark ? Colors.black : Colors.white,
                  letIndexChange: (value) {
                    if (value == 2) {
                      handleNaviTapped(0);
                      return false;
                    }
                    return true;
                  },
                  onTap: navigationTapped,
                  items: [
                    iconWidget(0, Icons.home, Icons.home_outlined),
                    iconWidget(1, Icons.search, Icons.search_outlined),
                    iconWidget(2, Icons.add_box, Icons.add_box_outlined),
                    iconWidget(
                        3, Icons.movie_filter, Icons.movie_filter_outlined),
                    Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(auth.user!.avatar!),
                        radius: 12,
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ],
    );
  }

  void fetchChatDataMessage() async {
    final token =
        Provider.of<AuthProvider>(context, listen: false).auth.accessToken!;
    final chatBloc = BlocProvider.of<ChatBloc>(context);
    chatBloc.add(ChatEventFetch(token: token));
  }

  void fetchNotificationData() async {
    final token =
        Provider.of<AuthProvider>(context, listen: false).auth.accessToken!;
    final notifiBloc = BlocProvider.of<NotiBloc>(context);
    notifiBloc.add(NotiEventFetch(token: token));
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  void handleNaviTapped(int index) {
    _pageControllerWithAdd.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  List<Widget> _screens(Auth auth) => [
        KeepAlivePage(
            child: HomeScreen(
          accessToken: auth.accessToken!,
        )),
        KeepAlivePage(
            child: SearchScreen(
          accessToken: auth.accessToken!,
        )),
        Container(),
        KeepAlivePage(child: ReelsScreen()),
        KeepAlivePage(child: ProfileScreen()),
      ];

  Widget iconWidget(int index, IconData iconActive, IconData iconInactive) {
    final dark = THelperFunctions.isDarkMode(context);
    return Icon(index == _currentIndex ? iconActive : iconInactive,
        color: index == _currentIndex
            ? dark
                ? Colors.white
                : Colors.black
            : Colors.grey.withOpacity(0.8));
  }
}
