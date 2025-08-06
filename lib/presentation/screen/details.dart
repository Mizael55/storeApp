import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:store_app/models/product.dart';
import 'package:store_app/presentation/screen/cart.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Function(Product) onProductUpdated;
  final Function(String) onProductDeleted;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onProductUpdated,
    required this.onProductDeleted,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _currentProduct;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  File? _selectedImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _nameController = TextEditingController(text: _currentProduct.name);
    _priceController = TextEditingController(text: _currentProduct.price.toString());
    _descriptionController = TextEditingController(text: _currentProduct.description);
    _selectedCategory = _currentProduct.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Resetear cambios si se cancela la edición
        _nameController.text = _currentProduct.name;
        _priceController.text = _currentProduct.price.toString();
        _descriptionController.text = _currentProduct.description;
        _selectedCategory = _currentProduct.category;
        _selectedImage = null;
      }
    });
  }

  void _saveChanges() {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y precio son requeridos')),
      );
      return;
    }

    final updatedProduct = Product(
      id: _currentProduct.id,
      name: _nameController.text,
      price: double.parse(_priceController.text),
      description: _descriptionController.text,
      category: _selectedCategory,
      imageUrl: _currentProduct.imageUrl, // Mantener la URL original si no se cambia la imagen
      discount: _currentProduct.discount,
      isFavorite: _currentProduct.isFavorite,
    );

    setState(() {
      _currentProduct = updatedProduct;
      _isEditing = false;
    });

    widget.onProductUpdated(updatedProduct);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto actualizado correctamente')),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content: const Text('¿Estás seguro de que quieres eliminar este producto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onProductDeleted(_currentProduct.id);
                Navigator.pop(context); // Regresar a la pantalla anterior
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final discountedPrice = _currentProduct.price * (1 - _currentProduct.discount / 100);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _isEditing
                  ? GestureDetector(
                      onTap: () => _showImagePickerDialog(),
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              _currentProduct.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, size: 50),
                                ),
                              ),
                            ),
                    )
                  : Hero(
                      tag: 'product-${_currentProduct.id}',
                      child: Image.network(
                        _currentProduct.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 50),
                        ),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _currentProduct.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _currentProduct.isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _currentProduct.isFavorite = !_currentProduct.isFavorite;
                  });
                  widget.onProductUpdated(_currentProduct);
                },
              ),
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _toggleEditMode,
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditing) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del producto',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: const [
                        DropdownMenuItem(value: 'Electrónica', child: Text('Electrónica')),
                        DropdownMenuItem(value: 'Ropa', child: Text('Ropa')),
                        DropdownMenuItem(value: 'Hogar', child: Text('Hogar')),
                        DropdownMenuItem(value: 'Deportes', child: Text('Deportes')),
                        DropdownMenuItem(value: 'Juguetes', child: Text('Juguetes')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _toggleEditMode,
                            child: const Text('Cancelar',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _saveChanges,
                            child: const Text('Guardar',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _confirmDelete,
                        child: const Text('Eliminar Producto',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _currentProduct.category,
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_currentProduct.discount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentProduct.discount}% OFF',
                              style: TextStyle(
                                color: Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentProduct.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (_currentProduct.discount > 0)
                          Text(
                            '\$${_currentProduct.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (_currentProduct.discount > 0) const SizedBox(width: 8),
                        Text(
                          '\$${discountedPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentProduct.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Especificaciones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSpecificationItem('Marca', 'TechCorp'),
                    _buildSpecificationItem('Modelo', '2023'),
                    _buildSpecificationItem('Color', 'Negro'),
                    _buildSpecificationItem('Garantía', '1 año'),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isEditing ? null : _buildBottomBar(context),
    );
  }

  Widget _buildSpecificationItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: QuantitySelector(
              onDecrement: () {},
              onIncrement: () {},
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: const Text(
                'Añadir al carrito',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${_currentProduct.name} añadido al carrito'),
                    action: SnackBarAction(
                      label: 'Ver carrito',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar imagen'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galería'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Cámara'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class QuantitySelector extends StatefulWidget {
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const QuantitySelector({
    super.key,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              if (quantity > 1) {
                setState(() => quantity--);
                widget.onDecrement();
              }
            },
          ),
          Text(
            quantity.toString(),
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() => quantity++);
              widget.onIncrement();
            },
          ),
        ],
      ),
    );
  }
}