import * as Cesium from 'cesium';

/**
 * 地图配置接口
 */
export interface MapConfig {
  // 影像图服务配置
  imageServer: {
    ip: string;
    port: number;
  };

  // 线划图服务配置
  lineServer: {
    ip: string;
    port: number;
  };

  // GeoServer WMS配置
  geoServer: {
    ip: string;
    port: number;
    layers: string;
  };

  // 默认底图配置 (底图名称或索引)
  defaultBaseMap: string | number;
}

/**
 * 从config.json加载地图配置
 */
export async function loadMapConfig(): Promise<MapConfig> {
  // 默认配置
  const defaultConfig: MapConfig = {
    imageServer: {
      ip: '0.0.0.0',
      port: 5160,
    },
    lineServer: {
      ip: '0.0.0.0',
      port: 5160,
    },
    geoServer: {
      ip: 'localhost',
      port: 8080,
      layers: 'ne:coastlines',
    },
    defaultBaseMap: 0, // 默认使用第一个底图
  };

  try {
    const resp = await fetch('/config.json');
    const config = await resp.json();

    // 合并配置
    if (config.mapConfig) {
      const mapConfig = config.mapConfig;
      return {
        imageServer: {
          ip: mapConfig.imageServer?.ip || defaultConfig.imageServer.ip,
          port: mapConfig.imageServer?.port || defaultConfig.imageServer.port,
        },
        lineServer: {
          ip: mapConfig.lineServer?.ip || defaultConfig.lineServer.ip,
          port: mapConfig.lineServer?.port || defaultConfig.lineServer.port,
        },
        geoServer: {
          ip: mapConfig.geoServer?.ip || defaultConfig.geoServer.ip,
          port: mapConfig.geoServer?.port || defaultConfig.geoServer.port,
          layers: mapConfig.geoServer?.layers || defaultConfig.geoServer.layers,
        },
        defaultBaseMap: mapConfig.defaultBaseMap !== undefined ? mapConfig.defaultBaseMap : defaultConfig.defaultBaseMap,
      };
    }
  } catch (e) {
    console.warn('读取 config.json 获取地图配置失败，使用默认配置');
  }

  return defaultConfig;
}

/**
 * 创建所有地图提供者
 */
export function createMapProviders(config: MapConfig): {
  imageryViewModels: Cesium.ProviderViewModel[];
  defaultIndex: number;
} {
  // 构建服务地址
  const imageBaseUrl = `http://${config.imageServer.ip}:${config.imageServer.port}`;
  const lineBaseUrl = `http://${config.lineServer.ip}:${config.lineServer.port}`;
  const geoServerBaseUrl = `http://${config.geoServer.ip}:${config.geoServer.port}`;

  // 1. 获取 Cesium 自带的底图，并只保留我们需要的地图
  const defaultImageryViewModels = Cesium.createDefaultImageryProviderViewModels();

  // 查找 Natural Earth II 底图（考虑可能的名称变化）
  let naturalEarthViewModel = defaultImageryViewModels.find((model) => model.name && model.name.includes('Natural Earth'));

  // 如果找不到 Cesium 自带的 Natural Earth II，使用我们的自定义实现
  if (!naturalEarthViewModel) {
    naturalEarthViewModel = new Cesium.ProviderViewModel({
      name: 'Natural Earth II',
      iconUrl: Cesium.buildModuleUrl('Widgets/Images/ImageryProviders/naturalEarthII.png'),
      tooltip: 'Natural Earth II',
      creationFunction: function () {
        return new Cesium.TileMapServiceImageryProvider({
          url: Cesium.buildModuleUrl('Assets/Textures/NaturalEarthII'),
        });
      },
    });
  }

  // 2. GeoServer WMS 底图
  const wmsMap = new Cesium.ProviderViewModel({
    name: '我的地图',
    iconUrl: Cesium.buildModuleUrl('Widgets/Images/ImageryProviders/ArcGisMapServiceWorldImagery.png'),
    tooltip: '自定义WMS 底图',
    creationFunction: function () {
      return new Cesium.WebMapServiceImageryProvider({
        url: `${geoServerBaseUrl}/geoserver/aiccgmap/wms`,
        layers: config.geoServer.layers,
        parameters: {
          service: 'WMS',
          format: 'image/png',
          transparent: true,
          version: '1.1.1',
        },
      });
    },
  });

  // 3. 影像图服务（gr）
  // 3.1 影像图 RESTful 方式
  const imageRestful = new Cesium.ProviderViewModel({
    name: '影像图',
    iconUrl: Cesium.buildModuleUrl('Widgets/Images/ImageryProviders/bingAerial.png'),
    tooltip: '无标注影像图',
    creationFunction: function () {
      return new Cesium.UrlTemplateImageryProvider({
        url: `${imageBaseUrl}/v1.0/gr/{z}/{x}/{y}.jpg`,
        tilingScheme: new Cesium.WebMercatorTilingScheme(),
        minimumLevel: 0,
        maximumLevel: 21,
      });
    },
  });

  // 3. 影像图服务（gr）
  // 3.1 影像图 RESTful 方式
  const imageLabelRestful = new Cesium.ProviderViewModel({
    name: '标注影像',
    iconUrl: Cesium.buildModuleUrl('Widgets/Images/ImageryProviders/bingAerialLabels.png'),
    tooltip: '全球影像图带标注',
    creationFunction: function () {
      return new Cesium.UrlTemplateImageryProvider({
        url: `${imageBaseUrl}/v1.0/gh/{z}/{x}/{y}.jpg`,
        tilingScheme: new Cesium.WebMercatorTilingScheme(),
        minimumLevel: 0,
        maximumLevel: 21,
      });
    },
  });
  // // 3.3 影像图 WMTS 方式
  // const imageWmts = new Cesium.ProviderViewModel({
  //   name: '影像图-WMTS',
  //   iconUrl: Cesium.buildModuleUrl('Widgets/Images/ImageryProviders/bingAerial.png'),
  //   tooltip: '影像图 - WMTS 方式调用',
  //   creationFunction: function () {
  //     return new Cesium.WebMapTileServiceImageryProvider({
  //       url: `${imageBaseUrl}/wmts/gr/1.0.0/WMTSCapabilities.xml`,
  //       layer: 'gr',
  //       style: 'default',
  //       format: 'image/jpeg',
  //       tileMatrixSetID: 'GoogleMapsCompatible',
  //     });
  //   },
  // });

  // 4. 线划图服务（gm）
  // 4.1 线划图 RESTful 方式
  const lineRestful = new Cesium.ProviderViewModel({
    name: '全球线划图',
    iconUrl: Cesium.buildModuleUrl('Widgets/Images/ImageryProviders/bingRoads.png'),
    tooltip: '线划图 - RESTful 方式调用',
    creationFunction: function () {
      return new Cesium.UrlTemplateImageryProvider({
        url: `${lineBaseUrl}/v1.0/gm/{z}/{x}/{y}.png`,
        tilingScheme: new Cesium.WebMercatorTilingScheme(),
        minimumLevel: 0,
        maximumLevel: 21,
        transparent: true,
      });
    },
  });

  // 4. 线划图服务（gm）
  // 4.1 线划图 RESTful 方式
  const lineDEMRestful = new Cesium.ProviderViewModel({
    name: '地势晕渲图',
    iconUrl: Cesium.buildModuleUrl('Widgets/Images/ImageryProviders/bingRoads.png'),
    tooltip: '全球地势晕渲图',
    creationFunction: function () {
      return new Cesium.UrlTemplateImageryProvider({
        url: `${lineBaseUrl}/v1.0/gt/{z}/{x}/{y}.png`,
        tilingScheme: new Cesium.WebMercatorTilingScheme(),
        minimumLevel: 0,
        maximumLevel: 21,
        transparent: true,
      });
    },
  });
  // // 4.2 线划图 TileJSON 方式
  // const lineTileJson = new Cesium.ProviderViewModel({
  //   name: '线划图-TileJSON',
  //   iconUrl: Cesium.buildModuleUrl('Widgets/Images/ImageryProviders/stamenWatercolor.png'),
  //   tooltip: '线划图 - TileJSON 方式调用',
  //   creationFunction: function () {
  //     // TileJSON 方式需要通过异步加载配置，这里使用自定义实现
  //     const provider = new Cesium.UrlTemplateImageryProvider({
  //       url: '', // 空URL，在请求时动态设置
  //       tilingScheme: new Cesium.WebMercatorTilingScheme(),
  //       minimumLevel: 0,
  //       maximumLevel: 20,
  //       transparent: true,
  //     });

  //     // 重写 requestImage 方法以确保正确加载
  //     provider.requestImage = function (x, y, level, request) {
  //       const url = `${lineBaseUrl}/v1.0/gm/${level}/${x}/${y}.png`;
  //       const image = new Image();
  //       if (request) {
  //         image.crossOrigin = request.crossOrigin;
  //       }
  //       image.src = url;
  //       return image;
  //     };

  //     return provider;
  //   },
  // });

  // // 4.3 线划图 WMTS 方式
  // const lineWmts = new Cesium.ProviderViewModel({
  //   name: '线划图-WMTS',
  //   iconUrl: Cesium.buildModuleUrl('Widgets/Images/ImageryProviders/mapboxStreets.png'),
  //   tooltip: '线划图 - WMTS 方式调用',
  //   creationFunction: function () {
  //     return new Cesium.WebMapTileServiceImageryProvider({
  //       url: `${lineBaseUrl}/wmts/gm/1.0.0/WMTSCapabilities.xml`,
  //       layer: 'gm',
  //       style: 'default',
  //       format: 'image/png',
  //       tileMatrixSetID: 'GoogleMapsCompatible',
  //     });
  //   },
  // });

  // 底图列表 - 包含所有地图选项
  // 将Natural Earth移到GeoServer WMS前面并排放置
  //const imageryViewModels = [naturalEarthViewModel, wmsMap, imageRestful, imageWmts, lineRestful, lineTileJson, lineWmts];
  const imageryViewModels = [naturalEarthViewModel, wmsMap, imageRestful,imageLabelRestful, lineRestful,lineDEMRestful];

  // 确定默认底图索引
  // 默认使用GeoServer WMS作为第二个选项（索引1）
  let defaultIndex = 1;

  // 检查配置的defaultBaseMap是否有效
  if (typeof config.defaultBaseMap === 'number') {
    // 确保索引在有效范围内
    defaultIndex = Math.max(0, Math.min(config.defaultBaseMap, imageryViewModels.length - 1));
  } else if (typeof config.defaultBaseMap === 'string') {
    // 如果是字符串，则通过名称查找索引
    const index = imageryViewModels.findIndex((model) => model.name === config.defaultBaseMap);
    if (index >= 0) {
      defaultIndex = index;
    }
  }

  return {
    imageryViewModels,
    defaultIndex,
  };
}
