// iframe-widget.js
(function () {
  let widgetInstance = null;
  const defaultConfig = {
    // ֧��'top-left'����, 'top-right'����, 'bottom-left'����, 'bottom-right'����
    iconPosition: 'bottom-right',
    //ͼ��Ĵ�С
    iconSize: '60px',
    //ͼ�����ɫ
    iconColor: '#155eef',
    //��������޸�
    appId: '',
    //���쵯���Ŀ���
    chatWidth: '800px',
    //���쵯���ĸ߶�
    chatHeight: '700px',
  };

  /**
   * ����aiͼ��
   * @param config
   */
  function createAiChat(config) {
    // ����ģʽ��ȷ��ֻ����һ��ʵ��
    if (widgetInstance) {
      return;
    }

    // �ϲ�����
    const finalConfig = { ...defaultConfig, ...config };

    if (!finalConfig.appId) {
      console.error('appIdΪ�գ�');
      return;
    }
    // ��������
    const container = document.createElement('div');
    container.style.cssText = `
            position: fixed;
            z-index: 998;
            ${getPositionStyles(finalConfig.iconPosition)}
            cursor: pointer;
        `;
    // ����ͼ��
    const icon = document.createElement('div');
    icon.style.cssText = `
            width: ${finalConfig.iconSize};
            height: ${finalConfig.iconSize};
           
            background-color:color.white;
            border-radius: 50%;
            box-shadow: rgba(0, 0, 0, 0.2) 0 4px 8px 0;
            padding: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        `;
    icon.innerHTML =
      '<svg t="1750517509438" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="19577" xmlns:xlink="http://www.w3.org/1999/xlink" width="200" height="200"><path d="M951.96875 792.03125c-22.125 0-40.03125-17.90625-40.03125-40.03125V552.03125c0-22.125 17.90625-40.03125 40.03125-40.03125s40.03125 17.90625 40.03125 40.03125V752c0 22.125-17.90625 40.03125-40.03125 40.03125zM752 912.03125H272c-66.28125 0-120-53.71875-120-120v-360c0-66.28125 53.71875-120 120-120h199.96875v-51.09375c-23.8125-13.875-40.03125-39.375-40.03125-68.90625 0-44.15625 35.8125-79.96875 79.96875-79.96875s79.96875 35.8125 79.96875 79.96875c0 29.53125-16.21875 55.03125-40.03125 68.90625v51.09375H752c66.28125 0 120 53.71875 120 120v360c0 66.28125-53.71875 120-120 120z m40.03125-440.0625c0-44.15625-35.8125-79.96875-79.96875-79.96875H312.03125c-44.15625 0-79.96875 35.8125-79.96875 79.96875V752c0 44.15625 35.8125 79.96875 79.96875 79.96875h400.03125c44.15625 0 79.96875-35.8125 79.96875-79.96875V471.96875zM651.96875 672.03125c-33.09375 0-60-26.90625-60-60s26.90625-60 60-60 60 26.90625 60 60-26.8125 60-60 60z m-279.9375 0c-33.09375 0-60-26.90625-60-60s26.90625-60 60-60 60 26.90625 60 60-26.90625 60-60 60z m-300 120C49.90625 792.03125 32 774.125 32 752V552.03125C32 529.90625 49.90625 512 72.03125 512s40.03125 17.90625 40.03125 40.03125V752c-0.09375 22.125-18 40.03125-40.03125 40.03125z" fill="#2C4CE2" p-id="19578"></path></svg>';

    // ����iframe����
    const iframeContainer = document.createElement('div');
    iframeContainer.style.cssText = `
            position: absolute;
            right: 10px;
            bottom: 10px;
            width: ${finalConfig.chatWidth} !important;
            height: ${finalConfig.chatHeight} !important;
            background: white;
            border-radius: 8px;
            box-shadow: 0 0 20px rgba(0,0,0,0.2);
            display: none;
            z-index: 10000;
        `;

    // ����iframe
    const iframe = document.createElement('iframe');
    iframe.style.cssText = `
            width: 100%;
            height: 100%;
            border: none;
            border-radius: 8px;
        `;

    iframe.id = 'ai-app-chat-document';
    iframe.src = getIframeSrc(finalConfig) + '/ai/app/chat/' + finalConfig.appId;
    // �����رհ�ť
    const closeBtn = document.createElement('div');
    closeBtn.innerHTML =
      '<svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" width="1em" height="1em" viewBox="0 0 1024 1024" class="iconify iconify--ant-design"><path fill="currentColor" fill-rule="evenodd" d="M799.855 166.312c.023.007.043.018.084.059l57.69 57.69c.041.041.052.06.059.084a.1.1 0 0 1 0 .069c-.007.023-.018.042-.059.083L569.926 512l287.703 287.703c.041.04.052.06.059.083a.12.12 0 0 1 0 .07c-.007.022-.018.042-.059.083l-57.69 57.69c-.041.041-.06.052-.084.059a.1.1 0 0 1-.069 0c-.023-.007-.042-.018-.083-.059L512 569.926L224.297 857.629c-.04.041-.06.052-.083.059a.12.12 0 0 1-.07 0c-.022-.007-.042-.018-.083-.059l-57.69-57.69c-.041-.041-.052-.06-.059-.084a.1.1 0 0 1 0-.069c.007-.023.018-.042.059-.083L454.073 512L166.371 224.297c-.041-.04-.052-.06-.059-.083a.12.12 0 0 1 0-.07c.007-.022.018-.042.059-.083l57.69-57.69c.041-.041.06-.052.084-.059a.1.1 0 0 1 .069 0c.023.007.042.018.083.059L512 454.073l287.703-287.702c.04-.041.06-.052.083-.059a.12.12 0 0 1 .07 0Z"></path></svg>';
    closeBtn.style.cssText = `
            position: absolute;
            right: -3px;
            top: -10px;
            cursor: pointer;
            background: white;
            width: 25px;
            height: 25px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        `;

    // ��װԪ��
    iframeContainer.appendChild(closeBtn);
    iframeContainer.appendChild(iframe);
    document.body.appendChild(iframeContainer);
    container.appendChild(icon);
    document.body.appendChild(container);

    // �¼�����
    icon.addEventListener('click', () => {
      iframeContainer.style.display = 'block';
    });

    closeBtn.addEventListener('click', () => {
      iframeContainer.style.display = 'none';
    });

    // ����ʵ������
    widgetInstance = {
      remove: () => {
        container.remove();
        iframeContainer.remove();
      },
    };
  }

  /**
   * ��ȡλ����Ϣ
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
   * ��ȡsrc��ַ
   */
  function getIframeSrc(finalConfig) {
    const specificScript = document.getElementById('e7e007dd52f67fe36365eff636bbffbd');
    if (specificScript) {
      return specificScript.src.substring(0, specificScript.src.indexOf('/', specificScript.src.indexOf('://') + 3));
    }
  }

  // ��¶ȫ�ַ���
  window.createAiChat = createAiChat;
})();
