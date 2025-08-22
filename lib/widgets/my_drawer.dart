import 'package:flutter/material.dart';
import 'package:isdb_radio/models/navigation_provider.dart';
import 'package:isdb_radio/pages/isdb_info_page.dart';
import 'package:isdb_radio/widgets/draw_list_tile.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    // ✅ On réutilise la même instance
    final logoProvider = AssetImage(
      'assets/images/logo_isdb.png',
    );

    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Drawer(
            child: Column(
              children: [
                // Header avec image de fond et overlay vert
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // Image de fond
                      // Container(
                      //   width: double.infinity,
                      //   height: double.infinity,
                      //   decoration: BoxDecoration(
                      //     image: DecorationImage(
                      //       image: AssetImage('assets/images/logo_isdb.png'),
                      //       fit: BoxFit.fitWidth,
                      //     ),
                      //   ),
                      // ),
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.3, // ⚡ Optionnel : rendre le fond plus léger
                          child: Image(
                            image: logoProvider, 
                            fit: BoxFit.cover,
                           ) ,
                        ),
                      ),

                      // Overlay vert semi-transparent
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withValues(alpha: 1.0), // En haut
                              Colors.black.withValues(alpha: 0.8), // En bas
                            ],
                            // stops: [
                            //   0.7, // Primary occupe jusqu'à 70% de la hauteur
                            //   1.0  // Noir occupe le reste
                            // ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Logo avec fond blanc circulaire
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image(
                                  image: logoProvider,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: 10), // Espace entre le logo et le texte

                            // Texte "Radio ISDB"
                            Text(
                              'Radio ISDB',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                    ],
                  ),
                ),
                // Liste des éléments du drawer
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Items de navigation principale
                      DrawerListTile(
                        icon: Icons.sensors_rounded,
                        title: 'Direct',
                        isSelected: navigationProvider.currentIndex == 0,
                        onTap: () {
                          navigationProvider.goToLive();
                          Navigator.pop(context);
                        },
                      ),
                      DrawerListTile(
                        icon: Icons.archive,
                        title: 'Émissions',
                        isSelected: navigationProvider.currentIndex == 1,
                        onTap: () {
                          navigationProvider.goToArchive();
                          Navigator.pop(context);
                        },
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                      // Autres items
                      DrawerListTile(
                        icon: Icons.language,
                        title: 'Site web',
                        onTap: () {
                          // Ouvrir le site web
                          Navigator.pop(context);
                        },
                      ),
                      DrawerListTile(
                        icon: Icons.phone_android,
                        title: 'Évaluer l\'app',
                        onTap: () {
                          // Ouvrir le store pour évaluer
                          Navigator.pop(context);
                        },
                      ),
                      DrawerListTile(
                        icon: Icons.info_outline,
                        title: 'Informations',
                        onTap: () {
                          // Afficher les informations

                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IsdbInfoPage(), // Remplacez par votre page d'infos
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Bouton Quitter en bas
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: DrawerListTile(
                    icon: Icons.exit_to_app,
                    title: 'Quitter',
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () {
                      // Fermer l'application
                      Navigator.pop(context);
                      // Vous pouvez ajouter ici la logique pour fermer l'app
                    },
                  ),
                ),
              ],
            ),
          );
      },
    );
  }
}

