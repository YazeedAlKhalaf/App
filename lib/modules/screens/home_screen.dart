import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_buddies/data/models/event.dart';
import 'package:flutter_buddies/data/models/project.dart';
import 'package:flutter_buddies/data/repositories/event_repository.dart';
import 'package:flutter_buddies/data/repositories/project_repository.dart';
import 'package:flutter_buddies/widgets/app_bar_icon.dart';
import 'package:flutter_buddies/widgets/event_card.dart';
import 'package:flutter_buddies/widgets/project_card.dart';
import 'package:flutter_buddies/widgets/section_header.dart';
import 'package:flutter_buddies/widgets/user_widgets/user_widgets.dart' as uw;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Function to get number of people online using Discord's public API
  Future<int> getDiscordOnlineNumber() async {
    http.Response response = await http
        .get('https://discord.com/api/guilds/768528774991446088/widget.json');
    Map<String, dynamic> decoded = jsonDecode(response.body);
    dynamic numberOnline = decoded['presence_count'];
    return numberOnline;
  }

  // Get the list of users and shuffle it so different users are shown on the front page each time
  var widgetInfoList = uw.widgetInfoList..shuffle();

  final EventRepository _eventRepository = EventRepository.get();
  final ProjectRepository _projectRepository = ProjectRepository.get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        //! this should change the notification area text to black but it isn't
        value: SystemUiOverlayStyle.light,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white10,
              leading: Image(
                image: AssetImage('assets/global_images/flutterbuddies.png'),
              ),
              centerTitle: true,
              title: Column(
                children: [
                  Text(
                    'Flutter Buddies',
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                  Text(
                    'A Flutter Developer Community',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 14),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    Navigator.pushNamed(context, 'about');
                  },
                  color: Color(0xff45D1FD),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size(double.infinity, 80),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AppBarIcon(
                        iconImage: AssetImage(
                            'assets/global_images/Discord-Logo-Shadowed.png'),
                        iconText: 'Discord',
                        iconColor: Color(0xff8C9EFF),
                        iconFunction: () async {
                          await launch('http://flutterbuddies.com');
                        },
                      ),
                      AppBarIcon(
                        iconImage: AssetImage(
                            'assets/global_images/Twitter-Logo-Shadowed.png'),
                        iconText: 'Twitter',
                        iconColor: Color(0xff00A2F5),
                        iconFunction: () async {
                          await launch('https://twitter.com/Flutter_Buddies');
                        },
                      ),
                      AppBarIcon(
                        iconImage: AssetImage(
                            'assets/global_images/YouTube-Logo-Shadowed.png'),
                        iconText: 'YouTube',
                        iconColor: Color(0xffFF0000),
                        iconFunction: () async {
                          await launch(
                              'https://www.youtube.com/channel/UCxBpCSJUJFj26S-4KwNNR1w');
                        },
                      ),
                      AppBarIcon(
                        iconImage: AssetImage(
                            'assets/global_images/GitHub-Logo-Shadowed.png'),
                        iconText: 'GitHub',
                        iconColor: Color(0xff2771BB),
                        iconFunction: () async {
                          await launch(
                              'https://github.com/Flutter-Buddies/README');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SectionHeader(
                    leadingIcon: Icons.people,
                    headerText: 'Member pages',
                    headerFunction: () {
                      Navigator.pushNamed(context, 'user_widgets_screen');
                    },
                    trailingWidget: Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.green),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Expanded(
                            flex: 1,
                            child: FutureBuilder<int>(
                              future: getDiscordOnlineNumber(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                      '${snapshot.data} members online');
                                } else {
                                  return Text('Loading...');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children: widgetInfoList
                              .map((widgetInfo) =>
                                  MemberCircle(widgetInfo: widgetInfo))
                              .toList() +
                          [SeeMoreCircle()],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  SectionHeader(
                    leadingIcon: Icons.calendar_today,
                    headerText: 'Upcoming Events',
                    headerFunction: () {
                      Navigator.pushNamed(context, 'schedule');
                    },
                    trailingWidget: Text(
                      'See more',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  FutureBuilder<List<Event>>(
                    future: _eventRepository.take(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return GridView.count(
                          // Shrink wrap tells the grid view to let the children define the size
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          // Setting to none so that the shadow isn't clipped
                          clipBehavior: Clip.none,
                          childAspectRatio: 1.5,
                          crossAxisCount: 2,
                          physics: NeverScrollableScrollPhysics(),
                          children: snapshot.data
                              .map((event) => EventCard(
                                    eventName: event.name,
                                    eventImage: AssetImage(
                                        'assets/global_images/Event_Image.png'), // Use generic flutter + calendar image
                                    eventDateTime: event.dateTime,
                                  ))
                              .toList(),
                        );
                      } else {
                        return SizedBox(
                          height: 240,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  SectionHeader(
                    leadingIcon: FontAwesomeIcons.hammer,
                    headerText: 'Active Projects',
                    headerFunction: () {
                      Navigator.pushNamed(context, 'projects');
                    },
                    trailingWidget: Text(
                      'See more',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  FutureBuilder<List<Project>>(
                    future: _projectRepository.take(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: snapshot.data
                              .map((project) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16, bottom: 16),
                                    child: ProjectCard(
                                      projectTitle: project.title,
                                      projectDescription: project.description,
                                      projectImageUri: project.imageUri,
                                      projectTag: project.tag,
                                      url: project.url,
                                    ),
                                  ))
                              .toList(),
                        );
                      } else {
                        return SizedBox(
                          height: 240,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberCircle extends StatelessWidget {
  MemberCircle({this.widgetInfo});

  final uw.WidgetInfo widgetInfo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => widgetInfo.widget,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 76,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(widgetInfo.logoPath),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Positioned(
                    top: -32,
                    left: 18,
                    right: 18,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Stack(
                        children: [
                          Icon(
                            FontAwesomeIcons.crown,
                            color: Colors.yellow[800],
                            size: 40,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              '${widgetInfo.projectsCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                widgetInfo.developer,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SeeMoreCircle extends MemberCircle {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, 'user_widgets_screen'),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.grey[350],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.launch,
                    size: 28,
                  ),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                'See more...',
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
