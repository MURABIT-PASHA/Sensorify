class ConnectionSettings {
  final String hostAddress;
  final String clientAddress;
  final int portNumber;

  ConnectionSettings({
    required this.hostAddress,
    required this.clientAddress,
    required this.portNumber,
  });

  factory ConnectionSettings.fromJson(Map<String, dynamic> json) {
    return ConnectionSettings(
      hostAddress: json['hostAddress'],
      clientAddress: json['clientAddress'],
      portNumber: json['portNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostAddress': hostAddress,
      'clientAddress': clientAddress,
      'portNumber': portNumber,
    };
  }
}
