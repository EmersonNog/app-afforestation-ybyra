// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/custom_dropdown_button.dart';
import '../utils/custom_form_field.dart';
import '../utils/image_preview_widget.dart';
import '../utils/point_info.dart';
import '../utils/scaffold_mensage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'form_submit/handle_form_submission_app.dart';
import 'package:flutter_math_fork/flutter_math.dart' as math;

class PointDetailsFormApp extends StatefulWidget {
  final PointInfo pointInfo;

  const PointDetailsFormApp({super.key, required this.pointInfo});

  @override
  State<PointDetailsFormApp> createState() => _PointDetailsFormAppState();
}

class _PointDetailsFormAppState extends State<PointDetailsFormApp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCommonController = TextEditingController();
  final TextEditingController _capController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final List<TextEditingController> _additionalCapControllers =
      List.generate(10, (index) => TextEditingController());
  final TextEditingController _infestationController = TextEditingController();

  String _calculatedCapPi = '';
  bool _showAdditionalCaps = false;
  final Map<String, String> _capDapMap = {};
  final List<String> _capDapValues = [];
  String _dapRoot = '';

  File? _selectedImage;
  Future<String?> _imageURL = Future.value(null);
  int _currentStep = 0;
  bool _isSaving = false;

  final List<String> _hasVitality = [
    'Com Vitalidade',
    'Sem Vitalidade',
  ];
  String? _selectedVitality;

  final List<String> _injury = [
    'N/A',
    'Sem Injurias Mecanicas',
    'Injurias Mecanicas com Boa Recuperacao',
    'Injurias Mecanicas sem Sinais de Recuperacao',
  ];
  String? _selectedInjury;
  final List<String> _hasInfection = [
    'N/A',
    'Ausente',
    'Presente',
  ];
  String? _selectedInfection;

  @override
  void initState() {
    super.initState();
    _capController.addListener(_updateCalculatedCapPi);
    _populateFormFields();
    _capDapValues.addAll(List.filled(10, ''));
    fetchDataFromFirebase();
  }

  @override
  void dispose() {
    _capController.dispose();
    super.dispose();
  }

  String calculateCapPi(String capValue) {
    double cap = double.tryParse(capValue) ?? 0;
    double capPi = cap / pi;
    return capPi.toStringAsFixed(2);
  }

  void _updateCalculatedCapPi() {
    setState(() {
      _calculatedCapPi = calculateCapPi(_capController.text);
      _capDapMap[_capController.text] = _calculatedCapPi;
    });
  }

  Widget _buildAdditionalCapInputs() {
    return Visibility(
      visible: _showAdditionalCaps,
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              border: Border.all(width: 0.6, strokeAlign: 20),
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: List.generate(10, (index) {
                TextEditingController controller =
                    _additionalCapControllers[index];

                controller.addListener(() {
                  _updateCalculatedCapPiForAdditionalCap(index);
                });

                return Visibility(
                  visible: index >= _currentStep,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextFormField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          hint: 'Informe o novo CAP',
                          label: 'CAP ${index + 2}',
                          onChanged: (_) {},
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: RichText(
                            text: TextSpan(
                              text: 'DAP: ',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              children: <TextSpan>[
                                TextSpan(
                                  text: _capDapValues[index],
                                  style: DefaultTextStyle.of(context).style,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchDataFromFirebase() async {
    try {
      QuerySnapshot<Object?> querySnapshot = await FirebaseFirestore.instance
          .collection('additional_info_app')
          .where('point_id', isEqualTo: widget.pointInfo.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        setState(() {
          _dapRoot = doc['dapRoot'] ?? 'N/A';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  void _updateCalculatedCapPiForAdditionalCap(int index) {
    setState(() {
      String capValue = _additionalCapControllers[index].text;
      String dapValue = calculateCapPi(capValue);
      _capDapMap[capValue] = dapValue;
      _capDapValues[index] = dapValue;
    });
  }

  void _populateFormFields() async {
    try {
      QuerySnapshot<Object?> querySnapshot = await FirebaseFirestore.instance
          .collection('additional_info_app')
          .where('point_id', isEqualTo: widget.pointInfo.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;

        setState(() {
          _nameCommonController.text = doc['nameCommon'] ?? '';
          _selectedVitality = doc['selectedVitality'] ?? 'N/A';
          _selectedInjury = doc['selectedInjury'] ?? 'N/A';
          _selectedInfection = doc['selectedInfection'] ?? 'N/A';
          _infestationController.text = doc['infestation'] ?? 'N/A';
          _capController.text = doc['cap'] ?? '';
          _alturaController.text = doc['height'] ?? '';
          for (int i = 0; i < _additionalCapControllers.length; i++) {
            if (doc['additionalCapValues'] != null &&
                doc['additionalCapValues'].length > i) {
              _additionalCapControllers[i].text =
                  doc['additionalCapValues'][i] ?? '';
            }
          }
          _imageURL = Future.value(doc['imageURL']);
          _updateCalculatedCapPi();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  void _handleStepTap(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  Future<void> _uploadImage() async {
    if (_selectedImage != null) {
      try {
        setState(() {
          _isSaving = true;
        });

        String imageName = widget.pointInfo.name;
        String? uploadedURL =
            await uploadImageToStorage(_selectedImage!, imageName);

        if (uploadedURL != null) {
          setState(() {
            _imageURL = Future.value(uploadedURL);
          });
        } else {
          print('Failed to upload the image.');
        }
      } catch (error) {
        print('Error during image upload: $error');
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<String?> uploadImageToStorage(File imageFile, String imageName) async {
    try {
      Reference storageReference = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/app/$imageName.jpg');

      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'replace': 'true'},
      );

      UploadTask uploadTask = storageReference.putFile(imageFile, metadata);
      await uploadTask.whenComplete(() {});

      String downloadURL = await storageReference.getDownloadURL();

      print('Image uploaded to Firebase Storage. Download URL: $downloadURL');

      return downloadURL;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Stepper(
        elevation: 2,
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepCancel: () {
          setState(() {
            _currentStep = (_currentStep - 1).clamp(0, 1);
          });
        },
        onStepTapped: (step) {
          _handleStepTap(step);
        },
        steps: [
          Step(
            title: const Text('Dados'),
            subtitle: const Text('Quantitativos'),
            isActive: _currentStep == 0,
            state: _currentStep == 0 ? StepState.editing : StepState.complete,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFormField(
                  controller: _capController,
                  keyboardType: TextInputType.number,
                  hint: 'Informe o item',
                  label: 'CAP',
                  onChanged: (value) {
                    _updateCalculatedCapPi();
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: RichText(
                          text: TextSpan(
                              text: 'DAP: ',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              children: <TextSpan>[
                            TextSpan(
                              text: _calculatedCapPi,
                              style: DefaultTextStyle.of(context).style,
                            )
                          ]))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: const ButtonStyle(
                          elevation: MaterialStatePropertyAll(4)),
                      onPressed: () {
                        setState(() {
                          _showAdditionalCaps = !_showAdditionalCaps;
                          String calculatedCapPi =
                              calculateCapPi(_capController.text);
                          _capDapMap[_capController.text] = calculatedCapPi;
                        });
                      },
                      child: Text(_showAdditionalCaps
                          ? "Esconder CAP's"
                          : "Mostrar CAP's"),
                    ),
                    Material(
                      elevation: 10,
                      shape: Border.all(width: 1),
                      color: const Color.fromARGB(255, 242, 242, 242),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            math.Math.tex(
                              'DAP_{eq} = \\sqrt{\\Sigma_{i=1}^{n} DAP^{2}_i}',
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            math.Math.tex(
                              'DAP_{eq} = \\boldsymbol{\\Large \\underline{$_dapRoot}}',
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                _buildAdditionalCapInputs(),
                CustomTextFormField(
                  controller: _alturaController,
                  keyboardType: TextInputType.number,
                  hint: 'Informe o item',
                  label: 'Altura',
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Dados'),
            subtitle: const Text('Qualitativos'),
            isActive: _currentStep == 1,
            state: _currentStep == 1 ? StepState.editing : StepState.indexed,
            content: Column(
              children: [
                CustomTextFormField(
                    controller: _nameCommonController,
                    hint: 'Informe o item',
                    label: 'Nome Comum'),
                CustomDropdownButton<String>(
                  labelText: 'Possuí Vitalidade?',
                  items: _hasVitality,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedVitality = value;
                      if (_selectedVitality == 'Sem Vitalidade') {
                        _selectedInjury = 'N/A';
                        _selectedInfection = 'N/A';
                      }
                    });
                  },
                  value: _selectedVitality,
                ),
                if (_selectedVitality == 'Com Vitalidade') ...[
                  CustomDropdownButton<String>(
                    labelText: 'Injúrias Mecânicas',
                    items: _injury,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedInjury = value;
                      });
                    },
                    value: _selectedInjury,
                  ),
                  CustomDropdownButton<String>(
                    labelText: 'Infestação',
                    items: _hasInfection,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedInfection = value;
                        if (_selectedInfection == 'Ausente' ) {
                          _infestationController.text = 'N/A';
                        }
                      });
                    },
                    value: _selectedInfection,
                  ),
                  if (_selectedInfection == 'Presente') ...[
                    CustomTextFormField(
                        controller: _infestationController,
                        hint: 'Informe o item',
                        label: 'Infestação de que?'),
                  ],
                ],
              ],
            ),
          ),
          Step(
            title: const Text('Dados'),
            subtitle: const Text('Fotográficos'),
            isActive: _currentStep == 2,
            state: _currentStep == 2 ? StepState.editing : StepState.indexed,
            content: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 21, 86, 198),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await _galleryPhoto();
                        },
                        icon: const Icon(Icons.photo_library_outlined,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 21, 86, 198),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await _takePhoto();
                        },
                        icon: const Icon(Icons.camera_alt_outlined,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ImagePreviewWidget(
                    imageUrlFuture: _imageURL, selectedImage: _selectedImage),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ],
        controlsBuilder: (BuildContext context, ControlsDetails controls) {
          final isLastStep = _currentStep == 2;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                ElevatedButton(
                  onPressed: controls.onStepCancel,
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Color.fromARGB(255, 21, 86, 198),
                    ),
                  ),
                  child: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () async {
                  if (_isSaving) {
                    return;
                  }
                  if (isLastStep) {
                    try {
                      setState(() {
                        _isSaving = true;
                      });
                      String calculatedCapPi =
                          calculateCapPi(_capController.text);
                      await _uploadImage();
                      List<String> additionalCapValues =
                          _additionalCapControllers
                              .map((controller) => controller.text)
                              .toList();
                      await handleFormSubmissionApp(
                        widget.pointInfo,
                        _nameCommonController.text,
                        _capController.text,
                        calculatedCapPi,
                        _alturaController.text,
                        _selectedVitality!,
                        _selectedInjury ?? 'N/A',
                        _selectedInfection ?? 'N/A',
                        _infestationController.text,
                        additionalCapValues: additionalCapValues,
                        dapValues: _capDapValues,
                        imageURL: await _imageURL,
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      print('Error saving data: $e');
                      CustomSnackBar.show(
                        context: context,
                        message: 'Preencha todos os campos',
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      );
                    } finally {
                      setState(() {
                        _isSaving = false;
                      });
                    }
                  } else {
                    setState(() {
                      _currentStep = (_currentStep + 1).clamp(0, 2);
                      print('Advancing to the next step: $_currentStep');
                    });
                  }
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Color.fromARGB(255, 21, 86, 198),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        isLastStep
                            ? Icons.save
                            : Icons.arrow_forward_ios_rounded,
                        color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _takePhoto() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _galleryPhoto() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }
}
