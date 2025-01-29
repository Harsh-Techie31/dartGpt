import 'dart:typed_data';
// import 'dart:ui_web';

// import 'package:dartgpt/constant/constants.dart';
import 'package:dartgpt/models/message-model.dart';
import 'package:dartgpt/providers/conversation-provider.dart';
import 'package:dartgpt/providers/model-proivder.dart';
import 'package:dartgpt/screens/login-screen.dart';
import 'package:dartgpt/services/api-services.dart';
import 'package:dartgpt/services/auths.dart';
// import 'package:dartgpt/services/assets.dart';
// import 'package:dartgpt/services/image-pick.dart';
import 'package:dartgpt/services/img-upload.dart';
import 'package:dartgpt/widgets/chat-widget.dart';
import 'package:dartgpt/widgets/drop-down.dart';
import 'package:dartgpt/widgets/image-picker-ui.dart';
import 'package:dartgpt/widgets/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String? conversationId; // Pass the conversationId

  const ChatScreen({super.key, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  AuthMethods AM = AuthMethods();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isTyping = false;
  bool isUploading = false; // Track upload state
  String? uploadedImageUrl; // Store the uploaded image URL
  TextEditingController textEditingController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // Add ScrollController
  Uint8List? _file;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    if (widget.conversationId != null) {
      _loadConversation(widget.conversationId!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final convoProvider =
          Provider.of<ConversationProvider>(context, listen: false);
      convoProvider.initializeConversation();
    });
  }

  void _loadConversation(String convoId) {
    // Fetch the conversation using API or from a provider
    // Use convoId to fetch the messages for that specific conversation
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  void _scrollToBottom() {
    // Scroll to the bottom with animation
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _selectImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    // Show dialog to choose image source
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Center(
            child: Text(
              "Pick an Image",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          children: [
            buildDialogOption(
              context,
              label: "Take a Photo",
              icon: Icons.camera_alt_outlined,
              onTap: () async {
                Navigator.pop(context);
                // Pick image from camera
                _file = await picker
                    .pickImage(source: ImageSource.camera)
                    .then((pickedFile) => pickedFile?.readAsBytes());
                if (_file != null) {
                  setState(() {
                    isUploading = true; // Start uploading
                  });
                  String? url =
                      await uploadImageToCloudinary(_file!); // Upload the file
                  if (url != null) {
                    setState(() {
                      isUploading = false;
                      uploadedImageUrl = url; // Store the URL
                    });
                  }
                }
              },
            ),
            const Divider(height: 1, thickness: 1),
            buildDialogOption(
              context,
              label: "Choose a Photo",
              icon: Icons.photo_library_outlined,
              onTap: () async {
                Navigator.pop(context);
                // Pick image from gallery
                _file = await picker
                    .pickImage(source: ImageSource.gallery)
                    .then((pickedFile) => pickedFile?.readAsBytes());
                if (_file != null) {
                  setState(() {
                    isUploading = true; // Start uploading
                  });
                  String? url =
                      await uploadImageToCloudinary(_file!); // Upload the file
                  if (url != null) {
                    setState(() {
                      isUploading = false;
                      uploadedImageUrl = url; // Store the URL
                    });
                  }
                }
              },
            ),
            const Divider(height: 1, thickness: 1),
            buildDialogOption(
              context,
              label: "Cancel",
              icon: Icons.close,
              isCancel: true,
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleNewConversation(
      ConversationProvider convoProvider) async {
    
    String title = await convoProvider.finalizeConversationTitle();
    String convoid = convoProvider.conversationId;
    User u = _auth.currentUser!;

    // Save the current conversation to MongoDB
    bool success = await ApiService.saveConversation(
      userId: u.uid,
      convoId: convoid,
      convoTitle: title,
      messages: convoProvider.getApiJson(),
    );

    if (success) {
      // Initialize a new conversation
      convoProvider.initializeConversation();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conversaton Saved!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save the conversation.')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchConvos() async {
    return await ApiService.getAllConversations();
  }

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final convoProvider = Provider.of<ConversationProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white), // Hamburger Icon
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
            print("[log] opened drawer");
          },
        ),
        title: const Text(
          "ChatGPT",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(onPressed: () async{
            String ans = await AM.logout();

            if(ans == 'done'){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  LoginPage()));
            }

          }, icon: Icon(Icons.logout , color: Colors.white,)),

          IconButton(
            onPressed: () => _handleNewConversation(convoProvider),
            icon: const Icon(Icons.edit_note, color: Colors.white),
          ),
          IconButton(
            onPressed: () async {
              await showModalBottomSheet(
                backgroundColor: Colors.black,
                context: context,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          "Choose model: ",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        ModelsDropDown(),
                      ],
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
          // Add new conversation button
        ],
      ),
      drawer: Container(
        width: MediaQuery.of(context).size.width *
            0.7, // Set drawer width to 70% of the screen
        child: Drawer(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchConvos(), // Future to fetch past conversations
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text("No past conversations found."));
              }

              // If data is available, show the list of past conversations
              return Container(
                color: Colors.black, // Black background for the entire drawer
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.only(top: 15.0, left: 20.0),
                      color: Colors.black,
                      child: const Text(
                        'Chats',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          // fontWeight: FontWeight,
                        ),
                      ),
                    ),
                    const Divider(),

                    // Loop through the fetched conversations and display them
                    ...snapshot.data!.map<Widget>((convo) {
                      return ListTile(
                        title: Text(
                          convo['convoTitle'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                        onTap: () async {
                          List<Message> oldChats =
                              await fetchMessages(convo['convoId']);
                          Navigator.pop(context);
                          convoProvider.reInitializeConversation(
                              convo['convoId'], oldChats);
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Flexible(
              child: StreamBuilder<List<Message>>(
                stream: convoProvider.messageStream, // Listen to updates
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // If no messages, show the placeholder text
                    return Center(
                      child: Text(
                        "What can I help with?", // Your message
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    );
                  }

                  final messages = snapshot.data!;

                  // Scroll to the bottom after rendering messages
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollToBottom();
                    }
                  });

                  return ListView.builder(
                    controller:
                        _scrollController, // Assign the ScrollController
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUser = message.role == 'user';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ChatBubble(
                          msg: message.content,
                          index: isUser ? 0 : 1,
                          imageUrl: message.url, // User (0) or Assistant (1)
                        ),
                      );
                    },
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

            // Square Box for uploading image (above TextField)
            Padding(
              padding: const EdgeInsets.only(
                right: 30,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align items to the right
                children: [
                  if (isUploading)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const SpinKitFadingCircle(
                        color: Colors
                            .white, // Adjust the color of the spinner as needed
                        size: 40, // Adjust the size of the spinner as needed
                      ),
                    )
                  else if (uploadedImageUrl != null)
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.network(
                            uploadedImageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child; // Image loaded, show the image
                              } else {
                                return const Center(
                                  child: SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                uploadedImageUrl =
                                    null; // Remove the uploaded image
                              });
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                  left: 12.0, right: 12, bottom: 12, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Plus Icon to the left of the TextField
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_a_photo_rounded,
                          color: Colors.white),
                      onPressed: () {
                        _selectImage(context);
                      },
                    ),
                  ),

                  // Material widget for TextField and Send Button
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 4.0),
                        child: Row(
                          children: [
                            // TextField for typing the message
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors
                                      .grey[900], // Slight greyish background
                                  borderRadius: BorderRadius.circular(
                                      30), // Rounded corners for better UI
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4), // Inner spacing
                                child: TextField(
                                  controller: textEditingController,
                                  minLines: 1, // Starts with 1 line
                                  maxLines: 9, // Expands up to 9 lines
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: "Type a message...",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder
                                        .none, // No border for a clean look
                                  ),
                                ),
                              ),
                            ),
                            // Send Button Icon
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: () {
                                if (textEditingController.text.trim().isEmpty) {
                                  return; // Don't send the message
                                }
                                // Send the message along with the image (if exists)
                                if (uploadedImageUrl == null) {
                                  convoProvider.addUserMessage(
                                      textEditingController.text,
                                      modelsProvider.getCurrentModel,
                                      null

                                      // imageUrl: uploadedImageUrl,
                                      );
                                } else {
                                  convoProvider.addUserMessage(
                                      textEditingController.text,
                                      modelsProvider.getCurrentModel,
                                      uploadedImageUrl
                                      // imageUrl: uploadedImageUrl,
                                      );
                                }
                                textEditingController.clear();
                                setState(() {
                                  isTyping = true;
                                  uploadedImageUrl =
                                      null; // Clear the uploaded image
                                });

                                convoProvider.addListener(() {
                                  setState(() => isTyping = false);
                                  _scrollToBottom();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
