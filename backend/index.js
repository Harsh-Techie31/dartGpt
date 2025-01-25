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
    const conversation = await Conversation.create({
      convoId,
      convoTitle,
      messages,
    });

    return res.status(200).json({
      msg: "Conversation created successfully!",
      conversation,
    });
  } catch (error) {
    return res.status(400).json({
      msg: error.message,
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

