/**
 * 获取应用标题
 * 优先使用 config.json 中的 title，如果没有则使用默认值
 */
export function getAppTitle(): string {
  return (window as any)._CONFIG?.title || '数智一体化平台';
}

/**
 * 替换国际化文本中的 {APP_TITLE} 占位符
 */
export function replaceAppTitle(text: string): string {
  return text.replace('{APP_TITLE}', getAppTitle());
}
