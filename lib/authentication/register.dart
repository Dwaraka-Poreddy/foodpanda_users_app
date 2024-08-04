import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../global/global.dart';
import '../mainScreens/home_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  String userImageUrl = "";

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
        context: context,
        builder: (c) {
          return const ErrorDialog(
            message: "Please select an image.",
          );
        },
      );
    } else {
      if (passwordController.text == confirmPasswordController.text) {
        if (passwordController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            nameController.text.isNotEmpty) {
          showDialog(
              context: context,
              builder: (c) {
                return const LoadingDialog(message: "Registering your account");
              });

          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          fStorage.Reference reference = fStorage.FirebaseStorage.instance
              .ref()
              .child("users")
              .child(fileName);
          fStorage.UploadTask uploadTask =
              reference.putFile(File(imageXFile!.path));

          fStorage.TaskSnapshot taskSnapshot = await uploadTask;
          String url = await taskSnapshot.ref.getDownloadURL();
          userImageUrl = url;

          authenticateUserAndSignUp();
        } else {
          showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message:
                    "Please enter all the details required for registration.",
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Passwords do not match.",
            );
          },
        );
      }
    }
  }

  void authenticateUserAndSignUp() async {
    User? currentUser;

    await firebaseAuth
        .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim())
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });
    if (currentUser != null) {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        Route newRoute =
            MaterialPageRoute(builder: (context) => const HomeScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future saveDataToFirestore(User currentUser) async {
    FirebaseFirestore.instance.collection("users").doc(currentUser.uid).set({
      "uid": currentUser.uid,
      "email": currentUser.email,
      "name": nameController.text.trim(),
      "photoUrl": userImageUrl,
      "status": "approved",
    });

    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("photoUrl", userImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              _getImage();
            },
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.20,
              backgroundImage:
                  imageXFile == null ? null : FileImage(File(imageXFile!.path)),
              backgroundColor: Colors.white,
              child: imageXFile == null
                  ? Icon(
                      Icons.add_photo_alternate,
                      size: MediaQuery.of(context).size.width * 0.20,
                      color: Colors.grey,
                    )
                  : null,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  hintText: "Name",
                  data: Icons.person,
                  controller: nameController,
                  enabled: true,
                  obscureText: false,
                ),
                CustomTextField(
                  hintText: "Email",
                  data: Icons.email,
                  controller: emailController,
                  enabled: true,
                  obscureText: false,
                ),
                CustomTextField(
                  hintText: "Password",
                  data: Icons.lock,
                  controller: passwordController,
                  enabled: true,
                  obscureText: true,
                ),
                CustomTextField(
                  hintText: "Confirm Password",
                  data: Icons.lock,
                  controller: confirmPasswordController,
                  enabled: true,
                  obscureText: true,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                formValidation();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields.'),
                  ),
                );
              }
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
