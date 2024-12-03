import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:leafy_house/domain/entities/plant.dart';
import 'package:leafy_house/domain/usecases/fetch_plants.dart';
import 'package:leafy_house/domain/usecases/add_plant.dart';
import 'package:leafy_house/domain/usecases/delete_plant.dart';
import 'package:leafy_house/domain/usecases/update_plant.dart';
import 'package:leafy_house/presentation/view_models/plants_notifier.dart';

// Mock sınıflarını oluşturun
@GenerateMocks([
  FetchPlants,
  AddPlant,
  DeletePlant,
  UpdatePlant,
])
import 'plants_notifier_test.mocks.dart';

void main() {
  late PlantsNotifier notifier;
  late MockFetchPlants mockFetchPlants;
  late MockAddPlant mockAddPlant;
  late MockDeletePlant mockDeletePlant;
  late MockUpdatePlant mockUpdatePlant;

  setUp(() {
    mockFetchPlants = MockFetchPlants();
    mockAddPlant = MockAddPlant();
    mockDeletePlant = MockDeletePlant();
    mockUpdatePlant = MockUpdatePlant();

    notifier = PlantsNotifier(
      fetchPlants: mockFetchPlants,
      addPlant: mockAddPlant,
      deletePlant: mockDeletePlant,
      updatePlant: mockUpdatePlant,
    );
  });

  test('loadPlants updates state with list of plants', () async {
    // Arrange
    final mockPlants = [
      Plant(
        id: '1',
        userId: 'userId',
        name: 'Plant 1',
        type: 'Type 1',
        moisture: 50,
        health: 'Healthy',
        imageUrl: 'url1',
      ),
    ];

    when(mockFetchPlants.call(any))
        .thenAnswer((_) async => mockPlants);

    // Act
    await notifier.loadPlants('userId');

    // Assert
    expect(notifier.state.plants, equals(mockPlants));
    expect(notifier.state.isLoading, false);
    verify(mockFetchPlants.call('userId')).called(1);
  });
}
