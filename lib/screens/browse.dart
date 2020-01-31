import 'dart:async';
import 'dart:io';

import 'package:filex/providers/browse_provider.dart';
import 'package:filex/providers/category_provider.dart';
import 'package:filex/screens/apps_screen.dart';
import 'package:filex/screens/category.dart';
import 'package:filex/screens/downloads.dart';
import 'package:filex/screens/images.dart';
import 'package:filex/screens/whatsapp_status.dart';
import 'package:filex/util/consts.dart';
import 'package:filex/util/file_utils.dart';
import 'package:filex/widgets/file_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class Browse extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BrowseProvider>(
      builder: (BuildContext context, BrowseProvider browseProvider, Widget child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "${Constants.appName}",
              style: TextStyle(
                fontSize: 25,
              ),
            ),
            actions: <Widget>[
              IconButton(
                tooltip: "Search",
                onPressed: (){},
                icon: Icon(
                  Feather.search,
                ),
              )
            ],
          ),
          body: browseProvider.loading
              ? Center(
                child: CircularProgressIndicator(),
              )
              : ListView(
            padding: EdgeInsets.only(left: 20),
            children: <Widget>[
              SizedBox(height: 20,),

              Text(
                "Storage Devices".toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),

              browseProvider.loading
                  ? Container(
                height: 100,
                    child: Center(
                child: CircularProgressIndicator(),
              ),
                  )
                  : ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: browseProvider.availableStorage.length,
                itemBuilder: (BuildContext context, int index) {
                  FileSystemEntity item = browseProvider.availableStorage[index];

                  String path = item.path.split("Android")[0];
                  double percent = index == 0
                      ?double.parse((browseProvider.usedSpace / browseProvider.totalSpace * 100)
                      .toStringAsFixed(0))/100
                      :double.parse((browseProvider.usedSDSpace / browseProvider.totalSDSpace * 100)
                      .toStringAsFixed(0))/100;
                  return ListTile(
                    onTap: (){
                      print(path);
                    },
                    contentPadding: EdgeInsets.only(right: 20),
                    leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          index == 0
                              ? Feather.smartphone
                              : Icons.sd_storage,
                          color: index == 0
                              ? Colors.lightBlue
                              : Colors.orange,
                        ),
                      ),
                    ),

                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          index == 0
                              ? "Device"
                              : "SD Card",
                        ),

                        Text(
                          index == 0
                              ? "${FileUtils.formatBytes(browseProvider.usedSpace, 2)} "
                              "used of ${FileUtils.formatBytes(browseProvider.totalSpace, 2)}"
                              : "${FileUtils.formatBytes(browseProvider.usedSDSpace, 2)} "
                              "used of ${FileUtils.formatBytes(browseProvider.totalSDSpace, 2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    subtitle: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: LinearPercentIndicator(
                        padding: EdgeInsets.all(0),
                        backgroundColor: Colors.grey[300],
                        percent: percent,
                        progressColor: index == 0
                            ? Colors.lightBlue
                            : Colors.orange,
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 1,
                          color: Theme.of(context).dividerColor,
                          width: MediaQuery.of(context).size.width - 70,
                        ),
                      ),
                    ],
                  );
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                  width: MediaQuery.of(context).size.width - 70,
                ),
              ),

              SizedBox(height: 20,),

              Text(
                "Categories".toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),

              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: Constants.categories.length,
                itemBuilder: (BuildContext context, int index) {
                  Map category = Constants.categories[index];

                  return ListTile(
                    onTap: () {
                      if(index == Constants.categories.length-1){
                        if(Directory(FileUtils.waPath).existsSync()) {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: WhatsappStatus(
                                title: "${category["title"]}",
                              ),
                            ),
                          );
                        }else{
                          browseProvider.showToast("Please Install Whatsapp to use this feature");
                        }
                      }else if(index == 0){
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: Downloads(
                              title: "${category["title"]}",
                            ),
                          ),
                        );
                        Provider.of<CategoryProvider>(context, listen: false).getDownloads();
                      }else if(index == 5){
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: AppScreen(),
                          ),
                        );
                      }else{
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: index == 1 || index == 2
                                ? Images(
                              title: "${category["title"]}",
                            )
                                : Category(
                              title: "${category["title"]}",
                            ),
                          ),
                        );
                        if(index == 1){
                          Provider.of<CategoryProvider>(context, listen: false).getImages("image");
                        }else if(index == 2){
                          Provider.of<CategoryProvider>(context, listen: false).getImages("video");
                        }else if(index == 3){
                          Provider.of<CategoryProvider>(context, listen: false).getAudios("audio");
                        }else if(index == 4){
                          Provider.of<CategoryProvider>(context, listen: false).getAudios("text");
                        }
                      }
                    },
                    contentPadding: EdgeInsets.all(0),
                    leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        category["icon"],
                        size: 18,
                        color: category["color"],
                      ),
                    ),
                    title: Text(
                      "${category["title"]}",
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 1,
                          color: Theme.of(context).dividerColor,
                          width: MediaQuery.of(context).size.width - 70,
                        ),
                      ),
                    ],
                  );
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                  width: MediaQuery.of(context).size.width - 70,
                ),
              ),


              SizedBox(height: 20,),

              Text(
                "Recent Files".toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),

              FutureBuilder<List<FileSystemEntity>>(
                initialData: [],
                future: FileUtils.getRecentFiles(showHidden: false),
                builder: (context, snapshot) {
                  return snapshot == null
                      ? Container(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : snapshot.hasData
                      ? ListView.separated(
                    padding: EdgeInsets.only(right: 20),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.isEmpty?0:5,
                    itemBuilder: (BuildContext context, int index) {
                      return FileItem(
                        file: snapshot.data[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 1,
                        color: Theme.of(context).dividerColor,
                      );
                    },
                  ): SizedBox();
                }
              ),
            ],
          ),
        );
      },

    );
  }
}
