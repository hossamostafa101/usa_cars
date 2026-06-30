import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:unicons/unicons.dart';
import 'package:talabatfresh/data/remote/url_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../components/show_toast_app.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_page.dart';
import 'map_page.dart';

class AccountStatusPage extends StatefulWidget {
  const AccountStatusPage({Key? key}) : super(key: key);

  @override
  _AccountStatusPageState createState() => _AccountStatusPageState();
}

class _AccountStatusPageState extends State<AccountStatusPage> {
  final _formKey = GlobalKey<FormState>();

  String status = 'good';
  String message = 'Your account is in good standing.';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData icon;
    String title;
    switch (status) {
      case 'good':
        bgColor = Colors.green;
        icon = Icons.check_circle;
        title = "Account in Good Standing";
        break;
      case 'warning':
        bgColor = Colors.orange;
        icon = Icons.warning;
        title = "Account Warning";
        break;
      case 'suspended':
        bgColor = Colors.red;
        icon = Icons.block;
        title = "Account Suspended";
        break;
      default:
        bgColor = Colors.grey;
        icon = Icons.info;
        title = "Status Unknown";
    }
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), //appbar size
        child: AppBar(
          bottomOpacity: 0.0,
          elevation: 0.0,
          shadowColor: Colors.transparent,
          backgroundColor: themeData.scaffoldBackgroundColor,
          leading: Padding(
            padding: EdgeInsets.only(left: size.width * 0.05),
            child: SizedBox(
              height: size.width * 0.1,
              width: size.width * 0.1,
              child: Container(
                decoration: BoxDecoration(
                  color: themeData.scaffoldBackgroundColor.withAlpha(
                    (0.03 * 255).toInt(),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Icon(
                  UniconsLine.bars,
                  color: themeData.secondaryHeaderColor,
                  size: size.height * 0.025,
                ),
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          leadingWidth: size.width * 0.15,
          title: Image.asset(

            'assets/icons/swapup_logo.png', //logo
            height: size.height * 0.06,
            width: size.width * 0.35,
          ),
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.05),
              child: SizedBox(
                height: size.width * 0.1,
                width: size.width * 0.1,
                child: Container(
                  decoration: BoxDecoration(
                    color: themeData.scaffoldBackgroundColor.withAlpha(
                      (0.03 * 255).toInt(),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Icon(
                    UniconsLine.search,
                    color: themeData.secondaryHeaderColor,
                    size: size.height * 0.025,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      // bottomNavigationBar: buildBottomNavBar(1, size, themeData),
      backgroundColor: themeData.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          color: bgColor.withOpacity(0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: bgColor),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(fontSize: 24, color: bgColor, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

}

