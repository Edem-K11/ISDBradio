
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isdb_radio/models/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveStorageConfig {
  
  // 1. VOIR où Hive stocke actuellement les données
  static Future<void> printCurrentStoragePaths() async {
    print("=== EMPLACEMENTS HIVE ===");
    
    // Emplacement par défaut de Hive
    final defaultPath = Hive.box('archives').path;
    print("📂 Emplacement actuel: $defaultPath");
    
    // Tous les emplacements possibles
    final appDocuments = await getApplicationDocumentsDirectory();
    final appSupport = await getApplicationSupportDirectory();
    final tempDir = await getTemporaryDirectory();
    final externalDir = Platform.isAndroid ? await getExternalStorageDirectory() : null;
    
    print("📁 Documents: ${appDocuments.path}");
    print("📁 Support: ${appSupport.path}");
    print("📁 Temp: ${tempDir.path}");
    if (externalDir != null) {
      print("📁 External: ${externalDir.path}");
    }
  }
  
  // 2. CHOISIR votre propre emplacement de stockage
  static Future<void> initWithCustomPath() async {
    // Option A: Répertoire Documents (recommandé)
    final documentsDir = await getApplicationDocumentsDirectory();
    final customPath = '${documentsDir.path}/isdb_radio_data';
    
    // Créer le dossier s'il n'existe pas
    final customDir = Directory(customPath);
    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
    }
    
    // Initialiser Hive avec ce chemin
    Hive.init(customPath);
    
    print("🎯 Hive initialisé dans: $customPath");
    
    // Maintenant vos données seront dans :
    // Android: /data/data/com.votre.package/app_flutter/isdb_radio_data/
    // iOS: /var/mobile/Containers/Data/Application/[ID]/Documents/isdb_radio_data/
  }
  
  // 3. CONFIGURATION AVANCÉE avec différents dossiers
  static Future<void> initWithOrganizedFolders() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final baseDir = '${documentsDir.path}/ISDB_Radio';
    
    if (kIsWeb) return;
    
    // Créer une structure organisée
    await Directory('$baseDir/audio_cache').create(recursive: true);
    await Directory('$baseDir/images_cache').create(recursive: true);
    await Directory('$baseDir/database').create(recursive: true);
    await Directory('$baseDir/downloads').create(recursive: true);
    
    // Hive dans le sous-dossier database
    Hive.init('$baseDir/database');
    
    print("🏗️ Structure créée :");
    print("   📁 $baseDir/");
    print("      ├── 📁 audio_cache/");
    print("      ├── 📁 images_cache/");
    print("      ├── 📁 database/      <- Hive ici");
    print("      └── 📁 downloads/");
  }
  
  // 4. STOCKAGE EXTERNE (Android uniquement)
  static Future<void> initExternalStorage() async {
    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final customPath = '${externalDir.path}/ISDB_Radio/database';
        
        await Directory(customPath).create(recursive: true);
        Hive.init(customPath);
        
        print("💾 Stockage externe Android: $customPath");
        // Données visibles dans l'explorateur de fichiers !
        // /storage/emulated/0/Android/data/com.votre.package/files/ISDB_Radio/database/
      }
    } else {
      print("⚠️ Stockage externe non disponible sur iOS");
      await initWithCustomPath(); // Fallback
    }
  }
  
  // 5. MIGRATION des données existantes
  static Future<void> migrateTo(String newPath) async {
    print("🔄 Migration des données vers: $newPath");
    
    // Fermer les boxes existantes
    await Hive.close();
    
    // Copier les fichiers
    final oldPath = Hive.box('archives').path;
    final oldDir = Directory(oldPath!).parent;
    final newDir = Directory(newPath);
    
    if (!await newDir.exists()) {
      await newDir.create(recursive: true);
    }
    
    // Copier tous les fichiers .hive
    await for (final file in oldDir.list()) {
      if (file is File && file.path.endsWith('.hive')) {
        final fileName = file.path.split('/').last;
        await file.copy('$newPath/$fileName');
        print("✅ Copié: $fileName");
      }
    }
    
    // Réinitialiser Hive avec le nouveau chemin
    Hive.init(newPath);
    
    print("✅ Migration terminée !");
  }
  
  // 6. NETTOYER l'ancien stockage
  static Future<void> cleanOldStorage(String oldPath) async {
    final oldDir = Directory(oldPath);
    if (await oldDir.exists()) {
      await oldDir.delete(recursive: true);
      print("🗑️ Ancien stockage supprimé: $oldPath");
    }
  }
  
  // 7. TAILLE du stockage
  static Future<void> getStorageInfo() async {
    final box = Hive.box('archives');
    final boxPath = box.path;
    final file = File(boxPath!);
    
    if (await file.exists()) {
      final sizeBytes = await file.length();
      final sizeMB = (sizeBytes / (1024 * 1024)).toStringAsFixed(2);
      
      print("📊 Taille base archives: ${sizeMB} MB");
      print("📊 Nombre d'éléments: ${box.length}");
    }
  }
}

// EXEMPLE d'utilisation avancée
class StorageManager {
  // Changer l'emplacement en cours d'utilisation
  static Future<void> changeStorageLocation(String newLocation) async {
    final oldPath = Hive.box('archives').path;
    
    // Migrer
    await HiveStorageConfig.migrateTo(newLocation);
    
    // Réouvrir les boxes
    await Hive.openBox<Archive>('archives');
    await Hive.openBox<Archive>('podcasts');
    
    // Optionnel: supprimer l'ancien stockage
    if (oldPath != null) {
      await HiveStorageConfig.cleanOldStorage(Directory(oldPath).parent.path);
    }
  }
  
  // Sauvegarder les données
  static Future<void> backupDatabase(String backupPath) async {
    final sourcePath = Hive.box('archives').path;
    if (sourcePath != null) {
      final sourceFile = File(sourcePath);
      await sourceFile.copy('$backupPath/archives_backup.hive');
      print("💾 Sauvegarde créée: $backupPath/archives_backup.hive");
    }
  }
}