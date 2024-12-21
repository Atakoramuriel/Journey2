class AutocompletePrediction {
  final String placeId;
  final String description;

  AutocompletePrediction({
    required this.placeId,
    required this.description,
  });

  factory AutocompletePrediction.fromJson(Map<String, dynamic> json) {
    return AutocompletePrediction(
      placeId: json['place_id'],
      description: json['description'],
    );
  }
}