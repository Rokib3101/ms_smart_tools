# Optimize and shrink code
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# Remove unused resources
-dontwarn javax.annotation.**
-dontwarn org.checkerframework.**
-dontwarn com.google.errorprone.annotations.**

# Flutter Engine optional dependencies for deferred components.
# These are safe to ignore as the app does not use deferred components.
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
