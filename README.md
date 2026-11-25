# Atelier Closet — Digital Wardrobe & Outfit Studio (Flutter)

A local-first digital wardrobe, outfit shuffle studio, freeform moodboard canvas, OOTD calendar, and cost-per-wear analytics app built in Flutter.

## Features
1. **Closet Digitization:** Pick from Camera/Gallery with on-device **Google ML Kit Subject Segmentation** for automatic background removal into transparent PNG cutouts.
2. **Closet Grid & Filtering:** Filter items by Category (Tops, Bottoms, Footwear, Outerwear, Accessories), Season, and search by brand/tags.
3. **Outfit Shuffle Studio ("Dress Me"):** Clueless-inspired 3-tier carousel with item locking and random shuffle, plus a **Freeform Moodboard Canvas** with drag, pinch-to-zoom, rotation, and z-index layering.
4. **OOTD Calendar & Trip Packing:** Plan or log outfits on specific dates (auto-incrementing item wear counts) and generate visual packing checklists.
5. **Wardrobe Analytics:** Real-time calculation of Total Closet Value, Average Cost-Per-Wear (CPW), Most Worn Gems, and Unworn Items.

## Getting Started
```bash
flutter pub get
flutter run
```

## Pushing to GitHub
```bash
git init
git add .
git commit -m "Initial commit: Atelier Closet Flutter MVP"
git branch -M main
git remote add origin https://github.com/<YOUR_USERNAME>/atelier-closet.git
git push -u origin main
```
