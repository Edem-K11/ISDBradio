
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

/// Classe centralisant toutes les icônes de l'application
/// Utilise MingCute Icons pour une cohérence visuelle
class AppIcons {
  AppIcons._(); // Constructeur privé pour empêcher l'instanciation

  // Navigation
  static const IconData radar = MingCuteIcons.mgc_radar_line;
  static const IconData radarFill = MingCuteIcons.mgc_radar_fill;
  static const IconData archive = MingCuteIcons.mgc_archive_line;
  static const IconData archiveFill = MingCuteIcons.mgc_archive_fill;
  static const IconData profile = MingCuteIcons.mgc_user_3_line;
  static const IconData settings = MingCuteIcons.mgc_settings_1_line;
  static const IconData menu = MingCuteIcons.mgc_menu_line;
  
  // Actions
  static const IconData add = MingCuteIcons.mgc_add_line;
  static const IconData edit = MingCuteIcons.mgc_edit_line;
  static const IconData delete = MingCuteIcons.mgc_delete_line;
  static const IconData refresh = MingCuteIcons.mgc_refresh_1_line;
  static const IconData save = MingCuteIcons.mgc_save_line;
  static const IconData close = MingCuteIcons.mgc_close_line;
  
  // Communication
  static const IconData mail = MingCuteIcons.mgc_mail_line;
  static const IconData phone = MingCuteIcons.mgc_phone_line;
  static const IconData message = MingCuteIcons.mgc_message_1_line;
  static const IconData notification = MingCuteIcons.mgc_notification_line;
  
  // Navigation directionnelle
  static const IconData arrowBack = MingCuteIcons.mgc_left_line;
  static const IconData arrowForward = MingCuteIcons.mgc_right_line;
  static const IconData arrowUp = MingCuteIcons.mgc_up_line;
  static const IconData arrowDown = MingCuteIcons.mgc_down_line;
  
  // États
  static const IconData favorite = MingCuteIcons.mgc_heart_line;
  static const IconData favoriteFilled = MingCuteIcons.mgc_heart_fill;
  static const IconData visibility = MingCuteIcons.mgc_eye_line;
  static const IconData visibilityOff = MingCuteIcons.mgc_eye_close_line;
  
  // Media
  static const IconData play = MingCuteIcons.mgc_play_line;
  static const IconData playFill = MingCuteIcons.mgc_play_fill;
  static const IconData pause = MingCuteIcons.mgc_pause_line;
  static const IconData pauseFill = MingCuteIcons.mgc_pause_fill;
  static const IconData rewindBackward = MingCuteIcons.mgc_rewind_backward_10_line;
  static const IconData rewindForward = MingCuteIcons.mgc_rewind_forward_10_line;
  static const IconData skipPrevious = MingCuteIcons.mgc_skip_previous_line;
  static const IconData skipForward = MingCuteIcons.mgc_skip_forward_line;
  static const IconData volume = MingCuteIcons.mgc_volume_line;
  
  // Système
  static const IconData warning = MingCuteIcons.mgc_warning_line;
  static const IconData error = MingCuteIcons.mgc_close_circle_line;
  static const IconData success = MingCuteIcons.mgc_check_circle_line;
  static const IconData info = MingCuteIcons.mgc_information_line;
  
}