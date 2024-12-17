import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:umos/chatpage.dart';
import 'package:umos/diary.dart';
import 'package:umos/firebase_options.dart';
import 'package:umos/homepage.dart';
import 'package:umos/login.dart';
import 'package:umos/registration.dart';
import 'package:umos/tutorial.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  Gemini.init(apiKey: 'AIzaSyCIruHwwBikBJhkSPrg5ONR_QAwds9rCQA');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindMenders',
      initialRoute: 'homeView',
      routes: {
        'homeView': (context) => StartPage(),
        'registrationView': (context) => RegistrationPage(),
        'chatView': (context) => ChatScreen(title: 'Dusty',),
        'loginView': (context) => LoginPage(),
        'tutorialView': (context) => TutorialPage(),
        'mainView': (context) => HomePage(),
        'diaryView': (context) => DiaryPage(),
      },
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/img/galaxy.png'),
          )
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text('Welcome to', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 50),),

                        ),
                        Container(
                          child: Text('MindMenders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 50),),
                        ),
                        // SizedBox(height: 20,),
                        // Container(
                        //   child: Image(
                        //     image: AssetImage('assets/img/umos_logo.png'),
                        //   ),
                        // ),
                        
                      ]
                  ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              width: MediaQuery.of(context).size.width*0.9,
              height: 56,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xff5F308D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            
                ),
                onPressed: (){
                  Navigator.of(context).pushNamed('registrationView');
                }, 
                child: Text('회원가입', style: TextStyle(fontFamily: "NotoSansKR", color: Colors.white),)
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              width: MediaQuery.of(context).size.width*0.9,
              height: 56,
              child: Center(
                child: GestureDetector(
                  onTap: (){
                    Navigator.of(context).pushNamed('loginView');
                  }, 
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '계정이 있나요? ',
                          style: TextStyle(color: Color(0xff707070), fontFamily: "NotoSansKR"),
                        ),
                        TextSpan(
                          text: '로그인',
                          style: TextStyle(color: Colors.white, fontFamily: "NotoSansKR", fontWeight: FontWeight.bold),
                        ),
                    ]
                  )
                ),
              ),
            ),
            )
          ],
          )
        ),
    );
  }
}
