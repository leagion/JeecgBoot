/**
 * 叠加图层管理器
 * 负责加载、管理和控制可叠加到基础地图上的图层
 */
import * as Cesium from 'cesium';

/**
 * 叠加图层配置接口
 */
export interface OverlayLayerConfig {
  id: string;
  name: string;
  url: string;
  layers: string;
  parameters?: Record<string, any>;
  alpha?: number;
  visible?: boolean;
  order?: number; // 排序顺序
  bbox?: {
    west: number;
    south: number;
    east: number;
    north: number;
  };
}

/**
 * 叠加图层管理器类
 */
export class OverlayLayerManager {
  private viewer: Cesium.Viewer;
  private layers: Map<string, { config: OverlayLayerConfig; cesiumLayer: Cesium.ImageryLayer }>;
  private controlPanel: HTMLElement | null = null;

  constructor(viewer: Cesium.Viewer) {
    this.viewer = viewer;
    this.layers = new Map();
  }

  /**
   * 从配置加载叠加图层
   */
  public async loadOverlayLayers(configs: OverlayLayerConfig[]): Promise<void> {
    // 确保控制面板已创建
    this.createControlPanel();

    // 加载每个图层
    for (const config of configs) {
      await this.addOverlayLayer(config);
    }
  }

  /**
   * 添加单个叠加图层
   */
  public async addOverlayLayer(config: OverlayLayerConfig): Promise<Cesium.ImageryLayer | null> {
    try {
      // 构建参数
      const parameters = {
        transparent: true,
        format: 'image/png',
        ...config.parameters,
      };

      // 创建 WMS 提供者
      const imageryProvider = new Cesium.WebMapServiceImageryProvider({
        url: config.url,
        layers: config.layers,
        parameters,
        rectangle: config.bbox
          ? new Cesium.Rectangle(
              Cesium.Math.toRadians(config.bbox.west),
              Cesium.Math.toRadians(config.bbox.south),
              Cesium.Math.toRadians(config.bbox.east),
              Cesium.Math.toRadians(config.bbox.north)
            )
          : undefined,
      });

      // 创建 Cesium 图层
      const cesiumLayer = new Cesium.ImageryLayer(imageryProvider, {
        alpha: config.alpha ?? 1.0,
        show: config.visible ?? true,
      });

      // 添加到 viewer
      this.viewer.imageryLayers.add(cesiumLayer);

      // 存储图层信息
      this.layers.set(config.id, { config, cesiumLayer });

      // 添加到控制面板
      this.addLayerToControlPanel(config);

      return cesiumLayer;
    } catch (error) {
      console.error(`添加叠加图层 ${config.name} 失败:`, error);
      return null;
    }
  }

  /**
   * 从外部配置文件加载叠加图层
   * @param configUrl 配置文件URL
   */
  public async loadOverlayLayersFromExternal(configUrl: string): Promise<void> {
    try {
      // 确保控制面板已创建
      this.createControlPanel();

      // 加载外部配置文件
      const response = await fetch(configUrl);
      if (!response.ok) {
        throw new Error(`加载配置文件失败: ${response.status}`);
      }

      // 解析配置文件
      const configData = await response.json();
      let layersConfig = [];

      // 兼容不同格式的配置文件
      if (Array.isArray(configData)) {
        layersConfig = configData;
      } else if (configData.overlayLayers && Array.isArray(configData.overlayLayers)) {
        layersConfig = configData.overlayLayers;
      } else if (configData.layers && Array.isArray(configData.layers)) {
        layersConfig = configData.layers;
      }

      // 根据order字段排序图层
      layersConfig.sort((a, b) => {
        const orderA = a.order ?? Number.MAX_SAFE_INTEGER;
        const orderB = b.order ?? Number.MAX_SAFE_INTEGER;
        return orderA - orderB;
      });

      // 加载所有图层
      for (const config of layersConfig) {
        await this.addOverlayLayer(config);
      }
    } catch (error) {
      console.error('从外部配置文件加载叠加图层失败:', error);
    }
  }

  /**
   * 移除叠加图层
   */
  public removeOverlayLayer(layerId: string): boolean {
    const layerInfo = this.layers.get(layerId);
    if (layerInfo) {
      this.viewer.imageryLayers.remove(layerInfo.cesiumLayer);
      this.layers.delete(layerId);

      // 从控制面板移除
      const layerElement = document.getElementById(`overlay-layer-${layerId}`);
      if (layerElement && layerElement.parentElement) {
        layerElement.parentElement.removeChild(layerElement);
      }

      return true;
    }
    return false;
  }

  /**
   * 销毁叠加图层管理器
   */
  public destroy(): void {
    // 清理所有图层
    for (const layerId of this.layers.keys()) {
      this.removeOverlayLayer(layerId);
    }

    // 移除控制面板
    if (this.controlPanel && this.controlPanel.parentElement) {
      this.controlPanel.parentElement.removeChild(this.controlPanel);
      this.controlPanel = null;
      this.contentElement = null;
    }

    // 清理事件监听器
    window.removeEventListener('mousemove', this.onDragging.bind(this));
    window.removeEventListener('mouseup', this.onDragEnd.bind(this));
    window.removeEventListener('touchmove', this.onDragging.bind(this));
    window.removeEventListener('touchend', this.onDragEnd.bind(this));

    // 清空图层映射
    this.layers.clear();
  }

  /**
   * 显示/隐藏叠加图层
   */
  public toggleOverlayLayer(layerId: string, visible?: boolean): void {
    const layerInfo = this.layers.get(layerId);
    if (layerInfo) {
      layerInfo.cesiumLayer.show = visible ?? !layerInfo.cesiumLayer.show;
    }
  }

  /**
   * 设置叠加图层透明度
   */
  public setLayerAlpha(layerId: string, alpha: number): void {
    const layerInfo = this.layers.get(layerId);
    if (layerInfo) {
      // 确保 alpha 值在 0-1 之间
      alpha = Math.max(0, Math.min(1, alpha));
      layerInfo.cesiumLayer.alpha = alpha;
    }
  }

  private isCollapsed = true; // 默认折叠状态
  private dragOffset = { x: 0, y: 0 };
  private isDragging = false;
  private contentElement: HTMLElement | null = null;

  /**
   * 创建图层控制面板
   */
  private createControlPanel(): void {
    if (this.controlPanel) {
      return;
    }

    // 创建控制面板容器
    this.controlPanel = document.createElement('div');
    this.controlPanel.className = 'overlay-layer-control-panel';
    this.controlPanel.style.position = 'absolute';
    this.controlPanel.style.bottom = '100px'; // 固定底部位置
    this.controlPanel.style.left = '20px';
    this.controlPanel.style.width = '240px';
    this.controlPanel.style.zIndex = '1011'; // 提高z-index确保始终在状态栏之上
    this.controlPanel.style.userSelect = 'none';
    this.controlPanel.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.15)';
    this.controlPanel.style.backgroundColor = 'rgba(255, 255, 255, 0.6)';
    this.controlPanel.style.backdropFilter = 'blur(10px)';
    this.controlPanel.style.border = '1px solid rgba(255, 255, 255, 0.2)';
    this.controlPanel.style.borderRadius = '8px';
    this.controlPanel.style.display = 'flex';
    this.controlPanel.style.flexDirection = 'column';
    this.controlPanel.style.height = 'auto';

    // 创建内容区域
    this.contentElement = document.createElement('div');
    this.contentElement.className = 'overlay-layer-content';
    this.contentElement.style.padding = '10px';
    this.contentElement.style.maxHeight = '400px';
    this.contentElement.style.overflowY = 'auto';
    this.contentElement.style.backgroundColor = 'rgba(255, 255, 255, 0.6)';
    this.contentElement.style.borderTopLeftRadius = '8px';
    this.contentElement.style.borderTopRightRadius = '8px';
    this.contentElement.style.borderBottom = '1px solid rgba(0, 0, 0, 0.1)';
    this.controlPanel.appendChild(this.contentElement);

    // 创建标题栏（固定在底部）
    const titleBar = document.createElement('div');
    titleBar.className = 'overlay-layer-title-bar';
    titleBar.style.display = 'flex';
    titleBar.style.alignItems = 'center';
    titleBar.style.justifyContent = 'space-between';
    titleBar.style.padding = '8px 12px';
    titleBar.style.cursor = 'move';
    titleBar.style.borderBottomLeftRadius = '8px';
    titleBar.style.borderBottomRightRadius = '8px';
    titleBar.style.position = 'relative';
    titleBar.style.zIndex = '10'; // 确保标题栏始终在最上层
    this.controlPanel.appendChild(titleBar);

    // 添加标题
    const title = document.createElement('h4');
    title.textContent = '图层管理';
    title.style.margin = '0';
    title.style.fontSize = '14px';
    title.style.color = '#333';
    titleBar.appendChild(title);

    // 添加折叠按钮（固定在底部）
    const collapseBtn = document.createElement('div');
    collapseBtn.className = 'overlay-layer-collapse-btn';
    collapseBtn.style.cursor = 'pointer';
    collapseBtn.style.padding = '4px';
    collapseBtn.style.color = '#333';
    collapseBtn.innerHTML = '▲'; // 默认向上箭头，表示可以向上展开
    collapseBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      this.toggleCollapse();
    });
    titleBar.appendChild(collapseBtn);

    // 添加拖拽事件
    titleBar.addEventListener('mousedown', this.onDragStart.bind(this));
    titleBar.addEventListener('touchstart', this.onDragStart.bind(this));

    // 添加到 Cesium 容器
    const cesiumContainer = document.getElementById('cesiumContainer');
    if (cesiumContainer) {
      cesiumContainer.appendChild(this.controlPanel);

      // 根据默认折叠状态设置内容区域的初始显示状态
      if (this.contentElement) {
        this.contentElement.style.display = this.isCollapsed ? 'none' : 'block';
        // 如果是展开状态，设置初始高度
        if (!this.isCollapsed) {
          const contentHeight = Math.min(this.contentElement.scrollHeight, 400);
          this.contentElement.style.height = contentHeight + 'px';
        }
      }
    }
  }

  /**
   * 切换折叠状态
   */
  private toggleCollapse(): void {
    this.isCollapsed = !this.isCollapsed;
    if (this.contentElement && this.controlPanel) {
      // 设置内容区域显示状态
      this.contentElement.style.display = this.isCollapsed ? 'none' : 'block';

      // 更新折叠按钮箭头方向
      const collapseBtn = this.controlPanel.querySelector('.overlay-layer-collapse-btn');
      if (collapseBtn) {
        collapseBtn.innerHTML = this.isCollapsed ? '▲' : '▼';
      }

      // 调整控制面板布局
      if (!this.isCollapsed) {
        // 展开状态：设置内容区域高度
        const contentHeight = Math.min(this.contentElement.scrollHeight, 400);
        this.contentElement.style.height = contentHeight + 'px';
        // 设置控制面板为flex布局并调整顺序
        this.controlPanel.style.flexDirection = 'column';
        this.controlPanel.style.height = 'auto'; // 使用auto高度让内容自然展开
      } else {
        // 折叠状态：只显示标题栏
        this.contentElement.style.height = 'auto';
        this.controlPanel.style.height = 'auto';
      }
    }
  }

  /**
   * 拖拽开始
   */
  private onDragStart(e: MouseEvent | TouchEvent): void {
    this.isDragging = true;
    const evt = (e as TouchEvent).touches ? (e as TouchEvent).touches[0] : (e as MouseEvent);

    if (this.controlPanel) {
      const rect = this.controlPanel.getBoundingClientRect();
      this.dragOffset = {
        x: evt.clientX - rect.left,
        y: evt.clientY - rect.top,
      };
    }

    window.addEventListener('mousemove', this.onDragging.bind(this));
    window.addEventListener('mouseup', this.onDragEnd.bind(this));
    window.addEventListener('touchmove', this.onDragging.bind(this), { passive: false });
    window.addEventListener('touchend', this.onDragEnd.bind(this));
  }

  /**
   * 拖拽中
   */
  private onDragging(e: MouseEvent | TouchEvent): void {
    if (!this.isDragging || !this.controlPanel) return;
    const evt = (e as TouchEvent).touches ? (e as TouchEvent).touches[0] : (e as MouseEvent);

    const cesiumContainer = document.getElementById('cesiumContainer');
    if (!cesiumContainer) return;

    const containerRect = cesiumContainer.getBoundingClientRect();

    // 获取控制面板尺寸
    const panelWidth = this.controlPanel.offsetWidth;
    const titleBarHeight = 40; // 标题栏固定高度

    // 计算新位置（基于标题栏位置）
    let newX = evt.clientX - containerRect.left - this.dragOffset.x;
    let newBottom = containerRect.height - (evt.clientY - this.dragOffset.y);

    // 限制在容器内
    newX = Math.max(0, Math.min(newX, containerRect.width - panelWidth));
    newBottom = Math.max(60, newBottom); // 至少距离底部60px，避免被状态栏遮挡

    // 如果是展开状态，需要确保面板顶部不超出容器
    if (!this.isCollapsed && this.contentElement) {
      const contentHeight = Math.min(this.contentElement.scrollHeight, 400);
      const totalHeight = contentHeight + titleBarHeight;
      const maxTop = containerRect.height - newBottom - totalHeight;
      if (maxTop < 0) {
        newBottom = containerRect.height - totalHeight;
      }
    }

    // 设置新位置
    this.controlPanel.style.left = newX + 'px';
    this.controlPanel.style.right = 'auto';
    this.controlPanel.style.bottom = newBottom + 'px';

    if ((e as any).cancelable) {
      (e as any).preventDefault();
    }
  }

  /**
   * 拖拽结束
   */
  private onDragEnd(): void {
    this.isDragging = false;
    window.removeEventListener('mousemove', this.onDragging.bind(this));
    window.removeEventListener('mouseup', this.onDragEnd.bind(this));
    window.removeEventListener('touchmove', this.onDragging.bind(this));
    window.removeEventListener('touchend', this.onDragEnd.bind(this));
  }

  /**
   * 将图层添加到控制面板
   */
  private addLayerToControlPanel(config: OverlayLayerConfig): void {
    if (!this.contentElement) {
      return;
    }

    // 创建图层控制项
    const layerContainer = document.createElement('div');
    layerContainer.id = `overlay-layer-${config.id}`;
    layerContainer.className = 'overlay-layer-item';
    layerContainer.style.marginBottom = '8px';
    layerContainer.style.padding = '8px';
    layerContainer.style.borderRadius = '6px';
    layerContainer.style.backgroundColor = 'rgba(255, 255, 255, 0.35)';
    layerContainer.style.transition = 'all 0.2s';
    layerContainer.style.color = '#333';

    // 创建顶部控制区域
    const topControl = document.createElement('div');
    topControl.style.display = 'flex';
    topControl.style.alignItems = 'center';

    // 创建复选框
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.id = `overlay-checkbox-${config.id}`;
    checkbox.checked = config.visible ?? true;
    checkbox.style.marginRight = '8px';
    checkbox.style.cursor = 'pointer';
    checkbox.addEventListener('change', (e) => {
      this.toggleOverlayLayer(config.id, (e.target as HTMLInputElement).checked);
    });

    // 创建标签
    const label = document.createElement('label');
    label.htmlFor = `overlay-checkbox-${config.id}`;
    label.textContent = config.name;
    label.style.cursor = 'pointer';
    label.style.fontSize = '13px';
    label.style.fontWeight = '500';
    label.style.color = '#333';

    // 组装顶部控制
    topControl.appendChild(checkbox);
    topControl.appendChild(label);
    layerContainer.appendChild(topControl);

    // 添加到内容区域
    this.contentElement.appendChild(layerContainer);
  }
}

/**
 * 从 config.json 加载叠加图层配置
 */
export async function loadOverlayLayersConfig(): Promise<OverlayLayerConfig[]> {
  try {
    const response = await fetch('/config.json');
    const config = await response.json();

    // 检查是否有叠加图层配置
    if (config && config.mapConfig && config.mapConfig.overlayLayers && Array.isArray(config.mapConfig.overlayLayers)) {
      return config.mapConfig.overlayLayers;
    }

    return [];
  } catch (error) {
    console.error('加载叠加图层配置失败:', error);
    return [];
  }
}

/**
 * 初始化叠加图层管理器
 * @param viewer Cesium Viewer实例
 * @param geoserverConfigUrl 可选的GeoServer配置文件URL，默认为'/myMapConfig.json'
 */
export async function initOverlayLayers(viewer: Cesium.Viewer, geoserverConfigUrl: string = '/myMapConfig.json'): Promise<OverlayLayerManager> {
  const layerManager = new OverlayLayerManager(viewer);

  try {
    // 从指定的GeoServer配置文件加载（默认为myMapConfig.json）
    await layerManager.loadOverlayLayersFromExternal(geoserverConfigUrl);
  } catch (error) {
    console.error('从myMapConfig.json加载叠加图层失败:', error);

    try {
      // 如果默认配置加载失败，尝试从原始配置加载
      const overlayLayersConfig = await loadOverlayLayersConfig();

      // 如果有配置，则加载图层
      if (overlayLayersConfig.length > 0) {
        // 根据order字段排序图层
        overlayLayersConfig.sort((a, b) => {
          const orderA = a.order ?? Number.MAX_SAFE_INTEGER;
          const orderB = b.order ?? Number.MAX_SAFE_INTEGER;
          return orderA - orderB;
        });

        await layerManager.loadOverlayLayers(overlayLayersConfig);
      }
    } catch (secondError) {
      console.error('初始化叠加图层失败:', secondError);
    }
  }

  return layerManager;
}
