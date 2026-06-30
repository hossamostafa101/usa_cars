import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:unicons/unicons.dart';
import 'package:talabatfresh/data/local/cache_helper.dart';
import 'package:talabatfresh/pages/splash_page.dart';

class ChatbotPageB extends StatefulWidget {
  const ChatbotPageB({Key? key}) : super(key: key);

  @override
  _ChatbotPageBState createState() => _ChatbotPageBState();
}

class _ChatbotPageBState extends State<ChatbotPageB> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final String apiKey = 'f9b636960c1347b192d8252d1179c858';
  final String apiUrl = 'https://api.aimlapi.com/chat/completions';
  bool _isTyping = false;

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({'text': message, 'isUserMessage': true});
      _isTyping = true;
    });
    _controller.clear();

    // Check for logout commands
    if (message.toLowerCase().contains('logout')) {
      setState(() {
        _isTyping = false;
        _messages.add({'text': 'Logging out...', 'isUserMessage': false});
      });

      // Perform logout
      await CacheHelper.removeData(key: 'token');
      await CacheHelper.removeData(key: 'id');
      await CacheHelper.removeData(key: 'firstName');
      await CacheHelper.removeData(key: 'lastName');
      await CacheHelper.removeData(key: 'username');
      await CacheHelper.removeData(key: 'email');

      Timer(const Duration(milliseconds: 400), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashPage()),
        );
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
              'You are an assistant AI for the SwapUp app, which helps users swap digital services.'
                  ' Provide accurate and concise answers about service listings, finding swap partners,'
                  ' adding services, setting preferences, and navigating the app in English.'
                  ' For queries about swapping services, give clear, practical advice and guide users'
                  ' on how to post, search, and manage swap deals.'
                  ' For unrecognized commands, respond politely and suggest relevant service-swapping actions.',
            },
            {'role': 'user', 'content': message},
          ],
          'temperature': 0.7,
          'top_p': 0.7,
          'frequency_penalty': 1,
          'max_tokens': 512,
          'top_k': 50,
        }),
      );

      setState(() {
        _isTyping = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          final botMessage =
              data['choices']?[0]['message']['content'] ??
              data['content'] ??
              'No response content available';
          setState(() {
            _messages.add({'text': botMessage, 'isUserMessage': false});
          });
        } catch (e) {
          setState(() {
            _messages.add({
              'text': 'Error: Failed to parse response - $e',
              'isUserMessage': false,
            });
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        setState(() {
          _messages.add({
            'text':
                'Error: Server returned ${response.statusCode} - $errorMessage',
            'isUserMessage': false,
          });
        });
      }
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'text': 'Error: Failed to connect - $e',
          'isUserMessage': false,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var w = size.width;
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), //appbar size
        child: AppBar(
          bottomOpacity: 0.0,
          elevation: 0.0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.cyan[50],
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
            'assets/icons/swapup_logo_b.png', //logo
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
      backgroundColor: themeData.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.cyan[50]!, Colors.grey[100]!],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 12.0,
                          ),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: const SpinKitThreeBounce(
                            color: Color(0xFF00B2CA),
                            size: 20.0,
                          ),
                        ),
                      );
                    }
                    final isUserMessage = _messages[index]['isUserMessage'];
                    return Container(
                      margin: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment:
                            isUserMessage
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14.0,
                              horizontal: 16.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: const Radius.circular(20.0),
                                topRight: const Radius.circular(20.0),
                                bottomRight: Radius.circular(
                                  isUserMessage ? 0 : 20.0,
                                ),
                                topLeft: Radius.circular(
                                  isUserMessage ? 20.0 : 0,
                                ),
                              ),
                              color:
                                  isUserMessage
                                      ? Color(0xFF00B2CA)
                                      : Colors.grey[200],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: BoxConstraints(maxWidth: w * 2 / 3),
                            child: Text(
                              _messages[index]['text'],
                              style: TextStyle(
                                color:
                                    isUserMessage
                                        ? Colors.white
                                        : Colors.black87,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder:
                      (_, __) =>
                          const Padding(padding: EdgeInsets.only(top: 10.0)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Ask about services, logout, or more...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 14.0,
                          ),
                        ),
                        onSubmitted: _sendMessage,
                        enabled: !_isTyping,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    CircleAvatar(
                      backgroundColor: Color(0xFF00B2CA),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed:
                            _isTyping
                                ? null
                                : () => _sendMessage(_controller.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
