import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";
import Conversation from "./sample-model.js";

const app = express();
dotenv.config();

const MONGOOSE_URI =
  "mongodb+srv://harshchoudhary3113:nova123@flutter.p3a73.mongodb.net/?retryWrites=true&w=majority&appName=flutter";

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.send("Hello World!");
});

async function main() {
  try {
    await mongoose.connect(MONGOOSE_URI);
    console.log("Connected to MongoDB");
  } catch (e) {
    console.log("ERROR: " + e.message);
  }
}

const PORT = 2000;
main().then(() =>
  app.listen(PORT, "0.0.0.0", () => {
    console.log("Connected to server at " + PORT);
  })
);

app.post("/post-data", async (req, res) => {
  const { convoId, convoTitle, messages } = req.body;

  if (!convoId || !convoTitle || !Array.isArray(messages)) {
    return res.status(400).json({
      msg: "Invalid data. 'convoId', 'convoTitle', and 'messages' are required.",
    });
  }

  try {
    // Check if the conversation already exists
    const existingConversation = await Conversation.findOne({ convoId });

    if (existingConversation) {
      // If the conversation exists, update it with the new messages and title
      existingConversation.convoTitle = convoTitle;
      existingConversation.messages = messages;

      await existingConversation.save(); // Save the updated conversation

      return res.status(200).json({
        msg: "Conversation updated successfully!",
        conversation: existingConversation,
      });
    } else {
      // If the conversation doesn't exist, create a new one
      const newConversation = await Conversation.create({
        convoId,
        convoTitle,
        messages,
      });

      return res.status(200).json({
        msg: "Conversation created successfully!",
        conversation: newConversation,
      });
    }
  } catch (error) {
    return res.status(400).json({
      msg: error.message + " I AM DORaemon [log]",
    });
  }
});

// app.get("/user-data", async (req, res) => {
//   const email = req.query.email;

//   try {
//     const user = await User.findOne({ email });

//     if (!user) {
//       return res.status(404).json({ msg: "User not found" });
//     }

//     return res.status(200).json({
//       msg: "User fetched successfully",
//       user: { id: user._id, username: user.email },
//     });
//   } catch (error) {
//     return res.status(400).json({ msg: error.message });
//   }
// });
app.get("/get-conversations", async (req, res) => {
  try {
    // Fetch only the convoId and convoTitle from the database
    // Sort by createdAt field in descending order to get the latest conversations first
    const conversations = await Conversation.find({}, "convoId convoTitle")
      .sort({ createdAt: -1 }); // Sort by createdAt in descending order

    // If no conversations are found
    if (!conversations || conversations.length === 0) {
      return res.status(404).json({ msg: "No conversations found." });
    }

    // Send the conversations as the response
    return res.status(200).json({
      msg: "Conversations fetched successfully.",
      conversations,
    });
  } catch (error) {
    // Handle errors
    return res.status(500).json({
      msg: "An error occurred while fetching conversations.",
      error: error.message,
    });
  }
});

app.get("/get-conversation/:convoId", async (req, res) => {
  try {
    // Get the convoId from the request parameters
    const convoId = req.params.convoId;

    // Query the database to find the conversation by convoId and exclude the '_id' field from messages
    const conversation = await Conversation.findOne({ convoId: convoId }).select('convoId messages -_id');

    // If no conversation is found, return an error
    if (!conversation) {
      return res.status(404).json({ msg: "Conversation not found." });
    }

    // Return the convoId and messages of the found conversation, excluding '_id' in messages
    return res.status(200).json({
      msg: "Conversation messages fetched successfully.",
      convoId: conversation.convoId, // Include convoId in the response
      messages: conversation.messages, // messages without '_id' field
    });
  } catch (error) {
    // Handle errors
    return res.status(500).json({
      msg: "An error occurred while fetching the conversation.",
      error: error.message,
    });
  }
});



