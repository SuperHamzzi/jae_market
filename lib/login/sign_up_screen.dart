import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailTextController = TextEditingController();
  TextEditingController pwdTextController = TextEditingController();

  Future<bool> signUp(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: emailAddress, password: password);
      await FirebaseFirestore.instance.collection("users").add({
        "uid": credential.user?.uid ?? "",
        "email": credential.user?.email ?? "",
      });
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        print("패드워드가 약합니다.");
      } else if (e.code == "email-alreay-in-use") {
        print("이미 이메일정보가 존재합니다.");
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("회원가입"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "재혁 마켓 \n가입을 환영합니다",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 42,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailTextController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "이메일",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "이메일 주소를 입력하세요.";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      TextFormField(
                        controller: pwdTextController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "비밀번호",
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "비밀번호를 입력해주세요";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                MaterialButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final result = await signUp(
                        emailTextController.text.trim(),
                        pwdTextController.text.trim(),
                      );
                      if (result) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("회원가입 성공"),
                            ),
                          );
                          context.go("/login");
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("회원가입 실패"),
                              ),
                            );
                          }
                        }
                      }
                    }
                  },
                  height: 48,
                  minWidth: double.infinity,
                  color: Colors.green,
                  child: Text(
                    "회원가입",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
