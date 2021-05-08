import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:email_validator/email_validator.dart';

class ContactPage extends StatefulWidget {
  Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool _userEdited = false;
  Contact _editedContact;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  void _resetFormWarning() {
    setState(() {
      _formKey = GlobalKey<FormState>();
    });
  }

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener((value) {
      print("ID: ${value.logicalKey.keyId}");
    });
    if (widget.contact == null)
      _editedContact = Contact();
    else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _requestPop,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            title: Text(_editedContact.name ?? "Novo Contato"),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              bool res = _formKey.currentState.validate();
              setState(() {
                print("Save clicked");
                print(res);
              });
              if (res == false) return;
              if (_editedContact.name != null &&
                  _editedContact.name.isNotEmpty) {
                Navigator.pop(context, _editedContact);
              } else {
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.blueAccent,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _editedContact.img != null &&
                                  File(_editedContact.img).existsSync()
                              ? FileImage(File(_editedContact.img))
                              : AssetImage("images/person_icon.png"),
                        )),
                    // child:
                  ),
                  onTap: () {
                    ImagePicker picker = ImagePicker();
                    picker.getImage(source: ImageSource.gallery).then((value) {
                      if (value == null) return;
                      setState(() {
                        _editedContact.img = value.path;
                        print(value.path);
                        _userEdited = true;
                      });
                    });
                  },
                ),
                Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _createTextFormField(
                              "Nome", _setName, TextInputType.name,
                              controller: _nameController, validator: (value) {
                            if (value.isEmpty) return "Informe o nome!";
                            // return "";
                          }),
                          _createTextFormField(
                              "Email", _setEmail, TextInputType.emailAddress,
                              controller: _emailController, validator: (value) {
                            if (value.isEmpty) return "Informe o email!";
                            if (!_validateEmail(value))
                              return "Informe um email válido";
                            // return "";
                          }),
                          _createTextFormField(
                              "Fone", _setPhone, TextInputType.number,
                              controller: _phoneController, validator: (value) {
                            if (value.isEmpty) return "Informe o fone!";
                            // return "";
                          }, formatNumber: _formatPhoneNumber),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ));
  }

  bool _validateEmail(String email) => EmailValidator.validate(email);

  void _setName(String name) => _editedContact.name = name;
  void _setEmail(String email) => _editedContact.email = email;
  void _setPhone(String phone) => _editedContact.phone = phone;

  Widget _createTextFormField(
      String label, Function contactFieldSet, TextInputType keyboardType,
      {TextEditingController controller,
      String Function(String) validator,
      String Function(String) formatNumber}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      onChanged: (text) {
        // print("$text ${controller.text}");
        if (formatNumber != null) controller.text = formatNumber(text);
        setState(() {
          controller.selection =
              TextSelection.collapsed(offset: controller.text.length);
        });
        // _resetFormWarning();
        // if (text.length == 1) _formKey.currentState.validate();
        _userEdited = true;
        contactFieldSet(text);
      },
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  bool _deleteKeyPressed(Set<LogicalKeyboardKey> value) {
    if (value.isEmpty) return false;
    return value.first.keyId == 4295426090;
  }

  String _formatPhoneNumber(String number) {
    // return number;
    if (number.isEmpty) return "";
    // (88) 9 1122-3344'
    String n = number;
    number = number.replaceAll(RegExp("([^0-9])+"), "");
    print("Eoq $n $number");
    if (_deleteKeyPressed(RawKeyboard.instance.keysPressed)) return n;
    if (number.length == 1) return "\($number";
    if (number.length > 1 && number.length < 7)
      return "\(${number.substring(0, 2)}\)${number.substring(2, number.length)}";
    if (number.length > 7 && number.length < 10)
      return "\(${number.substring(0, 2)}\)${number.substring(2, 7)}-${number.substring(7, number.length)}";
    if (number.length >= 10) return n.substring(0, 14);
    // return number;
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Deseja descartar as alterações ?"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: <Widget>[
                ElevatedButton(
                  child: Text("Não"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      return Future.value(false);
    }
    return Future.value(true);
  }
}
