# Keep just_audio / audio_service / ExoPlayer members used via reflection.
-keep class com.ryanheise.** { *; }
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**
