// iframe-widget.js
(function () {
  let widgetInstance = null;
  const defaultConfig = {
    // 支持'top-left'左上, 'top-right'右上, 'bottom-left'左下, 'bottom-right'右下
    iconPosition: 'bottom-right',
    //图标的大小
    iconSize: '45px',
    //图标的颜色
    // iconColor: '#155eef',
    //必填不允许修改
    appId: '',
    //聊天弹窗的宽度
    chatWidth: '600px',
    //聊天弹窗的高度
    chatHeight: '500px',
  };

  /**
   * 创建ai图标
   * @param config
   */
  function createAiChat(config) {
    // 单例模式，确保只存在一个实例
    if (widgetInstance) {
      return;
    }

    // 合并配置
    const finalConfig = { ...defaultConfig, ...config };

    if (!finalConfig.appId) {
      console.error('appId为空！');
      return;
    }
    let body = document.body;
    body.style.margin = '0';
    // 创建容器
    const container = document.createElement('div');
    container.style.cssText = `
            position: fixed;
            z-index: 998;
            ${getPositionStyles(finalConfig.iconPosition)}
            cursor: pointer;
            user-select: none;
            touch-action: none;
        `;
    // 创建图标
    const icon = document.createElement('div');
    icon.style.cssText = `
            width: ${finalConfig.iconSize};
            height: ${finalConfig.iconSize};
            background-color: ${finalConfig.iconColor};
            border-radius: 50%;
            box-shadow: #cccccc 0 4px 8px 0;
            padding: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            box-sizing: border-box;
        `;
    icon.innerHTML =
      '<svg t="1751276924193" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="5722" width="200" height="200"><path d="M951.96875 792.03125c-22.125 0-40.03125-17.90625-40.03125-40.03125V552.03125c0-22.125 17.90625-40.03125 40.03125-40.03125s40.03125 17.90625 40.03125 40.03125V752c0 22.125-17.90625 40.03125-40.03125 40.03125zM752 912.03125H272c-66.28125 0-120-53.71875-120-120v-360c0-66.28125 53.71875-120 120-120h199.96875v-51.09375c-23.8125-13.875-40.03125-39.375-40.03125-68.90625 0-44.15625 35.8125-79.96875 79.96875-79.96875s79.96875 35.8125 79.96875 79.96875c0 29.53125-16.21875 55.03125-40.03125 68.90625v51.09375H752c66.28125 0 120 53.71875 120 120v360c0 66.28125-53.71875 120-120 120z m40.03125-440.0625c0-44.15625-35.8125-79.96875-79.96875-79.96875H312.03125c-44.15625 0-79.96875 35.8125-79.96875 79.96875V752c0 44.15625 35.8125 79.96875 79.96875 79.96875h400.03125c44.15625 0 79.96875-35.8125 79.96875-79.96875V471.96875zM651.96875 672.03125c-33.09375 0-60-26.90625-60-60s26.90625-60 60-60 60 26.90625 60 60-26.8125 60-60 60z m-279.9375 0c-33.09375 0-60-26.90625-60-60s26.90625-60 60-60 60 26.90625 60 60-26.90625 60-60 60z m-300 120C49.90625 792.03125 32 774.125 32 752V552.03125C32 529.90625 49.90625 512 72.03125 512s40.03125 17.90625 40.03125 40.03125V752c-0.09375 22.125-18 40.03125-40.03125 40.03125z" fill="#2C4CE2" p-id="5723"></path></svg>';

    // 创建iframe容器
    const iframeContainer = document.createElement('div');
    let right = finalConfig.chatWidth === '100%' ? '0' : '10px';
    let bottom = finalConfig.chatHeight === '100%' ? '0' : '10px';
    let chatWidth = finalConfig.chatWidth;
    let chatHeight = finalConfig.chatHeight;
    iframeContainer.style.cssText = `
            position: fixed;
            right: ${right};
            bottom: ${bottom};
            width: ${chatWidth} !important;
            height: ${chatHeight} !important;
            background: white;
            border-radius: 8px;
            box-shadow: 0 0 20px #cccccc;
            display: none;
            z-index: 10000;
        `;

    // 创建iframe
    const iframe = document.createElement('iframe');
    iframe.style.cssText = `
            width: 100%;
            height: 100%;
            border: none;
            border-radius: 8px;
        `;

    iframe.id = 'ai-app-chat-document';
    //update-begin---author:wangshuai---date:2025-04-25---for:【QQYUN-12159】【AI 广告位】让需要自建AI知识库的用户知道如何通过敲敲云搭建自己的AI知识库---
    iframe.src = getIframeSrc(finalConfig) + '/ai/app/chat/' + finalConfig.appId + '?source=chatJs';
    //update-end---author:wangshuai---date:2025-04-25---for:【QQYUN-12159】【AI 广告位】让需要自建AI知识库的用户知道如何通过敲敲云搭建自己的AI知识库---
    let iconRight = finalConfig.chatWidth === '100%' ? '0' : '-6px';
    let iconTop = finalConfig.chatWidth === '100%' ? '0' : '-9px';
    // 创建关闭按钮
    const closeBtn = document.createElement('div');
    closeBtn.innerHTML =
      '<svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" width="1em" height="1em" viewBox="0 0 1024 1024" class="iconify iconify--ant-design"><path fill="currentColor" fill-rule="evenodd" d="M799.855 166.312c.023.007.043.018.084.059l57.69 57.69c.041.041.052.06.059.084a.1.1 0 0 1 0 .069c-.007.023-.018.042-.059.083L569.926 512l287.703 287.703c.041.04.052.06.059.083a.12.12 0 0 1 0 .07c-.007.022-.018.042-.059.083l-57.69 57.69c-.041.041-.06.052-.084.059a.1.1 0 0 1-.069 0c-.023-.007-.042-.018-.083-.059L512 569.926L224.297 857.629c-.04.041-.06.052-.083.059a.12.12 0 0 1-.07 0c-.022-.007-.042-.018-.083-.059l-57.69-57.69c-.041-.041-.052-.06-.059-.084a.1.1 0 0 1 0-.069c.007-.023.018-.042.059-.083L454.073 512L166.371 224.297c-.041-.04-.052-.06-.059-.083a.12.12 0 0 1 0-.07c.007-.022.018-.042.059-.083l57.69-57.69c.041-.041.06-.052.084-.059a.1.1 0 0 1 .069 0c.023.007.042.018.083.059L512 454.073l287.703-287.702c.04-.041.06-.052.083-.059a.12.12 0 0 1 .07 0Z"></path></svg>';
    closeBtn.style.cssText = `
            position: absolute;
            margin-top: ${iconTop};
            right: ${iconRight};
            cursor: pointer;
            background: white;
            width: 25px;
            height: 25px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 5px #cccccc;
        `;

    // 组装元素
    iframeContainer.appendChild(closeBtn);
    iframeContainer.appendChild(iframe);
    document.body.appendChild(iframeContainer);
    container.appendChild(icon);
    document.body.appendChild(container);

    // 拖动相关变量
    let isDragging = false;
    let offsetX, offsetY;
    let startX, startY;

    // 开始拖动
    function startDrag(e) {
      // 阻止冒泡，避免触发点击事件
      e.stopPropagation();
      
      isDragging = true;
      
      // 处理鼠标事件和触摸事件
      if (e.type === 'mousedown') {
        startX = e.clientX;
        startY = e.clientY;
      } else if (e.type === 'touchstart') {
        startX = e.touches[0].clientX;
        startY = e.touches[0].clientY;
      }
      
      // 计算鼠标在图标内的偏移量
      const rect = container.getBoundingClientRect();
      offsetX = startX - rect.left;
      offsetY = startY - rect.top;
      
      // 添加移动和结束事件监听
      if (e.type === 'mousedown') {
        document.addEventListener('mousemove', drag);
        document.addEventListener('mouseup', stopDrag);
      } else if (e.type === 'touchstart') {
        document.addEventListener('touchmove', drag, { passive: false });
        document.addEventListener('touchend', stopDrag);
      }
    }
    
    // 拖动过程
    function drag(e) {
      if (!isDragging) return;
      
      // 阻止默认行为，避免页面滚动
      e.preventDefault();
      
      let clientX, clientY;
      
      // 处理鼠标事件和触摸事件
      if (e.type === 'mousemove') {
        clientX = e.clientX;
        clientY = e.clientY;
      } else if (e.type === 'touchmove') {
        clientX = e.touches[0].clientX;
        clientY = e.touches[0].clientY;
      }
      
      // 计算新位置
      const newLeft = clientX - offsetX;
      const newTop = clientY - offsetY;
      
      // 限制在视口范围内
      const maxX = window.innerWidth - container.offsetWidth;
      const maxY = window.innerHeight - container.offsetHeight;
      
      const boundedLeft = Math.max(0, Math.min(newLeft, maxX));
      const boundedTop = Math.max(0, Math.min(newTop, maxY));
      
      // 设置新位置
      container.style.left = boundedLeft + 'px';
      container.style.top = boundedTop + 'px';
      container.style.right = 'auto';
      container.style.bottom = 'auto';
    }
    
    // 停止拖动
    function stopDrag() {
      isDragging = false;
      
      // 移除事件监听
      document.removeEventListener('mousemove', drag);
      document.removeEventListener('mouseup', stopDrag);
      document.removeEventListener('touchmove', drag);
      document.removeEventListener('touchend', stopDrag);
    }
    
    // 添加拖动事件监听
    container.addEventListener('mousedown', startDrag);
    container.addEventListener('touchstart', startDrag);
    
    // 点击事件 - 使用mouseup事件来区分点击和拖动
    container.addEventListener('mouseup', (e) => {
      // 如果鼠标位置与开始位置相近，则视为点击而非拖动
      if (Math.abs(e.clientX - startX) < 5 && Math.abs(e.clientY - startY) < 5) {
        iframeContainer.style.display = 'block';
      }
    });
    
    // 触摸结束事件 - 用于移动设备
    container.addEventListener('touchend', (e) => {
      if (e.changedTouches.length > 0) {
        const touch = e.changedTouches[0];
        // 如果触摸位置与开始位置相近，则视为点击而非拖动
        if (Math.abs(touch.clientX - startX) < 5 && Math.abs(touch.clientY - startY) < 5) {
          iframeContainer.style.display = 'block';
        }
      }
    });

    closeBtn.addEventListener('click', () => {
      iframeContainer.style.display = 'none';
    });

    // 保存实例引用
    widgetInstance = {
      remove: () => {
        container.remove();
        iframeContainer.remove();
      },
    };
  }

  /**
   * 获取位置信息
   *
   * @param position
   * @returns {*|string}
   */
  function getPositionStyles(position) {
    const positions = {
      'top-left': 'top: 20px; left: 20px;',
      'top-right': 'top: 20px; right: 20px;',
      'bottom-left': 'bottom: 20px; left: 20px;',
      'bottom-right': 'bottom: 20px; right: 20px;',
    };
    return positions[position] || positions['bottom-right'];
  }

  /**
   * 获取src地址
   */
  function getIframeSrc(finalConfig) {
    const specificScript = document.getElementById('e7e007dd52f67fe36365eff636bbffbd');
    if (specificScript) {
      return specificScript.src.substring(0, specificScript.src.indexOf('/', specificScript.src.indexOf('://') + 3));
    }
  }



  // 暴露全局方法
  window.createAiChat = createAiChat;
})();
