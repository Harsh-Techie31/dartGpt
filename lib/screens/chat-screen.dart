import 'dart:typed_data';
// import 'dart:ui_web';

import 'package:dartgpt/constant/constants.dart';
import 'package:dartgpt/models/message-model.dart';
import 'package:dartgpt/providers/conversation-provider.dart';
import 'package:dartgpt/providers/model-proivder.dart';
import 'package:dartgpt/services/api-services.dart';
// import 'package:dartgpt/services/assets.dart';
// import 'package:dartgpt/services/image-pick.dart';
import 'package:dartgpt/services/img-upload.dart';
import 'package:dartgpt/widgets/chat-widget.dart';
import 'package:dartgpt/widgets/drop-down.dart';
import 'package:dartgpt/widgets/image-picker-ui.dart';
import 'package:dartgpt/widgets/utils.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isTyping = false;
  bool isUploading = false; // Track upload state
  String? uploadedImageUrl; // Store the uploaded image URL
  TextEditingController textEditingController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // Add ScrollController
  Uint8List? _file;
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

    // Save the current conversation to MongoDB
    bool success = await ApiService.saveConversation(
      convoId: convoid,
      convoTitle: title,
      messages: convoProvider.getApiJson(),
    );

    if (success) {
      // Initialize a new conversation
      convoProvider.initializeConversation();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conversation saved and new convo started!')),
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
        centerTitle: true,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white), // Hamburger Icon
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); 
            print("[log] opened drawer");
          },
        ),
        title: const Text(
          "dartGpt",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await showModalBottomSheet(
                backgroundColor: scaffoldBackgroundColor,
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
          IconButton(
            onPressed: () => _handleNewConversation(convoProvider),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future:  fetchConvos(), // Future to fetch past conversations
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No past conversations found."));
            }

            // If data is available, show the list of past conversations
            return SafeArea(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  SizedBox(
                    height: 60,
                    child: DrawerHeader(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Text(
                        'Past Conversations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  // Loop through the fetched conversations and display them
                  ...snapshot.data!.map((convo) {
                    return ListTile(
                      title: Text(convo['convoTitle']),
                      onTap: () async {
                        List<Message> oldChats = await fetchMessages(convo['convoId']);
                        // Handle interaction for specific conversation
                        print("[log]Selected: $convo");
                        Navigator.pop(context);
                        convoProvider.reInitializeConversation(convo['convoId'] , oldChats);
                        print("[log]Closed DRAWER");
                         // Close the drawer
                      },
                    );
                  })
                ],
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: StreamBuilder<List<Message>>(
                stream: convoProvider.messageStream, // Listen to updates
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
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
                            // Show round buffering animation while the image is loading
                            return Center(
                              child: SpinKitFadingCircle(
                                color: Colors
                                    .white, // Adjust the color of the spinner
                                size: 40, // Adjust the size of the spinner
                              ),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                  left: 12.0, right: 12, bottom: 12, top: 4),
              child: Row(
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
                      color: cardColor,
                      borderRadius: BorderRadius.circular(25),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 4.0),
                        child: Row(
                          children: [
                            // TextField for typing the message
                            Expanded(
                              child: TextField(
                                controller: textEditingController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: "Type a message...",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            // Send Button Icon
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: () {
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
                                  _scrollToBottom(); // Ensure scrolling happens
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
