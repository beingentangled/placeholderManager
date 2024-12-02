import 'package:flutter/material.dart';
import 'package:okto_flutter_sdk/okto_flutter_sdk.dart';
import 'package:placeholder/utils/okto.dart';

class TransferTokensPage extends StatefulWidget {
  const TransferTokensPage({super.key});

  @override
  State<TransferTokensPage> createState() => _TransferTokensPageState();
}

class _TransferTokensPageState extends State<TransferTokensPage> {
  final networkNameController = TextEditingController();
  final tokenAddressController = TextEditingController();
  final quantityController = TextEditingController();
  final recipientAddressController = TextEditingController();

  Future<TransferTokenResponse>? _transferToken;
  Future<NetworkDetails>? _supportedNetworks;
  String? _selectedNetwork;

  @override
  void initState() {
    super.initState();
    _supportedNetworks = getSupportedNetworks();
  }

  Future<TransferTokenResponse> transferToken() async {
    try {
      print("SUBB ${_selectedNetwork}");
      final transferToken = await okto!.transferTokens(
        networkName: _selectedNetwork ?? '',
        tokenAddress: tokenAddressController.text,
        quantity: quantityController.text,
        recipientAddress: recipientAddressController.text,
      );
      return transferToken;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 12, 40),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(40),
                child: const Text(
                  'Transfer Tokens',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 30),
                ),
              ),
              FutureBuilder<NetworkDetails>(
                future: _supportedNetworks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.white);
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    );
                  } else if (snapshot.hasData) {
                    final supportedNetworks = snapshot.data!.data.network;
                    return DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedNetwork,
                      hint: const Text(
                        'Select a Network',
                        style: TextStyle(color: Colors.white),
                      ),
                      dropdownColor: const Color.fromARGB(255, 11, 31, 48),
                      items: supportedNetworks.map((network) {
                        return DropdownMenuItem<String>(
                          value: network.networkName,
                          child: Text(
                            network.networkName,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedNetwork = value;
                        });
                      },
                    );
                  }
                  return Container();
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: tokenAddressController,
                  decoration: const InputDecoration(
                      label: Text('Token Address (Not mandatory)',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: quantityController,
                  decoration: const InputDecoration(
                      label: Text('Quantity',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: recipientAddressController,
                  decoration: const InputDecoration(
                      label: Text('Recipient Address',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _transferToken = transferToken();
                    });
                  },
                  child: const Text(
                    'Transfer Token',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _transferToken == null
                    ? Container()
                    : FutureBuilder<TransferTokenResponse>(
                        future: _transferToken,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white));
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                          } else if (snapshot.hasData) {
                            final transferTokenResponse = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SelectableText(
                                    'Order ID: ${transferTokenResponse.data.orderId}',
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
      ),
    );
  }
}
