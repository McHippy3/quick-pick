import 'clothes.dart';

num convertToImperial(num metric) {
  num fahrenheit = metric * (9.0 / 5.0) + 32.0;
  //Rounding to two decimal places
  fahrenheit = (fahrenheit * 100).round() / 100.0;
  return fahrenheit;
}

num convertToMetric(num imperial) {
  num celcius = (imperial - 32) * (5.0 / 9.0);
  //Rounding to two decimal places
  celcius = (celcius * 100).round() / 100.0;
  return celcius;
}

//Parses JSON data from API call to retrieve only the needed parts
class Weather {
  final String city;
  final String description;
  num temperature;
  Temperatures tempZone;
  final String imageId;
  //0 for metric, 1 for imperial
  int unit;

  /* CONSTRUCTORS */

  Weather(
      {this.city,
      this.description,
      this.temperature,
      this.imageId,
      this.unit}) {
    //Setting temperature zone
    if (temperature > 20) {
      tempZone = Temperatures.hot;
    } else if (temperature > 10) {
      tempZone = Temperatures.warm;
    } else if (temperature > -5) {
      tempZone = Temperatures.cool;
    } else {
      tempZone = Temperatures.cold;
    }
  }

  factory Weather.fromJson(Map<String, dynamic> bodyContent, int unit) {
    //Gathering Description (requires extra step since it is contained within a list)
    List<dynamic> weatherList = new List<dynamic>.from(bodyContent['weather']);
    Map<String, dynamic> weatherSpecifics = weatherList[0];

    return Weather(
        city: bodyContent['name'],
        description: weatherSpecifics['main'],
        temperature: bodyContent['main']['temp'],
        imageId: weatherSpecifics['icon'],
        unit: unit);
  }

  /* METHODS */
  void convertUnits() {
    //Converting to imperial
    if (unit == 0) {
      temperature = convertToImperial(temperature);
      unit = 1;
    }
    //Converting to metric
    else {
      temperature = convertToMetric(temperature);
      unit = 0;
    }
  }
}
