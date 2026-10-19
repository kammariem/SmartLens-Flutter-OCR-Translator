
# 1. Image contenant Flutter et Android SDK
FROM ghcr.io/cirruslabs/flutter:stable

# 2. Dossier de travail dans le conteneur
WORKDIR /app

# 3. Copier les fichiers des dépendances
COPY pubspec.yaml ./

# 4. Télécharger les dépendances Flutter
RUN flutter pub get

# 5. Copier le code source du projet
COPY . .

# 6. Compiler l'application Android
CMD ["flutter", "build", "apk", "--debug"]
