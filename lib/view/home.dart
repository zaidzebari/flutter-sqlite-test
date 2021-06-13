import 'package:first_test_for_flutter/model/client_model.dart';
import 'package:first_test_for_flutter/services/DBProvider_service.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController _name = new TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _name.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutter SQLite")),
      body: Column(
        children: [
          Container(
            height: 100,
            child: Form(
              key: _key,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      // prefixIcon: Icon(Icons.person),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _name.clear();
                          setState(() {});
                        },
                        icon: Icon(Icons.clear),
                      ),
                      hintText: 'Enter name ',
                      labelText: 'Name ',
                    ),
                    onSaved: (String? value) {},
                    validator: (String? value) {
                      return (value != null && value.contains('@'))
                          ? 'Do not use the @ char.'
                          : null;
                    },
                  )
                ],
              ),
            ),
          ),
          Flexible(
            child: FutureBuilder<List<Client>>(
              future: DBProvider.db.getAllClients(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Client>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (BuildContext context, int index) {
                      Client item = snapshot.data![index];
                      return Dismissible(
                        key: UniqueKey(),
                        background: Container(color: Colors.red),
                        onDismissed: (direction) {
                          DBProvider.db.deleteClient(item.id);
                        },
                        child: ListTile(
                          title: Text(item.firstName),
                          leading: Text(item.id.toString()),
                          trailing: Checkbox(
                            onChanged: (value) {
                              DBProvider.db.blockOrUnblock(item);
                              setState(() {});
                            },
                            value: item.blocked,
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  print('list is empty');
                  return Center(child: Text('Loadding..'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // Client rnd = testClients[Random().nextInt(testClients.length)];
          // String query =
          // "INSERT Into Client (id,first_name,last_name,blocked) VALUES (?,?,?,?)";
          Map<String, dynamic> data = new Client(
                  id: Random().nextInt(111111),
                  firstName: _name.text,
                  lastName: 'salah',
                  blocked: false)
              .toMap();
          await DBProvider.db.insert('Client', data);
          // await DBProvider.db.newClient(rnd);
          setState(() {});
        },
      ),
    );
  }
}
