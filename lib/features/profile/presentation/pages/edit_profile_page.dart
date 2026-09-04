import 'dart:io';
import 'package:firebase_auth_starter/features/auth/presentation/components/name_textfield.dart';
import 'package:firebase_auth_starter/features/profile/domain/entities/profile_user.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/features/profile/presentation/components/bio_textfield.dart';
import 'package:firebase_auth_starter/features/profile/presentation/cubits/edit_profile_cubit.dart';
import 'package:firebase_auth_starter/features/profile/presentation/cubits/edit_profile_state.dart';
import 'package:firebase_auth_starter/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:firebase_auth_starter/features/profile/presentation/cubits/profile_state.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final nameTextController = TextEditingController();
  final bioTextController = TextEditingController();

  Uint8List? _webImage;
  File? _imageFile;

  bool _didSeedForm = false;
  String? _seededUid;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authCubit = context.read<AuthCubit>();
    final profileCubit = context.read<ProfileCubit>();
    final uid = authCubit.currentUser?.uid;

    if (uid == null) {
      return;
    }

    final state = profileCubit.state;
    final alreadyLoadedCorrectUser =
        state is ProfileLoaded && state.profileUser.uid == uid;

    if (!alreadyLoadedCorrectUser) {
      await profileCubit.fetchUserProfile(uid);
    }
  }

  void _seedForm(ProfileUser user) {
    if (_seededUid == user.uid && _didSeedForm) return;

    nameTextController.text = user.name;
    bioTextController.text = user.bio;
    _didSeedForm = true;
    _seededUid = user.uid;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      if (kIsWeb) {
        final bytes = await result.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = null;
        });
      } else {
        setState(() {
          _imageFile = File(result.path);
          _webImage = null;
        });
      }
    }
  }

  void _updateProfile(ProfileUser user) {
    if (!_formKey.currentState!.validate()) return;

    final trimmedName = nameTextController.text.trim();
    final trimmedBio = bioTextController.text.trim();

    final hasNameChanged = trimmedName != user.name;
    final hasBioChanged = trimmedBio != user.bio;
    final hasImageChanged = _webImage != null || _imageFile != null;

    if (!hasNameChanged && !hasBioChanged && !hasImageChanged) {
      context.pop();
      return;
    }

    context.read<EditProfileCubit>().updateProfile(
      uid: user.uid,
      newName: hasNameChanged ? trimmedName : null,
      newBio: hasBioChanged ? trimmedBio : null,
      imageWebBytes: hasImageChanged && kIsWeb ? _webImage : null,
      imageMobilePath: hasImageChanged && !kIsWeb ? _imageFile?.path : null,
    );
  }

  void _removeProfilePicture(ProfileUser user) {
    if (_webImage != null || _imageFile != null) {
      setState(() {
        _webImage = null;
        _imageFile = null;
      });
      return;
    }
    context.read<EditProfileCubit>().removeProfilePicture(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EditProfileCubit, EditProfileState>(
          listener: (context, state) {
            if (state is EditProfileSuccess) {
              context.pop();
            } else if (state is EditProfileImageRemoved) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Profile image removed.')));
            } else if (state is EditProfileError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ],
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final editState = context.watch<EditProfileCubit>().state;
          final isSubmitting = editState is EditProfileLoading;
          final currentUid = context.read<AuthCubit>().currentUser?.uid;

          if (currentUid == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit Profile')),
              body: const Center(
                child: Text('You must be logged in to edit your profile.'),
              ),
            );
          }

          if (state is ProfileLoaded) {
            if (state.profileUser.uid != currentUid) {
              return Scaffold(
                appBar: AppBar(title: const Text('Edit Profile')),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            _seedForm(state.profileUser);

            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text('Edit Profile'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: isSubmitting
                        ? null
                        : () => _updateProfile(state.profileUser),
                  ),
                ],
              ),
              body: _buildEditForm(
                user: state.profileUser,
                isSubmitting: isSubmitting,
              ),
            );
          }

          if (state is ProfileError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit Profile')),
              body: Center(child: Text(state.message)),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Edit Profile')),
            body: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildEditForm({
    required ProfileUser user,
    required bool isSubmitting,
  }) {
    Widget profileImageWidget;

    if (_webImage != null && kIsWeb) {
      profileImageWidget = Image.memory(
        _webImage!,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      );
    } else if (_imageFile != null && !kIsWeb) {
      profileImageWidget = Image.file(
        _imageFile!,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      );
    } else if (user.profileImageUrl.isNotEmpty) {
      profileImageWidget = Image.network(
        user.profileImageUrl,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      );
    } else {
      profileImageWidget = Container(
        width: 125,
        height: 125,
        color: Colors.black,
        child: const Icon(Icons.person, size: 75, color: Colors.white),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: ClipOval(child: profileImageWidget)),
              const SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Change photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.backgroundPrimary,
                    ),
                  ),
                ),
              ),
              if (user.profileImageUrl.isNotEmpty ||
                  _webImage != null ||
                  _imageFile != null) ...[
                const SizedBox(height: 5),
                Center(
                  child: TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => _removeProfilePicture(user),
                    child: Text(
                      'Remove photo',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              NameTextField(nameController: nameTextController, label: 'Name'),
              const SizedBox(height: 15),
              BioTextfield(bioController: bioTextController, label: 'Bio'),
              if (isSubmitting) ...[
                const SizedBox(height: 20),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameTextController.dispose();
    bioTextController.dispose();
    super.dispose();
  }
}
