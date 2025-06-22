import * as Cesium from 'cesium';

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
  let s = Math.round((mFloat - m) * 60);

  // 如果输入本来就是整数分，且没有小数，秒应为0
  if (Math.abs(degree) === d + m / 60) {
    s = 0;
  }
  // 秒为60时，进位到分
  if (s === 60) {
    s = 0;
    // 这里可考虑进位到分，但通常不会出现
  }
  return `${d}°${m}′${s.toString().padStart(2, '0')}″`;
}

// 自动识别经纬度顺序的解析函数
function parseCoordinate(input: string) {
  input = input
    .trim()
    .replace(/[，、]/g, ',')
    .replace(/ +/g, ' ');

  // 1. 度分秒（3组数字）
  const dmsPattern = /^(-?\d+)[°度d\s]+(\d+)[′'分\s]+(\d+)[″"秒\s]*[,，、\s]+(-?\d+)[°度d\s]+(\d+)[′'分\s]+(\d+)[″"秒\s]*$/;
  let match = input.match(dmsPattern);
  if (match) {
    const lonParts = [match[1], match[2], match[3]];
    const latParts = [match[4], match[5], match[6]];
    const a = parseFloat(match[1]) + parseFloat(match[2]) / 60 + parseFloat(match[3]) / 3600;
    const b = parseFloat(match[4]) + parseFloat(match[5]) / 60 + parseFloat(match[6]) / 3600;
    let lon = a,
      lat = b;
    if (Math.abs(a) <= 90 && Math.abs(b) <= 180) {
      lat = a;
      lon = b;
    }
    return { lon, lat, height: 30000, format: 'dms', raw: input, lonParts, latParts };
  }

  // 2. 一组度分秒，一组度分（前面度分秒，后面度分）
  const mixPattern1 = /^(-?\d+)[°度d\s]+(\d+)[′'分\s]+(\d+)[″"秒\s]*[,，、\s]+(-?\d+)[°度d\s]+(\d+)[′'分\s]*$/;
  match = input.match(mixPattern1);
  if (match) {
    const lonParts = [match[1], match[2], match[3]];
    const latParts = [match[4], match[5], '0'];
    const a = parseFloat(match[1]) + parseFloat(match[2]) / 60 + parseFloat(match[3]) / 3600;
    const b = parseFloat(match[4]) + parseFloat(match[5]) / 60;
    let lon = a,
      lat = b;
    if (Math.abs(a) <= 90 && Math.abs(b) <= 180) {
      lat = a;
      lon = b;
    }
    return { lon, lat, height: 30000, format: 'dms', raw: input, lonParts, latParts };
  }

  // 3. 一组度分，一组度分秒（前面度分，后面度分秒）
  const mixPattern2 = /^(-?\d+)[°度d\s]+(\d+)[′'分\s]*[,，、\s]+(-?\d+)[°度d\s]+(\d+)[′'分\s]+(\d+)[″"秒\s]*$/;
  match = input.match(mixPattern2);
  if (match) {
    const lonParts = [match[1], match[2], '0'];
    const latParts = [match[3], match[4], match[5]];
    const a = parseFloat(match[1]) + parseFloat(match[2]) / 60;
    const b = parseFloat(match[3]) + parseFloat(match[4]) / 60 + parseFloat(match[5]) / 3600;
    let lon = a,
      lat = b;
    if (Math.abs(a) <= 90 && Math.abs(b) <= 180) {
      lat = a;
      lon = b;
    }
    return { lon, lat, height: 30000, format: 'dms', raw: input, lonParts, latParts };
  }

  // 2. 度分格式（有 °、′ 或 度/分/空格分隔2组数字）
  // 2. 度分格式（分可以为小数）
  const dmPattern = /^(-?\d+)[°度d\s]+([\d\.]+)[′'分\s]*[,，、\s]+(-?\d+)[°度d\s]+([\d\.]+)[′'分\s]*$/;
  match = input.match(dmPattern);
  if (match) {
    // 112 23.22,23 33.22 或 112°23.22′ 23°33.22′
    const lonParts = [match[1], match[2]];
    const latParts = [match[3], match[4]];
    const a = parseFloat(match[1]) + parseFloat(match[2]) / 60;
    const b = parseFloat(match[3]) + parseFloat(match[4]) / 60;
    let lon = a,
      lat = b;
    if (Math.abs(a) <= 90 && Math.abs(b) <= 180) {
      lat = a;
      lon = b;
    }
    return { lon, lat, height: 30000, format: 'dm', raw: input, lonParts, latParts };
  }

  // 3. 纯小数度格式（只允许小数或整数，空格或逗号分隔）
  const degreePattern = /^(-?\d+(\.\d+)?)[,，、\s]+(-?\d+(\.\d+)?)/;
  match = input.match(degreePattern);
  if (match) {
    // 112.23 23.22
    let lon = parseFloat(match[1]);
    let lat = parseFloat(match[3]);
    if (Math.abs(lon) <= 90 && Math.abs(lat) <= 180) {
      [lat, lon] = [lon, lat];
    }
    return { lon, lat, height: 30000, format: 'degree', raw: input };
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
        displayName = `坐标定位：${coord.lon.toFixed(3) + '°'},${coord.lat.toFixed(3) + '°'}`;
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
        displayName: feature.properties.poi_name || '地名',
        destination: Cesium.Cartesian3.fromDegrees(lon, lat, 30000),
        lon,
        lat,
        height: 30000,
        isWFS: true,
      };
    });
  },
};
