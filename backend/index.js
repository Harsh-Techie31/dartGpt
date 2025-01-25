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
  const { convoId, convoTitle, messages } = req.body;

  if (!convoId || !convoTitle || !Array.isArray(messages)) {
    return res.status(400).json({
      msg: "Invalid data. 'convoId', 'convoTitle', and 'messages' are required.",
    });
  }

  try {
    const existingConversation = await Conversation.findOne({ convoId });

    if (existingConversation) {
      existingConversation.convoTitle = convoTitle;
      existingConversation.messages = messages;
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
      });
      return res.status(200).json({
        msg: "Conversation created successfully!",
        conversation: newConversation,
      });
    }
  } catch (error) {
    return res.status(400).json({
      msg: error.message,
    });
  }
});

// Other routes...
app.get("/get-conversations", async (req, res) => {
  try {
    const conversations = await Conversation.find({}, "convoId convoTitle").sort({
      createdAt: -1,
    });

    if (!conversations || conversations.length === 0) {
      return res.status(404).json({ msg: "No conversations found." });
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
