
enum SensorType{
  accelerometer,
  gyroscope,
  magnetometer,
}
enum DurationType{
  ms,
  s,
}
enum MessageOrderType{
  start, //Kayıt başlatan emirdir
  stop, //Varsa kayıt durduran emirdir
  record, //Kayıt gönderen emirdir
}