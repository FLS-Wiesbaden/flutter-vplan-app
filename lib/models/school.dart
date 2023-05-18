class School {
  static const apiPath = "geco";

  final String id;
  final String name;
  final String assetName;
  final String endpoint;
  final String authEndpoint;

  School(this.id, this.name, this.assetName, this.endpoint, this.authEndpoint);

  String get apiEndpoint {
    return "$endpoint${apiPath.startsWith("/") ? "" : "/"}$apiPath";
  }
  
}