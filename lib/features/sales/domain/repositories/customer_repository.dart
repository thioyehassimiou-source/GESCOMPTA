/// Persistance minimale des clients, nécessaire aux ventes à crédit.
abstract interface class CustomerRepository {
  /// Crée un client à partir de son nom et retourne son identifiant.
  Future<String> create(String name);
}
