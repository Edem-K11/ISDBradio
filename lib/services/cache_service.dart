
import 'package:hive_flutter/adapters.dart';
import 'package:isdb_radio/config/hive_storage_config.dart';
import 'package:isdb_radio/models/archive.dart';

class CacheService {
  // Les "boîtes" Hive - comme des tiroirs
  static Box<Archive>? _archivesBox;
  static Box<Archive>? _podcastsBox;
  
  // Initialiser Hive (à appeler au démarrage de l'app)
  static Future<void> init() async {
    // Option 1: Emplacement par défaut
    // await Hive.initFlutter();

    // Option 2: Emplacement personnalisé organisé (RECOMMANDÉ)
    await HiveStorageConfig.initWithOrganizedFolders();

    // Voir où sont stockées les données
    await HiveStorageConfig.printCurrentStoragePaths();

    
    // Enregistrer votre modèle Archive
    Hive.registerAdapter(ArchiveAdapter());
    
    // Ouvrir les boîtes (tiroirs)
    _archivesBox = await Hive.openBox<Archive>('archives');
    _podcastsBox = await Hive.openBox<Archive>('podcasts');

    // Afficher les infos de stockage
    await HiveStorageConfig.getStorageInfo();
  }
  
  // SAUVEGARDER des archives
  static Future<void> saveArchives(List<Archive> archives) async {
    final box = _archivesBox!;
    
    // Vider l'ancienne liste
    await box.clear();
    
    // Ajouter les nouvelles
    for (int i = 0; i < archives.length; i++) {
      await box.put(i, archives[i]);
    }
  }
  
  // RÉCUPÉRER les archives (instantané !)
  static List<Archive> getArchives() {
    final box = _archivesBox!;
    return box.values.toList();
  }
  
  // SAUVEGARDER des podcasts
  static Future<void> savePodcasts(List<Archive> podcasts) async {
    final box = _podcastsBox!;
    await box.clear();
    
    for (int i = 0; i < podcasts.length; i++) {
      await box.put(i, podcasts[i]);
    }
  }
  
  // RÉCUPÉRER les podcasts (instantané !)
  static List<Archive> getPodcasts() {
    final box = _podcastsBox!;
    return box.values.toList();
  }
}