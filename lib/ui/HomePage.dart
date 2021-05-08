import 'package:agenda_de_contatos/ui/createContactPage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();

    // Contact c = Contact.fromContact("eoq", "fon", "sehloiro", "img");
    // helper.saveContact(c);

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Contatos",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordernar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordernar de Z-A"),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return createCards(context, index);
          }),
    );
  }

  Widget createCards(context, index) {
    return GestureDetector(
      onTap: () {
        _showContactPage(contact: contacts[index]);
      },
      onLongPress: () {
        _showOptions(context, index);
      },
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: contacts[index].img != null &&
                              File(contacts[index].img).existsSync()
                          ? FileImage(File(contacts[index].img))
                          : AssetImage("images/person_icon.png")),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].name ?? "",
                      style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  int _orderList(OrderOptions order) {
    setState(() {
      contacts.sort((a, b) {
        switch (order) {
          case OrderOptions.orderaz:
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
            break;
          case OrderOptions.orderza:
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
            break;
          default:
            return -1;
        }
      });
    });
    return -1;
  }

  void _showOptions(context, index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            launch("tel:${contacts[index].phone}");
                            Navigator.pop(context);
                          },
                          child: Text("Ligar"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactPage();
                          },
                          child: Text("Editar"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                        "Deseja realmente excluir este contato ?"),
                                    actions: <Widget>[
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Não")),
                                      ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            await helper.deleteContact(
                                                contacts[index].id);

                                            setState(() {
                                              contacts.removeAt(index);
                                            });
                                          },
                                          child: Text("Sim"))
                                    ],
                                  );
                                });
                          },
                          child: Text("Excluir"),
                        ),
                      )
                    ],
                  ),
                );
              });
        });
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (recContact != null) {
      if (contact != null)
        await helper.updateContact(recContact);
      else
        await helper.saveContact(recContact);

      _getAllContacts();
    }
  }

  void _getAllContacts() async {
    await helper.getAllContacts().then((contacts) {
      this.contacts = contacts;
    });
    setState(() {
      print(this.contacts);
    });
  }
}

// contacts[index] != null
//                             ? FileImage(File(contacts[index].img))
//                             : Image.asset("images/person_icon")
