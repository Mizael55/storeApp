import 'dart:io';
import 'package:flutter/material.dart';
import 'package:store_app/constants/categories.dart';
import 'package:store_app/theme/app_colors.dart';
import 'package:store_app/utils/custom_category_dropdown.dart';
import 'package:store_app/utils/custom_text_input.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  String _selectedCategory = productCategories.first.value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nuevo Producto',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save_rounded,
              size: 28,
              color: AppColors.secondary,
            ),
            onPressed: () {}, // La lógica se manejará desde el widget padre
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección de imagen
              GestureDetector(
                onTap: () {
                  
                }, // Lógica manejada externamente
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.inputBorder.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child:
                      _selectedImage == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Agregar imagen',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 32),

              // Campo de nombre
              Text(
                'Información del Producto',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextInput(
                controller: _nameController,
                label: 'Nombre del producto',
                prefixIcon: Icons.shopping_bag_outlined,
              ),
              const SizedBox(height: 16),

              // Campo de precio
              CustomTextInput(
                controller: _priceController,
                label: 'Precio',
                inputType: CustomInputType.number,
                prefixIcon: Icons.attach_money_outlined,
              ),
              const SizedBox(height: 16),

              // Selector de categoría y agrega que diga selecciona una categoría
              CustomCategoryDropdown(
                value: _selectedCategory,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
                label: 'Categoría',
              ),
              const SizedBox(height: 16),

              // Campo de descripción
              CustomTextInput(
                controller: _descriptionController,
                label: 'Descripción',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Botón de guardar
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Aquí se manejará la lógica de guardar el producto
                    // Por ejemplo, llamar a un método del widget padre o bloc
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Producto guardado exitosamente'),
                      ),
                    );
                  }else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Por favor, completa todos los campos'),
                      ),
                    );
                  }
                }, // Lógica manejada externamente
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.buttonText,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Guardar Producto',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
