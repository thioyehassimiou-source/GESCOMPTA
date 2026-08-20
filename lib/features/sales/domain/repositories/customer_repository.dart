/// Persistance minimale des clients, nécessaire aux ventes à crédit.
abstract interface class CustomerRepository {
  /// Récupère un client existant par son nom (insensible à la casse) ou en crée un nouveau s'il n'existe pas.
  /// Retourne l'identifiant du client.
  Future<String> getOrCreate(String name, {String? phone});
}
