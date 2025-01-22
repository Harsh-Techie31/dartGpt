import 'package:dartgpt/constant/constants.dart';
import 'package:dartgpt/services/api-services.dart';
import 'package:dartgpt/services/assets.dart';
import 'package:dartgpt/widgets/chat-widget.dart';
import 'package:dartgpt/widgets/drop-down.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isTyping = false;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
  String openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  // final list = chatMessages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(assetholder.openai),
        ),
        title: const Text(
          "dartGpt",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () async{
                  await showModalBottomSheet(
                    backgroundColor: scaffoldBackgroundColor,
                    context: context, builder: (context){
                    return Padding(
                      
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Choose model : " , style: TextStyle(fontSize: 16 , color: Colors.white ),
                          ),ModelsDropDown()
                        ],
                      ),
                    );
                  });
              },
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  return  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: ChatBubble(msg: chatMessages[index]['msg'].toString(), index: int.parse(chatMessages[index]['chatIndex'].toString()))
                  );
                },
              ),
            ),
            if (isTyping) ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: SpinKitThreeBounce(
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Material(
                color: cardColor,
                borderRadius: BorderRadius.circular(25),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textEditingController,
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (value) {
                            // TODO: Implement message sending
                          },
                          decoration: const InputDecoration(
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                        onPressed: () async{
                          ApiService.getModels();
                          // TODO: Implement send action
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
