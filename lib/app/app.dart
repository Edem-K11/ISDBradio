import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import '../features/info/presentation/info_controller.dart';
import '../features/info/presentation/update_required_page.dart';
import 'router.dart';

class RadioIsdbApp extends StatelessWidget {
  const RadioIsdbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Radio ISDB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: context.watch<ThemeController>().mode,
      routerConfig: appRouter,
      builder: (context, child) {
        final info = context.watch<InfoController>();
        if (info.needsUpdate) {
          return UpdateRequiredPage(storeUrl: info.config?.androidStoreUrl);
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
