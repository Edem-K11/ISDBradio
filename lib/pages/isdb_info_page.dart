
import 'package:flutter/material.dart';
import 'package:isdb_radio/widgets/draw_list_tile.dart';

class IsdbInfoPage extends StatelessWidget {
const IsdbInfoPage({ super.key });

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('ISDB Information'),
      ),
      body: ListView(
        children: [
          DrawerListTile(
            icon: Icons.home_rounded, 
            title: 'Nom de l\'application', 
            subtitle: 'ISDB Radio',
            onTap: (){}
          ),
          DrawerListTile(
            icon: Icons.info_rounded, 
            title: 'Version', 
            subtitle: '1.0.0',
            onTap: (){}
          ),
          DrawerListTile(
            icon: Icons.copyright, 
            title: 'Copyright', 
            subtitle: '© 2025 ISDB. All rights reserved.',
            onTap: (){}
          ),
          DrawerListTile(
            icon: Icons.star_rounded, 
            title: 'Evaluer l\'application', 
            subtitle: 'Laissez-nous un avis',
            onTap: (){}
          ),
          DrawerListTile(
            icon: Icons.language_rounded, 
            title: 'Web', 
            subtitle: 'Site web de l\'ISDB',
            onTap: (){},
          ),
          
        ],
      )
    );
  }
}