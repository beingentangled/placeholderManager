import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okto_flutter_sdk/okto_flutter_sdk.dart';
import 'package:placeholder/auth/google_login.dart';
import 'package:placeholder/screens/raw_txn/transaction_data_generator.dart';
import 'package:placeholder/utils/okto.dart';

class RawTransactioneExecutePage extends StatefulWidget {
  const RawTransactioneExecutePage({super.key});

  @override
  State<RawTransactioneExecutePage> createState() =>
      _RawTransactioneExecutePageState();
}

class _RawTransactioneExecutePageState
    extends State<RawTransactioneExecutePage> {
  final networkNameController = TextEditingController();
  final transactionObjectController = TextEditingController();
  Future<RawTransactionExecuteResponse>? _rawTransactionExecuted;
  Future<NetworkDetails>? _supportedNetworks;
  String _selectedNetwork = '';
  String _transactionData = '';
  String _selectedWalletAddress = '';

  Future<RawTransactionExecuteResponse> rawTransactionExecute() async {
    final transactionObject = jsonDecode(transactionObjectController.text);
    try {
      final orderHistory = await okto!.rawTransactionExecute(
          networkName: _selectedNetwork, transaction: transactionObject);
      return orderHistory;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<NetworkDetails> getSupportedNetworks() async {
    try {
      final supportedNetworks = await okto!.supportedNetworks();
      return supportedNetworks;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _supportedNetworks = getSupportedNetworks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              margin: const EdgeInsets.all(40),
              child: const Text(
                'Publish Your Ad',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20),
              ),
            ),
            // FutureBuilder<NetworkDetails>(
            //   future: _supportedNetworks,
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const CircularProgressIndicator(color: Colors.white);
            //     } else if (snapshot.hasError) {
            //       return Text(
            //         'Error: ${snapshot.error}',
            //         style: const TextStyle(color: Colors.white),
            //       );
            //     } else if (snapshot.hasData) {
            //       final supportedNetworks = snapshot.data!.data.network;
            //       return DropdownButton<String>(
            //         padding: const EdgeInsets.symmetric(horizontal: 20),
            //         isExpanded: true,
            //         value: _selectedNetwork,
            //         hint: const Text(
            //           'Select a Network',
            //           style: TextStyle(color: Colors.white),
            //         ),
            //         dropdownColor: const Color.fromARGB(255, 11, 31, 48),
            //         items: supportedNetworks.map((network) {
            //           return DropdownMenuItem<String>(
            //             value: network.networkName,
            //             child: Text(
            //               network.networkName,
            //               style: const TextStyle(color: Colors.white),
            //             ),
            //           );
            //         }).toList(),
            //         onChanged: (value) {
            //           setState(() {
            //             _selectedNetwork = value;
            //           });
            //         },
            //       );
            //     }
            //     return Container();
            //   },
            // ),
            // const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    // make a route to the transaction data generator page and navigate and await for a result
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionDataGenerator(),
                      ),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          var result = value;
                          transactionObjectController.text =
                              result['transactionData'];
                          _selectedNetwork = result['selectedNetwork'];
                          _transactionData = result['transactionData'];
                          _selectedWalletAddress =
                              result['selectedWalletAddress'];
                          generateTransactionData();
                        });
                      }
                    });
                  },
                  child: const Text('Build Transaction'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Transaction Object',
              style: TextStyle(color: Colors.white),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 11, 31, 48),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: transactionObjectController,
                maxLines: 10,
                scrollPhysics: const BouncingScrollPhysics(),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter transaction object',
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {
                if (_selectedNetwork.isEmpty || _transactionData.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please Build Transaction',
                      ),
                    ),
                  );
                  return;
                }
                setState(() {
                  _rawTransactionExecuted = rawTransactionExecute();
                });
              },
              child: const Text('Do Transaction'),
            ),
            ElevatedButton(
                onPressed: () async {
                  try {
                    await okto!.logout();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginWithGoogle()));
                  } catch (e) {
                    print(e);
                  }
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                )),
            Expanded(
              child: _rawTransactionExecuted == null
                  ? Container()
                  : FutureBuilder<RawTransactionExecuteResponse>(
                      future: _rawTransactionExecuted,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white));
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.white)));
                        } else if (snapshot.hasData) {
                          final transferNftResponse = snapshot.data!;
                          if (transferNftResponse.status == 'success') {
                            transactionObjectController.clear();
                            _rawTransactionExecuted = null;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Transaction Successful'),
                                ),
                              );
                            });
                          }
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transferNftResponse.status,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ],
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void generateTransactionData() {
    final transactionData = {
      'from': _selectedWalletAddress,
      'to': "0xD7A016b6Aed916815d4C5332fD93Ca307085F564",
      'data': _transactionData,
      'value': "0x",
    };
    transactionObjectController.text = jsonEncode(transactionData);
  }
}
