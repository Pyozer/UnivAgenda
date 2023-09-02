import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/screens/help/help.dart';
import 'package:univagenda/screens/home/home.dart';
import 'package:univagenda/screens/login/login_qrcode.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/api/api.dart';
import 'package:univagenda/utils/functions.dart';
import 'package:univagenda/utils/preferences/settings.provider.dart';
import 'package:univagenda/utils/scan.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:univagenda/widgets/ui/logo.dart';

enum BodyType { MAIN, QRCODE, MANUAL }

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _urlIcsController = TextEditingController();
  bool _isLoading = false;
  BodyType bodyType = BodyType.MAIN;

  @override
  void initState() {
    super.initState();
    setOnlyPortrait();
    AnalyticsProvider.setScreen(widget);
  }

  @override
  void dispose() {
    _urlIcsController.dispose();
    setAllOrientation();
    super.dispose();
  }

  void setOnlyPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void setAllOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _setLoading(bool loading) {
    if (mounted) setState(() => _isLoading = loading);
  }

  void _onSubmit() async {
    FocusScope.of(context).unfocus();

    String urlIcs = _urlIcsController.text.trim();

    // Check fields values
    if (urlIcs.isEmpty) {
      _showMessage(i18n.text(StrKey.REQUIRE_FIELD));
      return;
    }
    _onDone(urlIcs);
  }

  Future<void> _onDone(String urlIcs) async {
    final isValidUrl = Uri.tryParse(urlIcs)?.hasAbsolutePath ?? false;
    if (!isValidUrl) {
      // TODO: Add translation
      _showMessage(
        "Le QRCode doit contenir le lien d'exportation de votre agenda.\n\nVeuillez lire la section Aide pour plus d'informations.",
      );
      return;
    }

    _setLoading(true);
    final prefs = context.read<SettingsProvider>();
    prefs.setUserLogged(false);

    if (mounted) {
      urlIcs = urlIcs.replaceFirst('webcal', 'http');
      prefs.setUrlIcs([urlIcs]);

      try {
        final courses = await Api()
            .getCoursesCustomIcal(urlIcs)
            .timeout(const Duration(seconds: 25));

        if (!mounted) return;
        prefs.setCachedCourses(courses);

        // Redirect user if no error
        prefs.setUserLogged(true);
        return navigatorPushReplace(context, const HomeScreen());
      } on TimeoutException catch (_) {
        // TODO: Add translation
        _showMessage(
          'Le lien saisie ou présent dans le QRCode ne semble pas joignable, veuillez réessayez plus tard.',
        );
      } catch (e) {
        _showMessage(e.toString());
      }
      _setLoading(false);
    }
  }

  void _onDataPrivacy() {
    DialogPredefined.showSimpleMessage(
      context,
      i18n.text(StrKey.DATA_PRIVACY),
      i18n.text(StrKey.DATA_PRIVACY_TEXT),
    );
  }

  Future<void> _scanQRCode() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (Platform.isAndroid) {
        await _showMessage(
          'Permission refusé, voulez-vous ouvrir les paramètres pour changer ça ?',
        );
        openAppSettings();
      } else if (Platform.isIOS) {
        await _showMessage('Permission refusé, allez dans les paramètres');
      }
    }

    if (await Permission.camera.isRestricted) {
      return _showMessage('Permission restricted');
    }
    if (status.isGranted) {
      final result = await navigatorPush<String>(context, const LoginQrCode());
      if (result?.isNotEmpty ?? false) {
        _onDone(result!);
      }
    }
  }

  void _scanPicture() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final result = await analyzeImage(pickedFile.path);
        _onDone(result ?? '');
      }
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  Future<void> _showMessage(String msg) async {
    await DialogPredefined.showSimpleMessage(
      context,
      i18n.text(StrKey.ERROR),
      msg,
    );
  }

  Widget _buildBackBtn() {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: TextButton.icon(
          onPressed: () => setState(() => bodyType = BodyType.MAIN),
          icon: const Icon(Icons.arrow_back),
          label: Text(i18n.text(StrKey.BACK)),
          style: TextButton.styleFrom(),
        ),
      ),
    );
  }

  Widget _buildIcsField() {
    return TextField(
      controller: _urlIcsController,
      onEditingComplete: _onSubmit,
      textInputAction: TextInputAction.done,
      autofocus: false,
      maxLines: 5,
      minLines: 1,
      decoration: InputDecoration(
        labelStyle: Theme.of(context).textTheme.titleMedium,
        labelText: i18n.text(StrKey.URL_ICS),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        prefixIcon: Icon(
          Icons.event_outlined,
          color: Theme.of(context).colorScheme.secondary,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            navigatorPush(context, HelpScreen());
          },
          icon: const Icon(Icons.help_outline),
        ),
        contentPadding: const EdgeInsets.fromLTRB(0.0, 18.0, 18.0, 18.0),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildMainLogin() {
    return Column(
      key: const Key('main'),
      children: [
        FloatingActionButton.extended(
          icon: const Icon(Icons.qr_code_rounded),
          // TODO: Add translate
          label: Text('Scanner QRCode ENT'),
          heroTag: null,
          onPressed: () => setState(() => bodyType = BodyType.QRCODE),
        ),
        const SizedBox(height: 42.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40.0,
              height: 1.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            const SizedBox(width: 24.0),
            Text(i18n.text(StrKey.OR)),
            const SizedBox(width: 24.0),
            Container(
              width: 40.0,
              height: 1.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 42.0),
        FloatingActionButton.extended(
          icon: const Icon(Icons.link, size: 24.0),
          // TODO: Add translate
          label: Text("Saisir l'url manuellement"),
          heroTag: null,
          onPressed: () => setState(() => bodyType = BodyType.MANUAL),
        ),
      ],
    );
  }

  Widget _buildPictureMode() {
    return Column(
      key: const Key('qrcode'),
      children: [
        Text(
          // TODO: Add translation
          'Utiliser le QRCode',
          style: const TextStyle(fontSize: 20.0),
        ),
        const SizedBox(height: 32.0),
        FloatingActionButton.extended(
          icon: Icon(Icons.camera_alt_outlined, size: 24.0),
          // TODO: Add translation
          label: Text("Depuis l'appareil photo"),
          heroTag: null,
          onPressed: _scanQRCode,
        ),
        const SizedBox(height: 32.0),
        FloatingActionButton.extended(
          icon: const Icon(Icons.photo_size_select_actual_outlined, size: 24.0),
          // TODO: Add translation
          label: Text("Depuis un screenshot"),
          heroTag: null,
          onPressed: _scanPicture,
        ),
        _buildBackBtn(),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildManualMode() {
    return Column(
      key: const Key('manual'),
      children: [
        Card(
          elevation: 4.0,
          child: _buildIcsField(),
        ),
        const SizedBox(height: 24.0),
        FloatingActionButton.extended(
          icon: const Icon(Icons.send),
          label: Text(i18n.text(StrKey.NEXT)),
          heroTag: null,
          onPressed: _onSubmit,
        ),
        const SizedBox(height: 24.0),
        _buildBackBtn(),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary),
      );
    }
    if (bodyType == BodyType.MAIN) return _buildMainLogin();
    if (bodyType == BodyType.QRCODE) return _buildPictureMode();
    return _buildManualMode();
  }

  @override
  Widget build(BuildContext context) {
    // Use 50 to start UI changes before keyboard fully disappears
    final isKeyboardHidden = MediaQuery.of(context).viewInsets.bottom < 50;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Logo(size: isKeyboardHidden ? 100.0 : 60.0),
                  const SizedBox(height: 12.0),
                  Text(
                    i18n.text(StrKey.APP_NAME),
                    style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: isKeyboardHidden ? 5 : 6,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(child: child, scale: animation);
                },
                child: _buildContent(),
              ),
            ),
            if (isKeyboardHidden) const SizedBox(height: 10.0),
            if (isKeyboardHidden)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: _onDataPrivacy,
                    child: Text(i18n.text(StrKey.DATA_PRIVACY)),
                  ),
                  TextButton(
                    onPressed: () => navigatorPush(context, HelpScreen()),
                    child: Text(i18n.text(StrKey.HELP_FEEDBACK)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
