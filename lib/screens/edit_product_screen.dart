import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _isInit = false;
  var _title = '';
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    super.initState();

    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;

      if (productId != null) {
        final product =
            Provider.of<Products>(context, listen: false).findById(productId);
        _editedProduct = product;
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': _editedProduct.imageUrl,
        };
        _imageUrlController.text = _initValues['imageUrl'];
        _title = 'Edit Product';
      } else {
        _title = 'Add Product';
      }

      _isInit = true;
    }
  }

  @override
  void dispose() {
    super.dispose();

    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      final value = _imageUrlController.text;

      if (!value.startsWith('http') && !value.startsWith('https')) return;
      if (!value.endsWith('.png') &&
          !value.endsWith('.jpg') &&
          !value.endsWith('.jpeg')) return;
      setState(() {}); // Force update image when url input is unfocused
    }
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();

    if (isValid) {
      _form.currentState.save();

      if (_editedProduct.id != null) {
        // we are editing
        Provider.of<Products>(context, listen: false)
            .editProduct(_editedProduct.id, _editedProduct);
      } else {
        // adding new product
        Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initValues['title'],
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                validator: (value) {
                  if (value.isEmpty) return 'Please provide a value.';
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: value,
                    price: _editedProduct.price,
                    description: _editedProduct.description,
                    imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                validator: (value) {
                  if (value.isEmpty) return 'Please provide a value.';
                  if (double.tryParse(value) == null)
                    return 'Please enter a valid number.';
                  if (double.parse(value) <= 0)
                    return 'Please enter a number greater than 0.';
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: _editedProduct.title,
                    price: double.parse(value),
                    description: _editedProduct.description,
                    imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value.isEmpty) return 'Please provide a value.';
                  if (value.length < 10)
                    return 'Should be at least 10 characters long.';

                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: _editedProduct.title,
                    price: _editedProduct.price,
                    description: value,
                    imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: _imageUrlController.text.isEmpty
                        ? Text('Enter a URL')
                        : FittedBox(
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Image URL'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onFieldSubmitted: (value) => _saveForm(),
                      validator: (value) {
                        if (value.isEmpty) return 'Please provide a value.';
                        if (!value.startsWith('http') &&
                            !value.startsWith('https'))
                          return 'Please enter a valid URL.';
                        if (!value.endsWith('.png') &&
                            !value.endsWith('.jpg') &&
                            !value.endsWith('.jpeg'))
                          return 'Please enter a valid image URL.';

                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          description: _editedProduct.description,
                          imageUrl: value,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
