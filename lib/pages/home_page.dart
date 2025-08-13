import 'package:flutter/material.dart';
import 'package:isdb_radio/models/navigation_provider.dart';
import 'package:isdb_radio/widgets/my_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
const HomePage({ super.key });

  @override
  Widget build(BuildContext context){
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) 
      {
        Widget currentPage = navigationProvider.currentPage;
        String currentTitle = navigationProvider.currentTitle;
        return Scaffold(
          appBar: AppBar(
            title: Text(currentTitle),
            leading: IconButton(
              onPressed: (){}, 
              icon: Icon(Icons.menu)
            ),
          ),
          body: currentPage,
          bottomNavigationBar: MyBottomNavigationBarWidget(),
        );
      }
    );
  }
}