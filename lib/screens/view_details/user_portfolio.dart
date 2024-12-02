import 'package:flutter/material.dart';
import 'package:okto_flutter_sdk/okto_flutter_sdk.dart';
import 'package:placeholder/utils/okto.dart';

class UserPortfolioPage extends StatefulWidget {
  const UserPortfolioPage({super.key});

  @override
  State<UserPortfolioPage> createState() => _UserPortfolioPageState();
}

class _UserPortfolioPageState extends State<UserPortfolioPage> {
  Future<UserPortfolioResponse>? _userPortfolio;

  Future<UserPortfolioResponse> getuserPortfolio() async {
    try {
      final userPortfolio = await okto!.userPortfolio();
      return userPortfolio;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff5166EE),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(40),
              child: const Text(
                'User Portfolio',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _userPortfolio = getuserPortfolio();
                });
              },
              child: const Text('User Portfolio'),
            ),
            Expanded(
              child: _userPortfolio == null
                  ? Container()
                  : FutureBuilder<UserPortfolioResponse>(
                      future: _userPortfolio,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Colors.white));
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final userPortfolio = snapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: MediaQuery.sizeOf(context).height * 0.6,
                                  child: Text(
                                    userPortfolio.toJson(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                )
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
}
