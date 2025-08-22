import 'package:flutter/material.dart';
import 'package:isdb_radio/models/navigation_provider.dart';
import 'package:isdb_radio/widgets/my_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  
  void initState() {
    super.initState();
    // rien ici pour precacheImage
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Ici c’est safe : context est prêt
    precacheImage(const AssetImage('assets/images/logo_isdb.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        Widget currentPage = navigationProvider.currentPage;
        return SafeArea(
          child: Scaffold(
            body: currentPage,
            bottomNavigationBar: const MyBottomNavigationBarWidget(),
          ),
        );
      },
    );
  }
}
