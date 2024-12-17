
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:umos/functions/CRUD.dart';
import 'package:umos/functions/shared_pref.dart';

const _apiKey = 'AIzaSyCIruHwwBikBJhkSPrg5ONR_QAwds9rCQA';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.title});

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the app bar to the top of the screen
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make the app bar transparent
        elevation: 0, // Remove the shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white), // Back button icon
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      ),
      body: const ChatWidget(apiKey: _apiKey),
    );
  }

}

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    required this.apiKey,
    super.key,
  });

  final String apiKey;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<({Image? image, String? text, bool fromUser})> _generatedContent =
      <({Image? image, String? text, bool fromUser})>[];
  bool _loading = false;
  String? emotion = "";
  CRUD crud = new CRUD();
  String systemprompt = "";


  @override
  void initState() {
    super.initState();
    _initializeData().then((_) {
      setState(() {
        systemprompt = """
        너의 이름은 Dusty야. 나는 너의 친구이자 상담사이자, 너는 마음을 듣는 친구야. 
        너가 마주하는 너의 친구는 이러한 상황을 마주했어.$emotion. 
        자 이제 이 친구의 상황을 이해하고 부정적인 생각을 긍정적으로 바꿀 수 있도록 도와줘. 
        근데 친절하지만 차근차근 길지 않게 친구처럼 대화하면 좋겠어.
        """;
      });
      _model = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: widget.apiKey,
      systemInstruction: Content.text(systemprompt),
    );
    _chat = _model.startChat();
    });
    
  }


Future<void> _initializeData() async {
    // Wait for the email preference to be retrieved first
    String? email = await Helperfunctions.getUserEmailSharedPreference();
    
    if (email != null) {
      // Wait for the emotion data after getting the email
      String emotionData = await crud.getEmotion(email);
      setState(() {
        emotion = emotionData;
        print("this is: $emotion");
      });
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  void _updateSystemPrompt(String selectedCity) {
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final textFieldDecoration = InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Dusty랑 대화를 시작해보세요!',
      hintStyle: TextStyle(color: Colors.purple), // Change hint text color to white
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Colors.white, // Change border color to white
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Colors.white, // Change focused border color to white
        ),
      ),
      // fillColor: Colors.white, // Change fill color to white
      filled: true, // Ensure the fill color is applied
    );

    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/img/galaxy.png'),
          ),
        ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _apiKey.isNotEmpty
                ? ListView.builder(
                    controller: _scrollController,
                    itemBuilder: (context, idx) {
                      final content = _generatedContent[idx];
                      return MessageWidget(
                        text: content.text,
                        image: content.image,
                        isFromUser: content.fromUser,
                      );
                    },
                    itemCount: _generatedContent.length,
                  )
                : ListView(
                    children: const [
                      Text(
                        'No API key found. Please provide an API Key using '
                        "'--dart-define' to set the 'API_KEY' declaration.",
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 15,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.purple,
                    ),
                    autofocus: true,
                    focusNode: _textFieldFocus,
                    decoration: textFieldDecoration,
                    controller: _textController,
                    onSubmitted: _sendChatMessage,
                  ),
                ),
                // const SizedBox.square(dimension: 15),
                // IconButton(
                //   onPressed: !_loading
                //       ? () async {
                //           _sendImagePrompt(_textController.text);
                //         }
                //       : null,
                //   icon: Icon(
                //     Icons.image,
                //     color: _loading
                //         ? Theme.of(context).colorScheme.secondary
                //         : Theme.of(context).colorScheme.primary,
                //   ),
                // ),
                if (!_loading)
                  IconButton(
                    onPressed: () async {
                      _sendChatMessage(_textController.text);
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.purple,
                    ),
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Future<void> _sendImagePrompt(String message) async {
  //   setState(() {
  //     _loading = true;
  //   });
  //   try {
  //     ByteData catBytes = await rootBundle.load('assets/images/cat.jpg');
  //     ByteData sconeBytes = await rootBundle.load('assets/images/scones.jpg');
  //     final content = [
  //       Content.multi([
  //         TextPart(message),
  //         // The only accepted mime types are image/*.
  //         DataPart('image/jpeg', catBytes.buffer.asUint8List()),
  //         DataPart('image/jpeg', sconeBytes.buffer.asUint8List()),
  //       ])
  //     ];
  //     _generatedContent.add((
  //       image: Image.asset("assets/images/cat.jpg"),
  //       text: message,
  //       fromUser: true
  //     ));
  //     _generatedContent.add((
  //       image: Image.asset("assets/images/scones.jpg"),
  //       text: null,
  //       fromUser: true
  //     ));

  //     var response = await _model.generateContent(content);
  //     var text = response.text;
  //     _generatedContent.add((image: null, text: text, fromUser: false));

  //     if (text == null) {
  //       _showError('No response from API.');
  //       return;
  //     } else {
  //       setState(() {
  //         _loading = false;
  //         _scrollDown();
  //       });
  //     }
  //   } catch (e) {
  //     _showError(e.toString());
  //     setState(() {
  //       _loading = false;
  //     });
  //   } finally {
  //     _textController.clear();
  //     setState(() {
  //       _loading = false;
  //     });
  //     _textFieldFocus.requestFocus();
  //   }
  // }
Future<void> _sendChatMessage(String message) async {
  _textController.clear();
  setState(() {
    _loading = true;
  });

  try {
    // Add the user's message
    _generatedContent.add((image: null, text: message, fromUser: true));
    
    // Fetch the assistant's response
    final response = await _chat.sendMessage(Content.text(message));
    final text = response.text;

    // Add the assistant's message along with an image
    _generatedContent.add((
      image: Image(image: AssetImage('assets/img/umos_tut1.png')), // Your image here
      text: text,
      fromUser: false
    ));

    if (text == null) {
      _showError('No response from API.');
      return;
    } else {
      setState(() {
        _loading = false;
        _scrollDown();
      });
    }
  } catch (e) {
    _showError(e.toString());
    setState(() {
      _loading = false;
    });
  } finally {
    _textController.clear();
    setState(() {
      _loading = false;
    });
    _textFieldFocus.requestFocus();
  }
}


  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}
class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    this.image,
    this.text,
    required this.isFromUser,
  });

  final Image? image;
  final String? text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isFromUser && image != null) ...[
          CircleAvatar(
            backgroundColor: Colors.transparent,
            child: image,
          ),
          const SizedBox(width: 8), // Space between the image and the text
        ],
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            decoration: BoxDecoration(
              color: isFromUser
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: MarkdownBody(data: text ?? ""),
          ),
        ),
        if (isFromUser && image != null) ...[
          const SizedBox(width: 8), // Space between the text and the image
          CircleAvatar(
            backgroundColor: Colors.transparent,
            child: image,
          ),
        ],
      ],
    );
  }
}

