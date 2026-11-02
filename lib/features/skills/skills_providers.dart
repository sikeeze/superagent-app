import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/skills/skill_manifest.dart';
import '../../core/skills/skill_store.dart';

/// Folder root penyimpanan skill (folder data aplikasi).
Future<Directory> skillsRoot() async {
  final dir = await getApplicationDocumentsDirectory();
  return Directory('${dir.path}${Platform.pathSeparator}skills');
}

/// Provider root skill store.
final skillStoreProvider = FutureProvider<SkillStore>((ref) async {
  final store = SkillStore(await skillsRoot());
  await store.ensure();
  return store;
});

/// Daftar skill terpasang (manifest saja; P-01: bangun saat lihat).
final skillListProvider = FutureProvider<List<SkillManifest>>((ref) async {
  final store = await ref.watch(skillStoreProvider.future);
  final names = await store.listNames();
  final manifests = <SkillManifest>[];
  for (final n in names) {
    final m = await store.readManifest(n);
    if (m != null) manifests.add(m);
  }
  return manifests;
});
