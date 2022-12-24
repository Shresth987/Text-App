import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:text_app/models/models.dart';
import 'package:text_app/screens/chat_screen.dart';
import 'package:text_app/theme.dart';
import 'package:text_app/widgets/avatar.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:text_app/helpers.dart';
import 'package:jiffy/jiffy.dart';
import 'package:text_app/widgets/display_error_message.dart';
import 'package:text_app/app.dart';

import '../widgets/unread_indicator.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final channelListController  = ChannelListController();
  @override
  Widget build(BuildContext context) {
    return ChannelListCore(
      channelListController: channelListController,
      filter: Filter.and(
        [
          Filter.equal('type', 'messaging'),
          Filter.in_('members', [
            StreamChatCore.of(context).currentUser!.id,
          ])
        ]
      ),


   emptyBuilder: (context) => Center(
     child: Text(
       'So empty . \n Go and message someone.',
           textAlign: TextAlign.center,
     ),
   ),
      errorBuilder: (context, error)=> DisplayErrorMessage(error:
      error),

      loadingBuilder: (context) => Center(
        child: SizedBox(
          height: 100, width: 100,
          child: CircularProgressIndicator(),
        ),
      ),
      listBuilder: (context, channels) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Stories(),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index){
                return _MessageTitle(channel: channels[index]);
              },
              childCount: channels.length,
              ),
            ),
          ],
        );
      },
    );
    // return CustomScrollView(
    //   slivers: [
    //     SliverToBoxAdapter(
    //       child: _Stories(),
    //     ),
    //     SliverList(
    //       delegate: SliverChildBuilderDelegate(_delegate),
    //     ),
    //   ],
    // );
  }
}

class _MessageTitle extends StatelessWidget {
  const _MessageTitle({Key? key, required this.channel}) : super(key: key);

  final Channel channel;

  @override
  Widget build(BuildContext context) {

    return InkWell(
      splashColor: Colors.blue,
      onTap: (){
       Navigator.of(context).push(ChatScreen.routeWithChannel(channel));
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.2,
            )
          )
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Avatar.medium(url: Helpers.getChannelImage(channel, context.currentUser!)),
              ),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(Helpers.getChannelName(channel, context.currentUser!),
                        style:
                    TextStyle(
                        letterSpacing: 0.2,
                        overflow: TextOverflow.ellipsis,
                        wordSpacing: 1.5,
                        fontWeight: FontWeight.w900)
                    ),
                  ),
                  SizedBox(
                      height: 20,

                      child: _buildLastMessage(),

                  ),
                ],
              )),
              Padding(padding: EdgeInsets.only(right: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(
                    height: 4
                  ),
                  _buildLastMessageAt(),
                  const SizedBox(
                    height: 8,
                  ),
                  Center(child: UnreadIndicator(
                    channel: channel,
                  ))
                ],
              ),

              )
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildLastMessage() {
    return BetterStreamBuilder<int>(
      stream: channel.state!.unreadCountStream,
      initialData: channel.state?.unreadCount ?? 0,
      builder: (context, count) {
        return BetterStreamBuilder<Message>(
          stream: channel.state!.lastMessageStream,
          initialData: channel.state!.lastMessage,
          builder: (context, lastMessage) {
            return Text(
              lastMessage.text ?? '',
              overflow: TextOverflow.ellipsis,
              style: (count > 0)
                  ? const TextStyle(
                fontSize: 12,
                color: AppColors.secondary,
              )
                  : const TextStyle(
                fontSize: 12,
                color: AppColors.textFaded,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLastMessageAt() {
    return BetterStreamBuilder<DateTime>(
      stream: channel.lastMessageAtStream,
      initialData: channel.lastMessageAt,
      builder: (context, data) {
        final lastMessageAt = data.toLocal();
        String stringDate;
        final now = DateTime.now();

        final startOfDay = DateTime(now.year, now.month, now.day);

        if (lastMessageAt.millisecondsSinceEpoch >=
            startOfDay.millisecondsSinceEpoch) {
          stringDate = Jiffy(lastMessageAt.toLocal()).jm;
        } else if (lastMessageAt.millisecondsSinceEpoch >=
            startOfDay
                .subtract(const Duration(days: 1))
                .millisecondsSinceEpoch) {
          stringDate = 'YESTERDAY';
        } else if (startOfDay.difference(lastMessageAt).inDays < 7) {
          stringDate = Jiffy(lastMessageAt.toLocal()).EEEE;
        } else {
          stringDate = Jiffy(lastMessageAt.toLocal()).yMd;
        }
        return Text(
          stringDate,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: -0.2,
            fontWeight: FontWeight.w600,
            color: AppColors.textFaded,
          ),
        );
      },
    );
  }
}

class _Stories extends StatelessWidget {
  const _Stories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: SizedBox(
        height: 134,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 16),
              child: Text('Stories',
                style: TextStyle(fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.textFaded,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index){
                  final faker = Faker();

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 60.0,
                      child: _StoryCard(
                        storyData: StoryData(
                          name: faker.person.name(),
                          url: Helpers.randomPictureUrl(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );

  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({Key? key, required this.storyData}) : super(key: key);

  final StoryData storyData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Avatar.medium(url: storyData.url),
        Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                storyData.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
        )
      ],
    );
  }
}