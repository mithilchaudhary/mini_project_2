import 'package:miniproj2/models/story_model.dart';
import 'package:miniproj2/models/chat_model.dart';
import 'package:miniproj2/models/message_model.dart';

List<StoryModel> getStories() {
  List<StoryModel> stories = [];
  StoryModel storyModel = new StoryModel();

  //1
  storyModel.imgUrl =
      "https://images.unsplash.com/photo-1483726234545-481d6e880fc6?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80";
  storyModel.username = "Satyam";
  stories.add(storyModel);

  storyModel = new StoryModel();

  //1
  storyModel.imgUrl =
      "https://images.unsplash.com/photo-1459356979461-dae1b8dcb702?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80";
  storyModel.username = "Mithil";
  stories.add(storyModel);

  storyModel = new StoryModel();

  //1
  storyModel.imgUrl =
      "https://images.unsplash.com/photo-1596392927852-2a18c336fb78?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80";
  storyModel.username = "Athrav";
  stories.add(storyModel);

  storyModel = new StoryModel();

  //1
  storyModel.imgUrl =
      "https://images.unsplash.com/photo-1498050108023-c5249f4df085?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1052&q=80";
  storyModel.username = "Chirag";
  stories.add(storyModel);

  storyModel = new StoryModel();

  //1
  storyModel.imgUrl =
      "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80";
  storyModel.username = "Nihal";
  stories.add(storyModel);

  storyModel = new StoryModel();

  //1
  storyModel.imgUrl =
      "https://images.unsplash.com/photo-1550047758-d235a6bb7462?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80";
  storyModel.username = "Hamza";
  stories.add(storyModel);

  storyModel = new StoryModel();

  return stories;
}

List<ChatModel> getChats() {
  List<ChatModel> chats = [];
  ChatModel chatModel = new ChatModel();

  //1
  chatModel.name = "Satyam";
  chatModel.imgUrl =
      "https://images.unsplash.com/photo-1483726234545-481d6e880fc6?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80";
  chatModel.lastMessage = "Oh hey there. I'm all good btw. How are you?";
  chatModel.lastSeenTime = "5m";
  chatModel.haveunreadmessages = true;
  chatModel.unreadmessages = 1;
  chats.add(chatModel);

  chatModel = new ChatModel();

  //1
  chatModel.name = "Mithil";
  chatModel.imgUrl =
      "https://images.unsplash.com/photo-1459356979461-dae1b8dcb702?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80";
  chatModel.lastMessage = "The workout was really tiring yesterday.";
  chatModel.lastSeenTime = "30 m";
  chatModel.haveunreadmessages = false;
  chatModel.unreadmessages = 1;
  chats.add(chatModel);

  chatModel = new ChatModel();

  //1
  chatModel.name = "Chirag";
  chatModel.imgUrl =
      "https://images.unsplash.com/photo-1498050108023-c5249f4df085?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1052&q=80";
  chatModel.lastMessage = "hey are you studying?";
  chatModel.lastSeenTime = "6 m";
  chatModel.haveunreadmessages = false;
  chatModel.unreadmessages = 1;
  chats.add(chatModel);

  chatModel = new ChatModel();

  //1
  chatModel.name = "Hamza";
  chatModel.imgUrl =
      "https://images.unsplash.com/photo-1550047758-d235a6bb7462?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80";
  chatModel.lastMessage = "how are you, lets catch up";
  chatModel.lastSeenTime = "5 m";
  chatModel.haveunreadmessages = false;
  chatModel.unreadmessages = 1;
  chats.add(chatModel);

  chatModel = new ChatModel();

  //1
  chatModel.name = "Athrav";
  chatModel.imgUrl =
      "https://images.unsplash.com/photo-1596392927852-2a18c336fb78?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80";
  chatModel.lastMessage = "Oh hey there. I'm all good btw. How are you?";
  chatModel.lastSeenTime = "1 hr";
  chatModel.haveunreadmessages = false;
  chatModel.unreadmessages = 1;
  chats.add(chatModel);

  chatModel = new ChatModel();

  return chats;
}

List<MessageModel> getMessages() {
  List<MessageModel> messages = [];
  MessageModel messageModel = new MessageModel();

//1
  messageModel.isByme = true;
  messageModel.message = "Thank you. Bye";
  messages.add(messageModel);

  messageModel = new MessageModel();

//1
  messageModel.isByme = false;
  messageModel.message = "Hey, what's up?";
  messages.add(messageModel);

  messageModel = new MessageModel();

//1
  messageModel.isByme = true;
  messageModel.message = "Oh hey there, I'm all good btw. How are you?";
  messages.add(messageModel);

  messageModel = new MessageModel();

  return messages;
}
