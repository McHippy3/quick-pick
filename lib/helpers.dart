//Used for passing primitives by reference
class PrimitiveWrapper {
  var primitive;

  PrimitiveWrapper(this.primitive);
}

String getFormattedTemp(int unit, double temp) {
  //Metric
  if (unit == 0) {
    return "$temp \u00B0C";
  }
  //Imperial
  else
    return "$temp \u00B0F";
}
