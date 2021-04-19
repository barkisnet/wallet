
String formatShortAddress(String address, [int prefixLength = 8, int postFixLength = 6, int separatorLength = 3]) {
  if(address.isEmpty){
    return "";
  }
  var prefix = address.substring(0, prefixLength);
  var postfix = address.substring(address.length - postFixLength, address.length);
  var sb = new StringBuffer()
    ..write(prefix)
    ..write("." * separatorLength)
    ..write(postfix);
  return sb.toString();
}
