import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ImagePreviewWidget extends StatelessWidget {
  final Future<String?> imageUrlFuture;
  final File? selectedImage;
  final String?
      existingImageUrl;

  const ImagePreviewWidget({
    Key? key,
    required this.imageUrlFuture,
    this.selectedImage,
    this.existingImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: imageUrlFuture,
      builder: (context, snapshot) {
        if (selectedImage != null) { 
          if (selectedImage!.path != existingImageUrl) { 
            return _buildImagePreview(selectedImage!);
          } else { 
            return _buildExistingImagePreview(existingImageUrl);
          }
        } else { 
          return _buildOtherCases(snapshot);
        }
      },
    );
  }

  Widget _buildImagePreview(File image) {
    return SizedBox(
      height: 300.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Image.file(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildExistingImagePreview(String? imageUrl) {
    return SizedBox(
      height: 300.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Image.network(imageUrl ?? ''),
      ),
    );
  }

  Widget _buildOtherCases(AsyncSnapshot<String?> snapshot) {
    if (snapshot.connectionState == ConnectionState.none ||
        snapshot.connectionState == ConnectionState.waiting) {
      return const Text('Carregando imagem...');
    } else if (snapshot.hasError ||
        snapshot.data == null ||
        snapshot.data!.isEmpty) {
      return SizedBox(
        height: 300.0,
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.red)),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.triangleExclamation,
                  color: Colors.yellow,
                  size: 45,
                ),
                Text(
                  'Nenhuma imagem encontrada.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    } else if (snapshot.connectionState == ConnectionState.done) {
      return _buildExistingImagePreview(snapshot.data);
    }

    return const SizedBox.shrink();
  }
}
