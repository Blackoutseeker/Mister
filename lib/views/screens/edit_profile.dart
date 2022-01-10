import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:mister/models/database/autonomous.dart';

import 'package:mister/controllers/stores/autonomous.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();

  final AutonomousStore _autonomousStore = GetIt.I.get<AutonomousStore>();

  Autonomous _autonomous = Autonomous();
  bool _isLoading = false;
  File? _avatarImage;
  File? _bannerImage;

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _showSnackBarToUser(String content) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  TextField _renderCustomTextField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 18,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
      ),
    );
  }

  void fillTextFieldsWithAutonomousData(Autonomous autonomous) {
    _nameController.text = autonomous.name ?? '';
    _phoneController.text = autonomous.phone ?? '';
    _addressController.text = autonomous.location?.address ?? '';
    _professionController.text = autonomous.profession ?? '';
    _facebookController.text = autonomous.socialNetworks?.facebook ?? '';
    _instagramController.text = autonomous.socialNetworks?.instagram ?? '';
  }

  Future<void> _pickBannerImage() async {
    final XFile? bannerImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1200,
    );

    if (bannerImage?.path != null) {
      File? croppedBannerImage = await ImageCropper.cropImage(
        sourcePath: bannerImage!.path,
        aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
        compressQuality: 70,
        androidUiSettings: const AndroidUiSettings(
          toolbarTitle: 'Cortar imagem',
          hideBottomControls: true,
          toolbarColor: Color(0xFF4267B2),
          toolbarWidgetColor: Color(0xFFFFFFFF),
        ),
      );

      setState(() {
        _bannerImage = croppedBannerImage;
      });
    }
  }

  Future<void> _pickAvatarImage() async {
    final XFile? avatarImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 700,
      maxHeight: 700,
    );

    if (avatarImage?.path != null) {
      File? croppedAvatarImage = await ImageCropper.cropImage(
        sourcePath: avatarImage!.path,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        compressQuality: 70,
        cropStyle: CropStyle.circle,
        androidUiSettings: const AndroidUiSettings(
          toolbarTitle: 'Cortar imagem',
          hideBottomControls: true,
          toolbarColor: Color(0xFF4267B2),
          toolbarWidgetColor: Color(0xFFFFFFFF),
        ),
      );
      setState(() {
        _avatarImage = croppedAvatarImage;
      });
    }
  }

  Future<String?> _uploadImageToStorage(File image, String storagePath) async {
    final TaskSnapshot snapshot = await _firebaseStorage
        .ref()
        .child(storagePath)
        .putFile(image)
        .whenComplete(() {});

    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _updateAutonomousInDatabase() async {
    _dismissKeyboard();

    final String? id = _autonomous.id;
    final String? email = _autonomous.email;
    final String name = _nameController.text;
    final String phone = _phoneController.text;
    final String address = _addressController.text;
    final String profession = _professionController.text;
    final String facebook = _facebookController.text;
    final String instagram = _instagramController.text;

    if (id == null) return;
    if (name.length < 6 ||
        phone.length < 8 ||
        address.isEmpty ||
        profession.length < 3) {
      await _showSnackBarToUser('Por favor, preencha os campos necessários');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String avatarImageStoragePath = 'autonomous/avatars/$id.jpg';
    final String bannerImageStoragePath = 'autonomous/banners/$id.jpg';

    final String? avatarUrl = _avatarImage?.path != null
        ? await _uploadImageToStorage(_avatarImage!, avatarImageStoragePath)
        : _autonomous.avatarUrl;

    final String? bannerUrl = _bannerImage?.path != null
        ? await _uploadImageToStorage(_bannerImage!, bannerImageStoragePath)
        : _autonomous.bannerUrl;

    final Autonomous autonomous = Autonomous(
      id: id,
      avatarUrl: avatarUrl,
      bannerUrl: bannerUrl,
      email: email,
      name: name,
      profession: profession,
      phone: phone,
      location: AutonomousLocation(
        address: address,
      ),
      socialNetworks: AutonomousSocialNetworks(
        facebook: facebook.isNotEmpty ? facebook : null,
        instagram: instagram.isNotEmpty ? instagram : null,
      ),
    );

    await _firebaseDatabase
        .reference()
        .child('professions')
        .child(profession)
        .set({'profession': profession});

    await _firebaseDatabase
        .reference()
        .child('users')
        .child('accounts')
        .child(id)
        .update({
      'profession': profession,
    });

    if (_autonomous.profession != profession) {
      await _firebaseDatabase
          .reference()
          .child('users')
          .child('autonomous')
          .child(_autonomous.profession ?? '')
          .child(id)
          .remove();
    }

    final bool haveSocialNetworks = facebook.isNotEmpty || instagram.isNotEmpty;

    final Map<String, dynamic> socialNetworks = {
      'facebook': facebook.isNotEmpty ? facebook : null,
      'instagram': instagram.isNotEmpty ? instagram : null,
    };

    await _firebaseDatabase
        .reference()
        .child('users')
        .child('autonomous')
        .child(profession)
        .child(id)
        .set({
      ...autonomous.convertToDatabaseWithRequiredData(),
      'socialNetworks': haveSocialNetworks ? socialNetworks : null,
      'avatarUrl': avatarUrl,
      'bannerUrl': bannerUrl,
    });

    await _firebaseDatabase.reference().child('quickSearch').child(id).update({
      'name': name,
      'profession': profession,
      'avatarUrl': avatarUrl,
    }).then((_) async {
      await _autonomousStore.setAutonomous(autonomous);

      setState(() {
        _isLoading = false;
        _avatarImage = _avatarImage?.path != null ? null : _avatarImage;
        _bannerImage = _bannerImage?.path != null ? null : _bannerImage;
        _autonomous = autonomous;
      });

      await _showSnackBarToUser('Alterações salvas com sucesso!');
    });
  }

  void _getAutonomousData() {
    final Autonomous autonomous = _autonomousStore.autonomous;
    fillTextFieldsWithAutonomousData(autonomous);
    setState(() {
      _autonomous = autonomous;
    });
  }

  @override
  void initState() {
    super.initState();
    _getAutonomousData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _professionController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: _dismissKeyboard,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: const Color(0xFF151054),
                expandedHeight: 140,
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(84),
                  child: Text(''),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Observer(
                    builder: (_) => Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        if (_autonomousStore.autonomous.bannerUrl != null ||
                            _bannerImage?.path != null)
                          Center(
                            child: _bannerImage?.path != null
                                ? Image.file(
                                    _bannerImage!,
                                    height: double.infinity,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    _autonomousStore.autonomous.bannerUrl!,
                                    height: double.infinity,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        else
                          Container(),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: FloatingActionButton(
                              heroTag: 'Edit Banner FAB',
                              onPressed: _pickBannerImage,
                              backgroundColor: const Color(0xFF4267B2),
                              child: const Icon(
                                Icons.add_a_photo,
                                color: Color(0xFFFFFFFF),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 56),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              Hero(
                                tag: (_autonomous.id ?? 'Default') + 'profile',
                                child: CircleAvatar(
                                  maxRadius: 50,
                                  backgroundColor: const Color(0xFFEEEEEE),
                                  foregroundImage:
                                      _autonomousStore.autonomous.avatarUrl !=
                                                  null ||
                                              _avatarImage?.path != null
                                          ? _avatarImage?.path != null
                                              ? FileImage(_avatarImage!)
                                                  as ImageProvider
                                              : NetworkImage(_autonomousStore
                                                  .autonomous.avatarUrl!)
                                          : null,
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF9E9E9E),
                                    size: 50,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -5,
                                right: -5,
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: FloatingActionButton(
                                    heroTag: 'Edit Avatar FAB',
                                    onPressed: _pickAvatarImage,
                                    backgroundColor: const Color(0xFF4267B2),
                                    child: const Icon(
                                      Icons.add_a_photo,
                                      color: Color(0xFFFFFFFF),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 40,
                    ),
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Edite suas informações',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _renderCustomTextField(
                          controller: _nameController,
                          hintText: 'Nome completo',
                          prefixIcon: Icons.person,
                        ),
                        const SizedBox(height: 10),
                        _renderCustomTextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          hintText: 'Número de telefone',
                          prefixIcon: Icons.phone,
                        ),
                        const SizedBox(height: 10),
                        _renderCustomTextField(
                          controller: _professionController,
                          hintText: 'Profissão',
                          prefixIcon: Icons.work,
                        ),
                        const SizedBox(height: 10),
                        _renderCustomTextField(
                          controller: _addressController,
                          hintText: 'Endereço',
                          prefixIcon: Icons.location_on,
                        ),
                        const SizedBox(height: 10),
                        _renderCustomTextField(
                          controller: _facebookController,
                          hintText: 'Facebook',
                          prefixIcon: Icons.facebook,
                        ),
                        const SizedBox(height: 10),
                        _renderCustomTextField(
                          controller: _instagramController,
                          hintText: 'Instagram',
                          prefixIcon: FontAwesomeIcons.instagram,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed:
                              !_isLoading ? _updateAutonomousInDatabase : null,
                          child: !_isLoading
                              ? const Text(
                                  'Salvar alterações',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                )
                              : const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 2,
                                  ),
                                ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              const Color(0xFF151054),
                            ),
                            minimumSize: MaterialStateProperty.all(
                              const Size(double.infinity, 40),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
