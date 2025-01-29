import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";
import Conversation from "./sample-model.js";

const app = express();
dotenv.config();

// MongoDB connection URI
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

// Routes
app.post("/post-data", async (req, res) => {
  console.log("Received request body:", req.body);
  const { convoId, userID, convoTitle, messages } = req.body;

  // Validate request body
  if (!convoId || !convoTitle || !Array.isArray(messages) || !userID) {
    return res.status(400).json({
      msg: "Invalid data. 'convoId', 'convoTitle', 'messages', and 'userID' are required.",
    });
  }

  try {
    const existingConversation = await Conversation.findOne({ convoId });

    if (existingConversation) {
      existingConversation.convoTitle = convoTitle;
      existingConversation.messages = messages;
      // existingConversation.userID = userID;
      await existingConversation.save();

      return res.status(200).json({
        msg: "Conversation updated successfully!",
        conversation: existingConversation,
      });
    } else {
      const newConversation = await Conversation.create({
        convoId,
        convoTitle,
        messages,
        userID,
      });

      return res.status(200).json({
        msg: "Conversation created successfully!",
        conversation: newConversation,
      });
    }
  } catch (error) {
    return res.status(500).json({
      msg: "Server error",
      error: error.message,
    });
  }
});


// Other routes...
app.get("/get-conversations", async (req, res) => {
  const { userID } = req.query;  // Accept userID from query parameters

  // Check if userID is provided
  if (!userID) {
    return res.status(400).json({ msg: "userID is required." });
  }

  try {
    // Find conversations where userID matches the provided userID
    const conversations = await Conversation.find({ userID })
      .select("convoId convoTitle")  // Only return convoId and convoTitle
      .sort({ createdAt: -1 });

    if (!conversations || conversations.length === 0) {
      return res.status(404).json({ msg: "No conversations found for the specified user." });
    }

    return res.status(200).json({
      msg: "Conversations fetched successfully.",
      conversations,
    });
  } catch (error) {
    return res.status(500).json({
      msg: "An error occurred while fetching conversations.",
      error: error.message,
    });
  }
});

app.get("/get-conversation/:convoId", async (req, res) => {
  try {
    const convoId = req.params.convoId;
    const conversation = await Conversation.findOne({ convoId: convoId }).select(
      "convoId messages -_id"
    );

    if (!conversation) {
      return res.status(404).json({ msg: "Conversation not found." });
    }

    return res.status(200).json({
      msg: "Conversation messages fetched successfully.",
      convoId: conversation.convoId,
      messages: conversation.messages,
    });
  } catch (error) {
    return res.status(500).json({
      msg: "An error occurred while fetching the conversation.",
      error: error.message,
    });
  }
});

export default app;
