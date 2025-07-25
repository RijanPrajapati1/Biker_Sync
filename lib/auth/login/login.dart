import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/auth/register/register.dart';
import 'package:social_media_app/components/password_text_field.dart';
import 'package:social_media_app/components/text_form_builder.dart';
import 'package:social_media_app/utils/validation.dart';
import 'package:social_media_app/view_models/auth/login_view_model.dart';
import 'package:social_media_app/widgets/indicators.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    LoginViewModel viewModel = Provider.of<LoginViewModel>(context);

    return LoadingOverlay(
      progressIndicator: circularProgress(context),
      isLoading: viewModel.loading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 251, 251),
        key: viewModel.scaffoldKey,
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 8),
            Container(
              height: 170.0,
              width: MediaQuery.of(context).size.width,
              child: Image.asset('assets/images/login.png'),
            ),
            SizedBox(height: 20.0),
            Center(
              child: Text(
                'Welcome back!',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w900),
              ),
            ),
            Center(
              child: Text(
                'Log into your account and get started!',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            SizedBox(height: 30.0),
            buildForm(context, viewModel),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t have an account?'),
                SizedBox(width: 5.0),
                GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(CupertinoPageRoute(builder: (_) => Register()));
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildForm(BuildContext context, LoginViewModel viewModel) {
    return Form(
      key: viewModel.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextFormBuilder(
              enabled: !viewModel.loading,
              prefix: Ionicons.mail_outline,
              hintText: "Email",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateEmail,
              onSaved: (String val) => viewModel.setEmail(val),
              focusNode: viewModel.emailFN,
              nextFocusNode: viewModel.passFN,
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: PasswordFormBuilder(
              enabled: !viewModel.loading,
              prefix: Ionicons.lock_closed_outline,
              suffix: Ionicons.eye_outline,
              hintText: "Password",
              textInputAction: TextInputAction.done,
              validateFunction: Validations.validatePassword,
              submitAction: () => viewModel.login(context),
              obscureText: true,
              onSaved: (String val) => viewModel.setPassword(val),
              focusNode: viewModel.passFN,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: InkWell(
                onTap: () => viewModel.forgotPassword(context),
                child: Container(
                  width: 130,
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 25.0),
          Container(
            height: 45.0,
            width: 180.0,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: Text(
                'Log in'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => viewModel.login(context),
            ),
          ),
        ],
      ),
    );
  }
}
