import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app_firebase/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('deve criar um UserModel corretamente', () {
      final user = UserModel(
        uid: 'user123',
        email: 'teste@example.com',
        displayName: 'João Silva',
      );

      expect(user.uid, 'user123');
      expect(user.email, 'teste@example.com');
      expect(user.displayName, 'João Silva');
    });

    test('deve converter para Map corretamente', () {
      final user = UserModel(
        uid: 'user123',
        email: 'teste@example.com',
        displayName: 'João Silva',
      );

      final map = user.toMap();

      expect(map['uid'], 'user123');
      expect(map['email'], 'teste@example.com');
      expect(map['displayName'], 'João Silva');
    });

    test('deve criar UserModel a partir de Map', () {
      final map = {
        'uid': 'user123',
        'email': 'teste@example.com',
        'displayName': 'João Silva',
      };

      final user = UserModel.fromMap(map);

      expect(user.uid, 'user123');
      expect(user.email, 'teste@example.com');
      expect(user.displayName, 'João Silva');
    });

    test('deve preservar dados após conversão Map -> Model -> Map', () {
      final originalMap = {
        'uid': 'abc123',
        'email': 'joao@example.com',
        'displayName': 'João da Silva',
      };

      final user = UserModel.fromMap(originalMap);
      final convertedMap = user.toMap();

      expect(convertedMap['uid'], originalMap['uid']);
      expect(convertedMap['email'], originalMap['email']);
      expect(convertedMap['displayName'], originalMap['displayName']);
    });

    test('deve usar email como displayName quando displayName está vazio', () {
      final map = {
        'uid': 'user123',
        'email': 'teste@example.com',
        'displayName': '',
      };

      final user = UserModel.fromMap(map);

      expect(user.displayName, 'teste@example.com');
    });

    test('deve usar "Usuário" quando email e displayName estão vazios', () {
      final map = {
        'uid': 'user123',
        'email': '',
        'displayName': '',
      };

      final user = UserModel.fromMap(map);

      expect(user.displayName, 'Usuário');
    });

    test('deve validar email vazio', () {
      expect(
        () => UserModel(
          uid: 'user123',
          email: '',
          displayName: 'João',
        ),
        returnsNormally,
      );
    });

    test('deve validar displayName vazio', () {
      expect(
        () => UserModel(
          uid: 'user123',
          email: 'teste@example.com',
          displayName: '',
        ),
        returnsNormally,
      );
    });
  });
}
