import mitt from '/@/utils/mitt';

const passwordChangeEmitter = mitt();

export function emitPasswordChangeRequired() {
  console.log('Emitting passwordChangeRequired event');
  passwordChangeEmitter.emit('passwordChangeRequired');
}

export function listenPasswordChangeRequired(callback: () => void) {
  passwordChangeEmitter.on('passwordChangeRequired', callback);
}

export function removePasswordChangeListener() {
  passwordChangeEmitter.clear();
}