import 'package:event_management/src/settings/settings_view.dart';
import 'package:event_management/widget/OptionsWidget.dart';
import 'package:flutter/material.dart';
import 'package:event_management/generated/l10n.dart';


class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static const routeName = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;  

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 30,
            ),
            onPressed: () {
              // print('IconButton pressed ...');
            },
          ),
          title: Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'Inter',
              letterSpacing: 0.0,
            ),
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: brightness == Brightness.dark ? Colors.black : Colors.grey[200],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 1, 0, 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: brightness == Brightness.dark ? Colors.grey[850] : Colors.white, 
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 50,
                      color: Color(0x33000000),
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: brightness == Brightness.dark ? Colors.grey[600] : Colors.white, // Màu vòng tròn theo theme
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey, // Màu viền mặc định
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1531123414780-f74242c2b052?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NDV8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Joy Augustin',
                              style: TextStyle(
                                fontFamily: 'Inter Tight',
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.0,
                                color: brightness == Brightness.dark ? Colors.white : Colors.black, // Màu chữ theo theme
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                              child: Text(
                                'joy@augustin.com',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: brightness == Brightness.dark ? Colors.white : Colors.black, // Màu chữ theo theme
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 16, 0, 0),
              child: Text(
                S.of(context).account,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
              ),
            ),
            OptionsWidget(
              icon: Icons.account_circle_outlined, 
              text: S.of(context).editProfile, 
              onTap: () {
                // Thực hiện hành động chỉnh sửa profile
              },
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 16, 0, 0),
              child: Text(
                S.of(context).general,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16, 
                  color: brightness == Brightness.dark ? Colors.white : Colors.black, 
                ),
              ),
            ),
            OptionsWidget(
              icon: Icons.settings, 
              text: S.of(context).setting, 
              onTap: () {
                Navigator.pushNamed(context, SettingsView.routeName);
              },
            ),
            OptionsWidget(
              icon: Icons.language, 
              text: S.of(context).language,  
              onTap: () {
                Navigator.pushNamed(context, '/language');
              },
            ),
             OptionsWidget(
              icon: Icons.logout, 
              text: S.of(context).logout,  
              onTap: () {
                // _signOut();
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => LoginScreen()),
                // );
              },
            ),
          ],
        ),
      ),
    );
  }
}
