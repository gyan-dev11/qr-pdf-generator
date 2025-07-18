const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electron', {
  selectFolder: async () => await ipcRenderer.invoke('dialog:selectFolder'),
  selectFile: async () => await ipcRenderer.invoke('dialog:selectFile'),
});
