const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electron', {
  selectFolder: async () => {
    try {
      console.log('[Preload] Requesting folder selection...');
      const folder = await ipcRenderer.invoke('dialog:selectFolder');
      console.log('[Preload] Folder selected:', folder);
      return folder;
    } catch (err) {
      console.error('[Preload] Error selecting folder:', err);
      return null;
    }
  },

  selectFile: async () => {
    try {
      console.log('[Preload] Requesting file selection...');
      const file = await ipcRenderer.invoke('dialog:selectFile');
      console.log('[Preload] File selected:', file);
      return file;
    } catch (err) {
      console.error('[Preload] Error selecting file:', err);
      return null;
    }
  }
});
