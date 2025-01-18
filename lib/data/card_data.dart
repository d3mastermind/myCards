import 'package:mycards/providers/card_data_provider.dart';

List<Map<String, dynamic>> jsonCardData = [
  {
    "cardId": "card1",
    "templateId": "template1",
    "frontCover": "https://example.com/birthday-cover.jpg",
    "senderId": "user123",
    "receiverId": "user456",
    "creditsAttached": 10,
    "isClaimed": true,
    "to": "Alice",
    "from": "Bob",
    "greeting": "Happy Birthday, Alice! Wishing you a fantastic year ahead!",
    "customImage": "https://example.com/custom-birthday-image.jpg",
    "voiceRecording": "https://example.com/birthday-voice-note.mp3",
  },
  {
    "cardId": "card2",
    "templateId": "template2",
    "frontCover": "https://example.com/anniversary-cover.jpg",
    "senderId": "user789",
    "receiverId": null, // Card not sent yet
    "creditsAttached": 0,
    "isClaimed": false,
    "to": "Mom & Dad",
    "from": "Charlie",
    "greeting": "Happy Anniversary to the best parents ever!",
    "customImage": null, // No custom image added
    "voiceRecording": null, // No voice note added
  },
  {
    "cardId": "card3",
    "templateId": "template3",
    "frontCover": "https://example.com/thankyou-cover.jpg",
    "senderId": "user321",
    "receiverId": "user654",
    "creditsAttached": 5,
    "isClaimed": false,
    "to": "Sam",
    "from": "Alex",
    "greeting": "Thanks a ton for your support, Sam!",
    "customImage": "https://example.com/thankyou-image.jpg",
    "voiceRecording": null, // No voice note added
  },
  {
    "cardId": "card4",
    "templateId": "template4",
    "frontCover": "https://example.com/congratulations-cover.jpg",
    "senderId": "user111",
    "receiverId": "user222",
    "creditsAttached": 15,
    "isClaimed": true,
    "to": "Jane",
    "from": "Mark",
    "greeting": "Congratulations on your achievement, Jane! So proud of you!",
    "customImage": null,
    "voiceRecording": "https://example.com/congratulations-voice.mp3",
  },
];

final data = CardData(templateId: "ii",frontCover: "00",senderId: "Mastermind",creditsAttached: 30,);
