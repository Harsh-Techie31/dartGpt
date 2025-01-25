import mongoose from 'mongoose';

// Schema for individual messages
const messageSchema = new mongoose.Schema({
  role: {
    type: String,
    enum: ['user', 'assistant'], // Specify allowed roles
    required: true,
  },
  content: {
    type: String,
    required: true, // Content is mandatory
  },
  url: {
    type: String,
    default: null, // URL is optional and can be null
  },
  timestamp: {
    type: Date,
    default: Date.now, // Automatically set timestamp
  },
});

// Schema for a conversation
const conversationSchema = new mongoose.Schema(
  {
    convoId: {
      type: String,
      required: true,
      unique: true, // Ensure each conversation has a unique ID
    },
    convoTitle: {
      type: String,
      required: true, // Title of the conversation
    },
    messages: [messageSchema], // Array of embedded message documents
  },
  {
    timestamps: true, // Automatically add `createdAt` and `updatedAt`
  }
);

const Conversation = mongoose.model('Conversation', conversationSchema);

export default Conversation;
