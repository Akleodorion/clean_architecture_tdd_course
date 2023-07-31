import 'package:clean_architecture_tdd_course/core/network/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([InternetConnectionChecker])
import 'network_info_test.mocks.dart';

void main() {
  late MockInternetConnectionChecker mockInternetConnectionChecker;
  late NetworkInfoImpl networkInfoImpl;

  setUp(() {
    mockInternetConnectionChecker = MockInternetConnectionChecker();
    networkInfoImpl = NetworkInfoImpl(mockInternetConnectionChecker);
  });

  test(
    "should return the status of the connection state",
    () async {
      //assert
      when(mockInternetConnectionChecker.hasConnection)
          .thenAnswer((_) async => true);
      //act
      final result = await networkInfoImpl.isConnected;
      //arrange
      verify(networkInfoImpl.isConnected).called(1);
      expect(result, true);
    },
  );
}
