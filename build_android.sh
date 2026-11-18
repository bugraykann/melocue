#!/bin/bash

# pubspec.yaml dosyasından mevcut versiyonu çek
current_version=$(grep '^version: ' pubspec.yaml | awk '{print $2}')

if [ -z "$current_version" ]; then
    echo "❌ pubspec.yaml içinde 'version:' bulunamadı!"
    exit 1
fi

# Versiyon adı (0.1.0) ve build numarasını (1) ayır
version_name=$(echo $current_version | cut -d '+' -f 1)
build_number=$(echo $current_version | cut -d '+' -f 2)

# Build numarasını 1 artır
new_build_number=$((build_number + 1))
new_version="${version_name}+${new_build_number}"

# Mac uyumlu sed ile pubspec.yaml içindeki versiyonu güncelle
sed -i '' "s/^version: .*/version: $new_version/" pubspec.yaml

echo "🚀 Versiyon başarıyla güncellendi: $current_version -> $new_version"

echo "🧹 Eski cache temizleniyor (flutter clean)..."
flutter clean > /dev/null
flutter pub get > /dev/null

# Yeni build numarasıyla AAB çıktısı al
echo "🔨 Android App Bundle (AAB) oluşturuluyor..."
flutter build appbundle --release

echo "✅ İşlem tamamlandı! Yeni sürümünüz Play Store'a yüklenmeye hazır."
