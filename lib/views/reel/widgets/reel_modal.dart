import 'package:flutter/material.dart';
import 'package:insta_node_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ReelModal extends StatefulWidget {
  final String reelId;
  final String reelUserId;
  final Function deleteReel;
  final Function savePost;
  final bool isSaved;
  const ReelModal({
    super.key,
    required this.reelId,
    required this.reelUserId,
    required this.deleteReel,
    required this.savePost,
    required this.isSaved,
  });

  @override
  State<ReelModal> createState() => _ReelModalState();
}

class _ReelModalState extends State<ReelModal> {
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context).auth.user!.sId!;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  widget.savePost();
                  Navigator.pop(context);
                },
                child: widget.isSaved
                    ? Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              )),
                            ),
                            child: Icon(
                              Icons.bookmark,
                              color: Theme.of(context).colorScheme.primary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Unsave',
                          )
                        ],
                      )
                    : Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              )),
                            ),
                            child: Icon(
                              Icons.bookmark_outline,
                              size: 30,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Save',
                          )
                        ],
                      ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      )),
                    ),
                    child: Icon(
                      Icons.flag_outlined,
                      size: 30,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Remix',
                  )
                ],
              ),
                            Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      )),
                    ),
                    child: Icon(
                      Icons.emoji_emotions_outlined,
                      size: 30,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Sequence',
                  )
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey.withOpacity(.3),
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey.withOpacity(.3),
          ),
          rowStartItem(Icons.link_outlined, 'Copy link', () {}, false),
          rowStartItem(
              Icons.report_gmailerrorred_outlined, 'Report', () {}, true),
          userId == widget.reelUserId
              ? rowStartItem(Icons.delete, 'Delete', () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('Delete Post'),
                            content: const Text(
                                'Are you sure you want to delete this post?'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel', style: TextStyle(color: Colors.grey),)),
                              TextButton(
                                  onPressed: () async {
                                    widget.deleteReel();
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red),)),
                            ],
                          ));
                }, true)
              : Container()
        ],
      ),
    );
  }

  Widget rowStartItem(
      IconData icon, String title, Function()? onTap, bool isImportant) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: isImportant
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            const SizedBox(
              width: 16,
            ),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18,
              color: isImportant
                  ? Theme.of(context).colorScheme.error
                  : null
              ),
            )
          ],
        ),
      ),
    );
  }
}
