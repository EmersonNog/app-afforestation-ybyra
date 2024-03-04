// ignore_for_file: depend_on_referenced_packages

import 'package:xml/xml.dart' as xml; 
import '../utils/point_info.dart';

class KMLStructure {
  static String generateKML(List<PointInfo> points) {
    final kml = xml.XmlBuilder();
    kml.processing('xml', 'version="1.0" encoding="UTF-8"');
    kml.element('kml', nest: () {
      kml.attribute('xmlns', 'http://www.opengis.net/kml/2.2');
      kml.element('Document', nest: () {
        for (var pointInfo in points) {
          kml.element('Placemark', nest: () {
            kml.element('name', nest: pointInfo.name);
            kml.element('Point', nest: () {
              kml.element('coordinates',
                  nest:
                      '${pointInfo.coordinates.longitude},${pointInfo.coordinates.latitude},0');
            });
          });
        }
      });
    });

    return kml.buildDocument().toXmlString(pretty: true);
  }
}
