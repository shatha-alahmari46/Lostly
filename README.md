# Lostly

Lostly is a mobile lost-and-found application designed to help users report, discover, and manage lost and found items in an organized and simple way.

## 📌 Project Idea

Lostly provides a centralized platform where users can:

- Report lost items.
- Report found items.
- Browse available lost and found posts.
- View detailed information about an item.
- Save items to favorites.
- Manage their own posts.
- Edit and delete their posts.
- Switch between Arabic and English.
- Upload images for posts.

## 🎯 Problem

When personal belongings are lost, information about them is often shared through scattered messages, social media posts, or informal communication.

This makes it difficult to:

- Find relevant lost or found items.
- Keep track of reported items.
- Organize item information.
- Update or remove outdated reports.

Lostly aims to make this process more organized through one dedicated application.

## 👥 Target Users

Lostly is mainly designed for:

- University students.
- University staff.
- People who lose or find personal belongings.
- Communities that need a simple lost-and-found platform.

## ✨ Features

### Authentication
- Firebase Authentication.
- User-based access to application data.

### Lost & Found Posts
- Create a lost or found item post.
- Add item name, category, location, date, description, brand, color, and image.
- Edit existing posts.
- Delete personal posts.
- View item details.

### Favorites
- Save items to favorites.
- View saved items.
- Favorite status is synchronized across the relevant screens.
- Saved items are stored separately for each authenticated user.

### My Posts
- View posts created by the current user.
- Edit personal posts.
- Delete personal posts.
- See the current favorite status of posts.

### Multilingual Support
- English language.
- Arabic language.
- RTL support for Arabic.

### Image Upload
- Users can attach images to posts.
- Images are uploaded using Cloudinary.

### Firebase
- Firebase Authentication.
- Cloud Firestore for storing users and posts.

## 🛠 Technologies

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Cloudinary
- Flutter BLoC / Cubit
- SharedPreferences
- HTTP
- Image Picker

## 🏗 Architecture

The project follows a simplified and organized architecture:

```text
lib/
├── cubits/
├── models/
├── services/
├── utils/
├── lostly/
│   ├── pages/
│   └── ...
└── main.dart
