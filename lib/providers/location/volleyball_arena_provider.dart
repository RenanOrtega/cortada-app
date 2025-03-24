import 'package:cortada_app/model/volleyball_arena_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final volleyballArenasProvider =
    StateNotifierProvider<VolleyballArenaNotifier, List<VolleyballArena>>(
        (ref) {
  return VolleyballArenaNotifier();
});

class VolleyballArenaNotifier extends StateNotifier<List<VolleyballArena>> {
  VolleyballArenaNotifier() : super([]) {
    state = [
      VolleyballArena(
        id: '1',
        name: 'Arena Vôlei Central',
        address: 'Av. Paulista, 1000',
        latitude: -23.565,
        longitude: -46.652,
        isIndoor: true,
        courtCount: 4,
      ),
      VolleyballArena(
        id: '2',
        name: 'Praia Vôlei Club',
        address: 'Rua das Areias, 230',
        latitude: -23.571,
        longitude: -46.648,
        isIndoor: false,
        courtCount: 6,
      ),
      VolleyballArena(
        id: '3',
        name: 'Centro Esportivo Ibirapuera',
        address: 'Parque Ibirapuera, s/n',
        latitude: -23.587,
        longitude: -46.657,
        isIndoor: true,
        courtCount: 8,
      ),
    ];
  }

  Future<void> fetchAreasNearLocation(
      double location, double longitude, double radius) async {
    // Aqui seria feita uma requisição a uma API real
    // Por enquanto, vamos simular com dados estáticos

    // Em uma implementação real, você faria uma chamada HTTP para seu backend:
    // final response = await http.get(Uri.parse(
    //    'https://sua-api.com/volleyball-arenas?lat=$latitude&lng=$longitude&radius=$radius'
    // ));

    // Simulando um atraso de rede
    await Future.delayed(const Duration(seconds: 1));

    // Neste exemplo, estamos apenas mantendo os dados originais
    // Em um caso real, você processaria a resposta da API aqui
  }
}
