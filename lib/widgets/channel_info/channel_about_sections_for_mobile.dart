import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube/widgets/search_view/mobile_searching_view.dart';

class CahnnelAbout extends StatefulWidget {
  final String descriptions;
  final String name;
  final String subscriber;
  final String videocount;
  final String viewcount;
  final String country;
  const CahnnelAbout(
      {super.key,
      required this.descriptions,
      required this.name,
      required this.subscriber,
      required this.videocount,
      required this.viewcount,
      required this.country});

  @override
  State<CahnnelAbout> createState() => _CahnnelAboutState();
}

class _CahnnelAboutState extends State<CahnnelAbout> {
  String getCountryName(String code) {
    final country = Country.tryParse(code); // Get the Country object
    return country?.name ?? ""; // Fallback if the code is invalid
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildAppBar()),
      body: FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 800)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.grey.shade700 : Colors.black54,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Descriptions",
                            style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            textAlign: TextAlign.justify,
                            widget.descriptions,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              height: 1.5,
                              color: isDark ? Colors.white : Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Channel Details",
                            style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.globe,
                                color: isDark ? Colors.white : Colors.grey[800],
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text("www.youtube.com/@${widget.name}",
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 18, 107, 180)))
                            ],
                          ), // Website

                          const SizedBox(
                            height: 10,
                          ),

                          _channelInfo(
                              Icon(
                                Icons
                                    .person_add_alt_outlined, // Updated icon for subscribers
                                color: isDark ? Colors.white : Colors.grey[800],
                              ),
                              "${widget.subscriber} subscribers"), // Subscribers

                          const SizedBox(
                            height: 10,
                          ),

                          _channelInfo(
                              Icon(
                                Icons
                                    .play_circle_fill_outlined, // Updated icon for videos
                                color: isDark ? Colors.white : Colors.grey[800],
                              ),
                              "${widget.videocount} videos"), // Video count

                          const SizedBox(
                            height: 10,
                          ),

                          _channelInfo(
                              Icon(
                                Icons.trending_up, // Updated icon for views
                                color: isDark ? Colors.white : Colors.grey[800],
                              ),
                              "${widget.viewcount} views"), // View count

                          const SizedBox(
                            height: 10,
                          ),

                          _channelInfo(
                              Icon(
                                Icons
                                    .public_outlined, // Updated icon for country
                                color: isDark ? Colors.white : Colors.grey[800],
                              ),
                              getCountryName(widget.country)), // Country

                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    )
                    // _channelInfo(Icon(Icons.access_alarm_sharp),
                    //     widget.subscriber),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget _channelInfo(Widget icon, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
        icon,
        const SizedBox(
          width: 10,
        ),
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back,
          size: 22,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      title: Text(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        widget.name,
        style: GoogleFonts.roboto(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        Icon(
          Icons.cast, // This is the icon you are looking for

          size: 22,
          color: isDark ? Colors.white : Colors.black,
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: Icon(
            CupertinoIcons.search,
            size: 24,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            showSearch(
              context: context,
              delegate: YoutubeSearchDelegate(context: context),
            );
          },
        ),
        const SizedBox(width: 20),
        Icon(
          Icons.more_vert,
          size: 22,
          color: isDark ? Colors.white : Colors.black,
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}
