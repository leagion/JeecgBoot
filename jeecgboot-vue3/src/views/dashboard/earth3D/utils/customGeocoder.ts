import * as Cesium from 'cesium';

// 度分秒转度，保留3位小数
function dmsToDegreesFixed(d: string, m?: string, s?: string): number {
  const deg = parseFloat(d) + parseFloat(m || '0') / 60 + parseFloat(s || '0') / 3600;
  return Number(deg.toFixed(4));
}

// 支持多种格式的坐标解析
function parseCoordinate(input: string) {
  // 1. 度格式
  let match = input
    .trim()
    .replace(/[，、]/g, ',')
    .replace(/ +/g, ' ')
    .match(/^(-?\d+(\.\d+)?)[,\s]+(-?\d+(\.\d+)?)(?:[,\s]+(\d+(\.\d+)?))?$/);
  if (match) {
    const lon = parseFloat(match[1]);
    const lat = parseFloat(match[3]);
    const height = match[5] ? parseFloat(match[5]) : 30000;
    return { lon, lat, height };
  }
  // 2. 度分秒格式
  const dmsPattern =
    /(-?\d+)[°度d\s]*([\d\.]+)?[′'分\s]*([\d\.]+)?[″"秒\s]*[E|W|e|w]?[,，、\s]+(-?\d+)[°度d\s]*([\d\.]+)?[′'分\s]*([\d\.]+)?[″"秒\s]*[N|S|n|s]?/i;
  match = input.trim().match(dmsPattern);
  if (match) {
    const lon = dmsToDegreesFixed(match[1], match[2], match[3]);
    const lat = dmsToDegreesFixed(match[4], match[5], match[6]);
    return { lon, lat, height: 30000 };
  }
  return null;
}

// Cesium geocoder服务
export const customGeocoderService = {
  geocode: async (input: string) => {
    // 坐标解析
    const coord = parseCoordinate(input);
    if (coord) {
      return [
        {
          displayName: `坐标定位：${coord.lon},${coord.lat}`,
          destination: Cesium.Cartesian3.fromDegrees(coord.lon, coord.lat, coord.height),
        },
      ];
    }
    // 地名WFS查询
    const cql = `poi_name LIKE '%${input}%'`;
    const url = `http://localhost:8080/geoserver/aiccgmap/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=aiccgmap:lq_poi_static&outputFormat=application/json&CQL_FILTER=${encodeURIComponent(cql)}&maxFeatures=50`;
    const response = await fetch(url);
    const geojson = await response.json();
    return geojson.features.map((feature: any) => {
      const [lon, lat] = feature.geometry.coordinates;
      return {
        displayName: feature.properties.poi_name,
        destination: Cesium.Cartesian3.fromDegrees(lon, lat, 30000),
      };
    });
  },
};
