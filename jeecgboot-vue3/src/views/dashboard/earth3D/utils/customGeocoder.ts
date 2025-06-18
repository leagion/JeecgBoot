import * as Cesium from 'cesium';

// 度分秒转度，保留3位小数
function dmsToDegreesFixed(d: string, m?: string, s?: string): number {
  const deg = parseFloat(d) || 0;
  const min = parseFloat(m || '0') || 0;
  const sec = parseFloat(s || '0') || 0;
  const sign = deg < 0 ? -1 : 1;
  const result = sign * (Math.abs(deg) + min / 60 + sec / 3600);
  return parseFloat(result.toFixed(4)); // 保留6位小数，更精确
}

// 格式化为度分
function formatDM(degree: number, _isLon: boolean) {
  const d = Math.floor(Math.abs(degree));
  const m = ((Math.abs(degree) - d) * 60).toFixed(3);
  return `${d}°${m}′`;
}

// 格式化为度分秒
function formatDMS(degree: number, _isLon: boolean) {
  const d = Math.floor(Math.abs(degree));
  const mFloat = (Math.abs(degree) - d) * 60;
  const m = Math.floor(mFloat);
  const s = ((mFloat - m) * 60).toFixed(2);
  return `${d}°${m}′${s}″`;
}

// 自动识别经纬度顺序的解析函数
function parseCoordinate(input: string) {
  // 1. 纯度格式 119.123 38.456 或 119.123,38.456
  let match = input
    .trim()
    .replace(/[，、]/g, ',')
    .replace(/ +/g, ' ')
    .match(/^(-?\d+(\.\d+)?)[,\s]+(-?\d+(\.\d+)?)(?:[,\s]+(\d+(\.\d+)?))?$/);
  if (match) {
    let a = parseFloat(match[1]);
    let b = parseFloat(match[3]);
    let height = match[5] ? parseFloat(match[5]) : 30000;
    let lon = a,
      lat = b;
    // 自动识别经纬度顺序
    if (Math.abs(a) <= 90 && Math.abs(b) <= 180) {
      lat = a;
      lon = b;
    }
    return { lon, lat, height, format: 'degree', raw: input };
  }

  // 2. 度分格式（支持汉字和符号，分隔符可为逗号、顿号、空格）
  match = input
    .trim()
    .replace(/[，、]/g, ',')
    .replace(/ +/g, ' ')
    .match(/^(-?\d+)[°度d\s]*([\d\.]+)[′'分\s]*[,，、\s]+(-?\d+)[°度d\s]*([\d\.]+)[′'分\s]*$/);
  if (match) {
    let a = parseFloat(match[1]) + parseFloat(match[2]) / 60;
    let b = parseFloat(match[3]) + parseFloat(match[4]) / 60;
    let lon = a,
      lat = b;
    if (Math.abs(a) <= 90 && Math.abs(b) <= 180) {
      lat = a;
      lon = b;
    }
    return { lon, lat, height: 30000, format: 'dm', raw: input };
  }

  // 3. 度分秒格式（支持汉字和符号，秒可省略）
  const dmsPattern = /(-?\d+)[°度d\s]*([\d\.]+)?[′'分\s]*([\d\.]+)?[″"秒\s]*[,，、\s]+(-?\d+)[°度d\s]*([\d\.]+)?[′'分\s]*([\d\.]+)?[″"秒\s]*/;
  match = input.trim().match(dmsPattern);
  if (match) {
    let a = dmsToDegreesFixed(match[1], match[2], match[3]);
    let b = dmsToDegreesFixed(match[4], match[5], match[6]);
    let lon = a,
      lat = b;
    if (Math.abs(a) <= 90 && Math.abs(b) <= 180) {
      lat = a;
      lon = b;
    }
    return { lon, lat, height: 30000, format: 'dms', raw: input };
  }
  return null;
}
// Cesium geocoder服务
export const customGeocoderService = {
  geocode: async (input: string) => {
    const coord = parseCoordinate(input);
    if (coord) {
      let displayName = '';
      if (coord.format === 'degree') {
        displayName = `坐标定位：${coord.lon.toFixed(3)},${coord.lat.toFixed(3)}`;
      } else if (coord.format === 'dm') {
        displayName = `坐标定位：${formatDM(coord.lon, true)} ${formatDM(coord.lat, false)}`;
      } else if (coord.format === 'dms') {
        displayName = `坐标定位：${formatDMS(coord.lon, true)} ${formatDMS(coord.lat, false)}`;
      } else {
        displayName = `坐标定位：${coord.lon},${coord.lat}`;
      }
      return [
        {
          displayName,
          destination: Cesium.Cartesian3.fromDegrees(coord.lon, coord.lat, coord.height),
          lon: coord.lon,
          lat: coord.lat,
          height: coord.height,
        },
      ];
    }
    // 地名WFS查询，动态读取 config.json
    const configResp = await fetch('/config.json');
    const { wfs } = await configResp.json();
    const cql = `poi_name LIKE '%${input}%'`;
    const url = `${wfs.url}?service=WFS&version=1.0.0&request=GetFeature&typeName=${wfs.layer}&outputFormat=application/json&CQL_FILTER=${encodeURIComponent(cql)}&maxFeatures=50`;
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
