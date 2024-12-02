// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:okto_flutter_sdk/okto_flutter_sdk.dart';
import 'package:web3dart/web3dart.dart';

import '../../utils/okto.dart';

class TransactionDataGenerator extends StatefulWidget {
  const TransactionDataGenerator({super.key});

  @override
  _TransactionDataGeneratorState createState() =>
      _TransactionDataGeneratorState();
}

class _TransactionDataGeneratorState extends State<TransactionDataGenerator> {
  final TextEditingController _numController = TextEditingController();
  String? _transactionData;
  String? _selectedWalletAddress = '';
  String? _selectedNetwork = '';

  Future<WalletResponse> fetchWallets() async {
    try {
      final wallets = await okto!.createWallet();
      return wallets;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _generateTransactionData() async {
    const String abiString = '''
  [
     {
      "inputs": [],
      "name": "retrieve",
      "outputs": [
       {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
       }
      ],
      "stateMutability": "view",
      "type": "function"
     },
     {
      "inputs": [
        {
         "internalType": "uint256",
         "name": "num",
         "type": "uint256"
        }
      ],
      "name": "store",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
     }
    ]
  ''';

//convert to uint256 _numController

    // Replace with your contract address
    final EthereumAddress contractAddress =
        EthereumAddress.fromHex('0xD7A016b6Aed916815d4C5332fD93Ca307085F564');

    // Parse ABI and set up contract
    final ContractAbi contractAbi =
        ContractAbi.fromJson(abiString, 'SimpleStorage');
    final DeployedContract contract =
        DeployedContract(contractAbi, contractAddress);
    final ContractFunction storeFunction = contract.function('store');

    // Parse input as BigInt for uint256
    try {
      // Define the base number (123)
      final BigInt numValue = BigInt.from(int.parse(_numController.text));

      // Define the multiplier for 1e18 Wei
      final BigInt weiMultiplier = BigInt.from(10).pow(18);

      // Perform the multiplication
      final BigInt result = numValue * weiMultiplier;

      // Print the result
      print('123 multiplied by 1e18 Wei: $result');

      // Prepare parameters
      final List<dynamic> params = [result];

      // Encode transaction data for the function call
      final Uint8List transactionData = storeFunction.encodeCall(params);

      // Convert transaction data to hex
      final String dataHex = bytesToHex(transactionData, include0x: true);

      // Update the state with the transaction data
      setState(() {
        _transactionData = dataHex;
        //pop with result _transactionData, _selectedNetwork, _selectedWalletAddress
        Map<String, String> result = {
          'transactionData': _transactionData!,
          'selectedNetwork': _selectedNetwork!,
          'selectedWalletAddress': _selectedWalletAddress!
        };
        Navigator.pop(context, result);
      });
    } catch (e) {
      // Handle parsing or range errors
      setState(() {
        _transactionData = 'Error: ${e.toString()}';
      });
    }
  }

// Utility function to convert Uint8List to hex
  String bytesToHex(Uint8List bytes, {bool include0x = false}) {
    final buffer = StringBuffer();
    if (include0x) {
      buffer.write('0x');
    }
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Generate Transaction Data',
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              controller: _numController,
              decoration: const InputDecoration(
                labelText: 'Enter number',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_selectedNetwork!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a network'),
                    ),
                  );
                } else if (_numController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a number'),
                    ),
                  );
                } else {
                  _generateTransactionData();
                }
              },
              child: const Text('Generate Transaction Data'),
            ),
            const SizedBox(height: 20),
            if (_transactionData != null)
              SelectableText(
                'Encoded Transaction Data:\n$_transactionData',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<WalletResponse>(
                future: fetchWallets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final wallets = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select a Network',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: wallets.data.wallets.length,
                            itemBuilder: (context, index) {
                              final wallet = wallets.data.wallets[index];
                              final isSelected =
                                  _selectedNetwork == wallet.networkName;
                              return InkWell(
                                enableFeedback: true,
                                onTap: () {
                                  setState(() {
                                    _selectedWalletAddress = wallet.address;
                                    _selectedNetwork = wallet.networkName;
                                  });
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue.shade100
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.blue, width: 2)
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // SelectableText(
                                      //   'Wallet Address: ${wallet.address}',
                                      //   style: TextStyle(
                                      //     fontSize: 16,
                                      //     fontWeight: isSelected
                                      //         ? FontWeight.bold
                                      //         : FontWeight.normal,
                                      //   ),
                                      // ),
                                      Text(
                                        'Network Name: ${wallet.networkName}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(child: Text('No wallets available.'));
                },
              ),
            ),
            if (_selectedNetwork != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Selected  Network:\n$_selectedNetwork',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
