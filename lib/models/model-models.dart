/// A model representing a data object with an ID, creation time, and root.
class ModelsModel {
  /// The unique identifier of the model.
  final String id;

  /// The creation timestamp of the model.
  final int created;

  /// The root or base path associated with the model.
  final String root;

  /// Constructor for creating a `ModelsModel` instance.
  ModelsModel({
    required this.id,
    required this.created,
    required this.root,
  });

  /// Factory constructor for creating an instance from a JSON object.
  factory ModelsModel.fromJson(Map<String, dynamic> json) {
    return ModelsModel(
      id: json['id'] ?? '',  // Provide default value if necessary
      created: json['created'] ?? 0,
      root: json['root'] ?? '',
    );
  }

  /// Converts a list of JSON objects into a list of `ModelsModel` instances.
  static List<ModelsModel> modelsFromApi(List<dynamic> modelApi) {
    return modelApi.map((data) => ModelsModel.fromJson(data)).toList();
  }
}
